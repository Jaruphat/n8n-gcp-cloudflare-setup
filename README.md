# 🚀 ติดตั้ง n8n บน GCP VM พร้อม HTTPS ด้วย NGINX + Self-signed SSL (ไม่มีโดเมนก็ใช้ได้)

## 📌 ขั้นตอนทั้งหมด

1. สร้าง VM instance บน Google Cloud
2. ติดตั้ง Docker + Docker Compose
3. รัน n8n ด้วย Docker Compose
4. ติดตั้ง NGINX + SSL สำหรับ HTTPS ด้วย Self-signed Certificate

---

## ✅ STEP 1: สร้าง VM บน GCP

1. เข้า [Google Cloud Console](https://console.cloud.google.com/)
2. ไปที่ **Compute Engine > VM instances**
3. คลิกปุ่ม **Create Instance** แล้วตั้งค่า:

   * Machine: `e2-micro` (Free-tier)
   * OS: Ubuntu 22.04 LTS
   * Firewall: ✅ Allow HTTP / ✅ Allow HTTPS
4. กด Create แล้วรอ VM พร้อมใช้งาน

---

## ✅ STEP 2: ติดตั้ง Docker + Docker Compose

```bash
sudo apt update && sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker
```

ตรวจสอบว่า docker ใช้งานได้:

```bash
docker --version
```

---

## ✅ STEP 3: สร้างไฟล์ `docker-compose.yml` สำหรับ n8n (พร้อม PostgreSQL)

```bash
mkdir n8n && cd n8n
nano docker-compose.yml
```

วางเนื้อหานี้:

```yaml
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
```

จากนั้นรัน:

```bash
docker compose up -d
```

ตรวจสอบว่าใช้งานได้:

```
http://<YOUR_EXTERNAL_IP>:5678
```

---

# 🌐 เพิ่ม HTTPS ด้วย NGINX + Self-Signed SSL

## ✅ STEP 3.5: เริ่มต้น docker-compose

```bash
docker compose up -d
```

เมื่อเรียบร้อยแล้วสามารถเข้าทดสอบได้ที่:

```
http://<YOUR_EXTERNAL_IP>:5678
```

---

## ✅ STEP 4: ติดตั้ง nginx + openssl + certbot (optional)

```bash
sudo apt update && sudo apt install nginx openssl certbot python3-certbot-nginx -y
```

---

## ✅ STEP 5: สร้าง Self-signed SSL Certificate

```bash
sudo mkdir -p /etc/nginx/ssl/n8n

sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/n8n/server.key \
  -out /etc/nginx/ssl/n8n/server.crt \
  -subj "/CN=YOUR_SERVER_IP"
```

> แทน `YOUR_SERVER_IP` เป็น External IP ของ VM

---

## ✅ STEP 6: เขียน nginx config

```bash
sudo nano /etc/nginx/sites-available/n8n
```

```nginx
server {
    listen 80;
    server_name YOUR_SERVER_IP;
    return 301 https://$host:443$request_uri;
}

server {
    listen 443 ssl;
    server_name YOUR_SERVER_IP;

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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## ✅ STEP 7: เปิดใช้ config และ restart nginx

```bash
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## ✅ STEP 7.5: เปิด Firewall Rule สำหรับพอร์ต 443 บน GCP

1. ไปที่ Google Cloud Console → VPC Network → Firewall Rules
2. Create Firewall Rule:

   * Name: `allow-nginx-https`
   * Target: All instances
   * Source IP Ranges: `0.0.0.0/0`
   * Protocols/Ports: `tcp:443`

---

## ✅ STEP 8: ทดสอบการใช้งาน

เข้า URL:

```
https://YOUR_SERVER_IP:443
```

> ถ้า browser ขึ้น Warning ให้คลิก Advanced > Proceed

---

## ✅ STEP 9: ตั้งค่า ENV ให้รองรับ HTTPS

เพิ่มไฟล์ `.env` หรือเพิ่มใน `docker-compose.yml`:

```env
N8N_PROTOCOL=https
N8N_HOST=YOUR_SERVER_IP
N8N_PORT=5678
WEBHOOK_URL=https://YOUR_SERVER_IP:443/
VUE_APP_URL_BASE_API=https://YOUR_SERVER_IP:443/
```

จากนั้น restart:

```bash
docker compose down && docker compose up -d
```

---

## 🚀 พร้อมสำหรับ Let's Encrypt ในอนาคต

เมื่อมีโดเมน สามารถเปิดใช้ SSL ฟรีได้ด้วยคำสั่งนี้:

```bash
sudo certbot --nginx -d yourdomain.com
```

---

## 📊 Summary

| รายละเอียด             | คำอธิบาย                          |
| ---------------------- | --------------------------------- |
| 🔐 HTTPS (self-signed) | ใช้งานได้ทันทีแม้ไม่มีโดเมน       |
| 🧩 NGINX reverse proxy | รองรับ HTTPS บน port 443         |
| 🚀 พร้อม Certbot       | รองรับ Let's Encrypt หากมี domain |
