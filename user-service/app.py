import instana
from flask import Flask, request, render_template, jsonify
import requests

app = Flask(__name__)

ORDER_SERVICE_URL = 'http://order-service:5002/create_order'

@app.route('/', methods=['GET'])
def index():
    # Instana가 자동 계측하므로 별도 트레이스 코드 불필요
    products = requests.get('http://product-service:5001/api/products').json()
    return render_template('index.html', products=products)

@app.route('/order', methods=['POST'])
def create_order():
    product_ids = request.json.get('product_ids', [])
    resp = requests.post(ORDER_SERVICE_URL, json={"product_ids": product_ids})
    order_result = resp.json() if resp.ok else {"error": "Order failed"}
    return jsonify(order_result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5100)

