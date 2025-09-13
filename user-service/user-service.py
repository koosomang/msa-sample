import instana
from flask import Flask, request, render_template, jsonify
import os
import requests
import time
from dotenv import load_dotenv

# .env 파일에서 환경변수 자동 로드
load_dotenv()

app = Flask(__name__)

ORDER_SERVICE_URL = 'http://order-service:5002/create_order'
INSTANA_SERVICE_NAME = "user-service"
INSTANA_API_URL = os.getenv("INSTANA_API_URL")
INSTANA_API_TOKEN = os.getenv("INSTANA_API_TOKEN")

#Instana
print(dir(instana))
tracer = instana.tracer  # instana 내 tracer 객체 직접 사용

@app.route('/', methods=['GET'])
def index():
    # Instana가 자동 계측하므로 별도 트레이스 코드 불필요
    products = requests.get('http://product-service:5001/api/products').json()
    return render_template('index.html', products=products)

@app.route('/order', methods=['POST'])
def create_order():
    product_ids = request.json.get('product_ids', [])
    # 강제 에러 조건
    if 'error' in product_ids:
        return jsonify({"error": "강제 발생시킨 주문 처리 에러"}), 500

    resp = requests.post(ORDER_SERVICE_URL, json={"product_ids": product_ids})
    order_result = resp.json() if resp.ok else {"error": "Order failed"}
    return jsonify(order_result)

@app.route('/release_mark', methods=['POST'])
def release_mark():
    try:
        data = request.get_json()
        app_name = data.get('application_name')
        message = data.get('message')
        current_time_ms = int(time.time() * 1000)
        if not app_name or not message:
            return jsonify({"status": "error", "message": "Missing fields"}), 400

        payload = {
            "name": message,
            "start": current_time_ms,
            "applications": [{"name": app_name}]
        }
        headers = {
            "Authorization": f"apiToken {INSTANA_API_TOKEN}",
            "Content-Type": "application/json"
        }
        print("Payload sent to Instana API:", payload)
        response = requests.post(INSTANA_API_URL, json=payload, headers=headers, verify=False)
        response.raise_for_status()

        return jsonify({"status": "success", "message": "Release mark sent"})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"status": "error", "message": f"서버 오류: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5100)

