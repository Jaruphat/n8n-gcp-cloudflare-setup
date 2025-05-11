# 🌐 ติดตั้ง Cloudflare Tunnel เพื่อให้ n8n ใช้งาน HTTPS ได้บน GCP VM (ไม่มีโดเมนก็ใช้ได้)

## 📌 Prerequisites / ข้อกำหนดเบื้องต้น

ก่อนเริ่มใช้งาน คุณต้องเตรียมสิ่งต่อไปนี้ให้พร้อม:

* ✅ มี VM instance ที่ติดตั้ง `n8n` แล้ว (เข้าผ่าน [http://your-external-ip/n8n](http://your-external-ip/n8n) ได้)
* ✅ ระบบปฏิบัติการ Ubuntu 20.04 / 22.04 หรือ Debian 12
* ✅ เชื่อมต่ออินเทอร์เน็ตได้ และสามารถติดตั้งแพ็กเกจผ่าน apt
* ❌ **ไม่ต้องมีโดเมน ไม่ต้องเปิดพอร์ต**

---

## ✅ STEP 1: SSH เข้าไปใน VM

```bash
gcloud compute ssh [YOUR_VM_NAME] --zone=[YOUR_ZONE]
```

หรือเข้าผ่าน SSH ผ่าน GCP

---

## ✅ STEP 2: ติดตั้ง Docker + cloudflared ด้วยตนเอง

### ติดตั้ง Docker

```bash
sudo apt update -y
sudo apt install -y docker.io
```

### ติดตั้ง cloudflared (Cloudflare Tunnel CLI)

```bash
wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

---

## ✅ STEP 3: Login กับ Cloudflare (ครั้งแรก)

```bash
cloudflared login
```

ระบบจะขึ้นลิงก์ → copy ไปเปิดในเบราว์เซอร์เครื่องคุณ แล้วอนุญาตให้ใช้งานบัญชี Cloudflare

---

## ✅ STEP 4: สร้าง Tunnel แบบมีชื่อ

```bash
cloudflared tunnel create n8n-gcp
```

จะได้ไฟล์ `~/.cloudflared/n8n-gcp.json`

---

## ✅ STEP 5: สร้าง config.yaml สำหรับ Tunnel

```bash
nano ~/.cloudflared/config.yaml
```

วางเนื้อหานี้:

```yaml
tunnel: n8n-gcp
credentials-file: /home/ubuntu/.cloudflared/n8n-gcp.json

ingress:
  - hostname: n8n-yourname.cfargotunnel.com
    service: http://localhost:5678
  - service: http_status:404
```

> เปลี่ยน `ubuntu` และ `yourname` ตามที่ใช้จริง

---

## ✅ STEP 6: ขอใช้โดเมนฟรีจาก Cloudflare (cfargotunnel.com)

```bash
cloudflared tunnel route dns n8n-gcp n8n-yourname.cfargotunnel.com
```

---

## ✅ STEP 7: รัน Tunnel แบบถาวร

```bash
cloudflared tunnel run n8n-gcp
```

หรือติดตั้งเป็น background service:

```bash
sudo cloudflared service install
```

---

## ✅ STEP 8: ตั้งค่าตัวแปรใน n8n ให้รู้จักลิงก์ HTTPS

```env
WEBHOOK_URL=https://n8n-yourname.cfargotunnel.com/
N8N_HOST=n8n-yourname.cfargotunnel.com
N8N_PROTOCOL=https
```

จากนั้น:

```bash
docker compose down && docker compose up -d
```

---

## ✅ STEP 9: เริ่มใช้งาน Webhook ได้ทันที

```
https://n8n-yourname.cfargotunnel.com/webhook/...
```

---

## 🎉 เสร็จสมบูรณ์!

* ได้ HTTPS ฟรี ใช้งาน Webhook จริงได้
* ลิงก์ไม่เปลี่ยนหลังรีบูต VM
* ไม่ต้องจดโดเมนหรือเปิดพอร์ตเลย

---

## 🌍 Cloudflare Tunnel Setup for n8n (English)

### Step 1: SSH into your GCP VM

```bash
gcloud compute ssh [YOUR_VM_NAME] --zone=[YOUR_ZONE]
```

### Step 2: Install Docker + cloudflared manually

#### Install Docker

```bash
sudo apt update -y
sudo apt install -y docker.io
```

#### Install cloudflared

```bash
wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

### Step 3: Log into Cloudflare and create tunnel

```bash
cloudflared login
cloudflared tunnel create n8n-gcp
```

### Step 4: Create config.yaml

```yaml
tunnel: n8n-gcp
credentials-file: /home/ubuntu/.cloudflared/n8n-gcp.json

ingress:
  - hostname: n8n-yourname.cfargotunnel.com
    service: http://localhost:5678
  - service: http_status:404
```

### Step 5: Register your subdomain

```bash
cloudflared tunnel route dns n8n-gcp n8n-yourname.cfargotunnel.com
```

### Step 6: Run tunnel

```bash
cloudflared tunnel run n8n-gcp
```

### Step 7: Configure n8n environment

```env
WEBHOOK_URL=https://n8n-yourname.cfargotunnel.com/
N8N_HOST=n8n-yourname.cfargotunnel.com
N8N_PROTOCOL=https
```

Restart docker:

```bash
docker compose down && docker compose up -d
```

Then access your webhook via:

```
https://n8n-yourname.cfargotunnel.com/webhook/...
```

---

## 🧰 ติดตั้งแบบ 1-click อยู่ในไฟล์ `setup-n8n-cloudflare.sh` ใน repo นี้
