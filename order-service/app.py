from flask import Flask, request, jsonify
import requests   # 누락 시 추가!

app = Flask(__name__)
PRODUCT_SERVICE_URL = 'http://product-service:5001/api/products'

@app.route('/create_order', methods=['POST'])
def create_order():
    data = request.get_json(force=True)
    product_ids = data.get('product_ids', [])

    resp = requests.get(PRODUCT_SERVICE_URL)
    all_products = resp.json()

    selected = [p for p in all_products if p["id"] in product_ids]
    order_id = "o1"

    return jsonify({"order_id": order_id, "products": selected})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)

