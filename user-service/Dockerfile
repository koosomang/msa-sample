FROM python:3.11-slim

# 환경변수 설정
ENV AUTOWRAPT_BOOTSTRAP=instana
ENV INSTANA_AGENT_HOST=instana-agent 
ENV INSTANA_AGENT_PORT=42699

WORKDIR /app
COPY . /app
#COPY user-service.py .
#COPY templates ./templates

RUN pip install flask requests
RUN pip install instana
RUN pip install python-dotenv

CMD ["python", "user-service.py"]

