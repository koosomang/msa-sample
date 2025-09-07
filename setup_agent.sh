#!/bin/bash

###
### Copyright 2019, 2025, Instana Inc.
###
### Licensed under the Apache License, Version 2.0 (the "License");
### you may not use this file except in compliance with the License.
### You may obtain a copy of the License at
###
###     http://www.apache.org/licenses/LICENSE-2.0
###
### Unless required by applicable law or agreed to in writing, software
### distributed under the License is distributed on an "AS IS" BASIS,
### WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
### See the License for the specific language governing permissions and
### limitations under the License.
###

set -o pipefail

AGENT_DIR="/opt/instana/agent"
AGENT_DIR_ZOS="${PWD}/instana-agent"
AGENT_DIR_ZOS_OLD="${PWD}/instana-agent-old"
# AIX, Darwin, Linux, SunOS
OS=$(uname -s)
MACHINE=""
FAMILY="unknown"
INIT="sysv"

PKG_URI=packages.instana.io

AGENT_TYPE="dynamic"
OPEN_J9="false"
PROMPT=true
ENABLE_SERVICE=false
RESTART=false
LOCATION=
ENDPOINT=""
MODE="apm"
GIT_REPO=
GIT_BRANCH=
GIT_USERNAME=
GIT_PASSWORD=
INSTANA_AGENT_SYSTEMD_TYPE=simple

INSTANA_AGENT_KEY="$INSTANA_AGENT_KEY"
INSTANA_DOWNLOAD_KEY="$INSTANA_DOWNLOAD_KEY"
INSTANA_AGENT_HOST="$INSTANA_AGENT_HOST"
INSTANA_AGENT_PORT="${INSTANA_AGENT_PORT:-443}"

INSTANA_AWS_REGION_CONFIG=""

gpg_check=1

function exists {
  if which "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

download_command='none'

function download_to_stdout {
  case "${download_command}" in
  'curl')
    download_to_stdout_curl $@
    ;;
  'wget')
    download_to_stdout_wget $@
    ;;
  *)
    log_error "Unknown download command '${download_command}'"
    exit 1;
  esac
}

function download_to_stdout_curl {
  local request_method=""
  if [[ "$1" == "GET" || "$1" == "POST" || "$1" == "PUT" ]]; then
    request_method="-X ${1}"
    shift
  fi

  local url="$1"

  local header_parameter
  if [[ "$2" == "-H" ]]; then
    header_parameter="-H ${3}"
    shift 2
  fi
  # Auth is passed in curl format: <user>:<password>
  local authentication="$2"
  local authentication_parameters
  # Connection timeout, default 2 secs
  local connect_timeout="${3:-2}"

  if [ -n "${authentication}" ]; then
    authentication_parameters="-u ${authentication}"
  fi

  if curl -s --fail --connect-timeout "${connect_timeout}" ${request_method} ${header_parameter} ${authentication_parameters} "${url}"; then
    return 0
  else
    return $?
  fi
}

function download_to_stdout_wget {
  local request_method=""
  if [[ "$1" == "GET" || "$1" == "POST" || "$1" == "PUT" ]]; then
    request_method="--method=${1}"
    shift
  fi

  local url="$1"

  local header_parameter
  if [[ "$2" == "-H" ]]; then
    header_parameter="--header ${3}"
    shift 2
  fi
  # Auth is passed in curl format: <user>:<password>
  local authentication="$2"
  local authentication_parameters
  # Connection timeout, default 2 secs
  local connect_timeout="${3:-2}"

  if [ -n "${authentication}" ]; then
    local username;
    username=$(awk -F ':' '{ print $1}' <<< "${authentication}")

    local password
    password=$(awk -F ':' '{ print $2}' <<< "${authentication}")

    authentication_parameters="--auth-no-challenge --http-user=${username} --http-password=${password}"
  fi

  if wget --timeout="${connect_timeout}" ${request_method} ${header_parameter} -qO- ${authentication_parameters} "${url}"; then
    return 0
  else
    return $?
  fi
}

function log_error {
  local message=$1

  if [[ $TERM == *"color"* ]]; then
    echo -e "\e[31m$message\e[0m"
  else
    echo $message
  fi
}

function log_info {
  local message=$1

  if [[ $TERM == *"color"* ]]; then
    echo -e "\e[32m$message\e[0m"
  else
    echo $message
  fi
}

function log_warn {
  local message=$1

  if [[ $TERM == *"color"* ]]; then
    echo -e "\e[33m${message}\e[0m"
  else
    echo "${message}"
  fi
}

function receive_confirmation() {
  read -r -p "$1 [y/N] " response

  if [[ ! $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 1
  fi

  return 0
}

function check_zOS_prerequisites() {
 if command -v gzip > /dev/null && command -v pax > /dev/nu