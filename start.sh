podman build -t product-service ./product-service
podman run -d --replace --name product-service --network msa-net -p 5001:5001 product-service

podman build -t order-service ./order-service
podman run -d --replace --name order-service --network msa-net -p 5002:5002 order-service

podman build -t user-service ./user-service
podman run -d --replace --name user-service --network msa-net -p 5100:5100 user-service

