## Nginx Proxy 설정
- 파일 생성
```
sudo cat /etc/nginx/sites-available/msa-sample

server {
    if ($host = {HOST_NAME}) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name {HOST_NAME};
    return 301 https://$host$request_uri;


}

server {
    listen 443 ssl http2;
    server_name {HOST_NAME};

    ssl_certificate /etc/letsencrypt/live/{HOST_NAME}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{HOST_NAME}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://127.0.0.1:5100/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    ssl_certificate /etc/letsencrypt/live/{HOST_NAME}/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/{HOST_NAME}/privkey.pem; # managed by Certbot
}
```

- 연결
```
sudo ln -s /etc/nginx/sites-available/msa-sample /etc/nginx/sites-enabled
```
