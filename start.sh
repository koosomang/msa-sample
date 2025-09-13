#!/bin/bash

set -e

# .env 파일에서 변수 로드
source .env

# 함수: 이미지가 이미 존재하면 true 반환
image_exists() {
  sudo ctr -n k8s.io images ls | grep -q "$1"
  return $?
}

# 서비스 목록 및 경로 정의
services=("product-service" "order-service" "user-service")
for service in "${services[@]}"; do
  image_name="localhost/${service}:latest"
  tar_file="${service}.tar"
  dir_path="./${service}"

  # tar 파일 삭제 (존재 시)
  if [ -f "$tar_file" ]; then
    echo "Deleting existing $tar_file"
    rm -f "$tar_file"
  fi

  # 이미지 빌드
  echo "Building image for $service..."
  podman build -t "$image_name" "$dir_path"

  #이미지 변경 체크 (digest 비교 등) - 단순화하여 무조건 저장 후 임포트
  podman save -o "$tar_file" "$image_name"

  # 기존 이미지가 있으면 삭제
  if image_exists "$image_name"; then
    echo "Removing existing image $image_name"
    sudo ctr -n k8s.io images rm "$image_name"
  fi

  # 새 이미지 임포트
  echo "Importing $tar_file into containerd..."
  sudo ctr -n k8s.io images import "$tar_file"
done

# Kubernetes 매니페스트 배포 적용
echo "Applying Kubernetes manifests..."
kubectl apply -f k3s

# 배포된 모든 Pod 강제 재시작 (재배포)
echo "Restarting all pods in msa-sample namespace..."
kubectl delete pod --all -n msa-sample

echo "Deployment update completed."


AUTH_HEADER="Authorization: apiToken $INSTANA_API_TOKEN"
CONTENT_HEADER="Content-Type: application/json"
CURRENT_TIME_MS=$(date +%s%3N)

json_payload=$(cat <<EOF
{
  "name": "v.1.1",
  "start": $CURRENT_TIME_MS,
  "applications": [
    {
      "name": "{user-name}-test-application"
    }
  ]
}
EOF
)

#echo "Starting pipeline feedback ..."
#curl -k --location --request POST "$INSTANA_API_URL" \
#  -H "$AUTH_HEADER" -H "$CONTENT_HEADER" \
#  --data "$json_payload"
#
#echo "Pipeline feedback started."
