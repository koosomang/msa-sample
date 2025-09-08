import instana
from flask import Flask, render_template, jsonify

app = Flask(__name__)

INSTANA_SERVICE_NAME = "product-service"

#Instana
print(dir(instana))
tracer = instana.tracer  # instana 내 tracer 객체 직접 사용

products = [
    {"id": "p1", "name": "Apple"},
    {"id": "p2", "name": "Banana"},
    {"id": "p3", "name": "Cherry"}
]

# UI용 HTML 페이지
@app.route('/products')
def products_page():
    return render_template('products.html', products=products)

# API용 JSON 데이터 반환 경로
@app.route('/api/products')
def products_api():
    return jsonify(products)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

