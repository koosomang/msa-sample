FROM python:3.11-slim

# 환경변수 설정
ENV AUTOWRAPT_BOOTSTRAP=instana

WORKDIR /app
COPY product-service.py .
COPY templates ./templates

RUN pip install flask
RUN pip install instana

CMD ["python", "product-service.py"]

