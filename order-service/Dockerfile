FROM python:3.11-slim

# 환경변수 설정
ENV AUTOWRAPT_BOOTSTRAP=instana

WORKDIR /app
COPY order-service.py .
COPY templates ./templates

RUN pip install flask requests
RUN pip install instana

CMD ["python", "order-service.py"]

