# 🚀 ติดตั้ง n8n บน GCP VM พร้อม HTTPS ด้วย NGINX + Self-signed SSL (ไม่มีโดเมนก็ใช้ได้)

## 📦 ติดตั้งอัตโนมัติแบบ 1-Click ด้วย Shell Script

สร้างไฟล์ชื่อ `setup-n8n-gcp.sh` แล้ววางโค้ดนี้:

```bash
#!/bin/bash

IP_ADDRESS="$1"
if [ -z "$IP_ADDRESS" ]; then
  echo "❌ กรุณาระบุ External IP ของ VM เป็น argument เช่น ./setup.sh <EXTERNAL_IP>"
  exit 1
fi

echo "✅ ติดตั้ง Docker และ Docker Compose..."
sudo apt update && sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

mkdir -p ~/n8n && cd ~/n8n

cat > docker-compose.yml <<EOF
version: "3.7"

services:
  postgres:
    image: postgres:15
    restart: always
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8npass
      - POSTGRES_DB=n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data

  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8npass
      - DB_POSTGRESDB_SCHEMA=public
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_HOST=localhost
      - WEBHOOK_URL=http://localhost:5678/
      - NODE_ENV=production
      - N8N_SECURE_COOKIE=false
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres

volumes:
  postgres_data:
  n8n_data:
EOF

docker compose up -d

echo "✅ ติดตั้ง nginx และสร้าง SSL..."
sudo apt install -y nginx openssl certbot python3-certbot-nginx

sudo mkdir -p /etc/nginx/ssl/n8n
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/n8n/server.key \
  -out /etc/nginx/ssl/n8n/server.crt \
  -subj "/CN=$IP_ADDRESS"

sudo tee /etc/nginx/sites-available/n8n > /dev/null <<EOF
server {
    listen 80;
    server_name $IP_ADDRESS;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $IP_ADDRESS;

    ssl_certificate /etc/nginx/ssl/n8n/server.crt;
    ssl_certificate_key /etc/nginx/ssl/n8n/server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1m;
    client_max_body_size 100m;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

echo "✅ ติดตั้งเสร็จสิ้น!"
echo "🔗 เปิดเบราว์เซอร์ไปที่: https://$IP_ADDRESS"
echo "⚠️ หากขึ้น warning SSL ให้กด Advanced > Proceed"
```

---

จากนั้นให้รันคำสั่งนี้ใน VM:

```bash
curl -sL https://raw.githubusercontent.com/<your-repo>/setup-n8n-gcp.sh | bash -s <YOUR_EXTERNAL_IP>
```

> **หมายเหตุ:** อย่าลืมแทน `<your-repo>` และ `<YOUR_EXTERNAL_IP>` ตามจริง หรือใช้ `chmod +x` รันตรง ๆ บนเครื่องก็ได้
