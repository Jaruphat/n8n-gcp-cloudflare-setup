## ติดตั้ง Cloudflare Tunnel เพื่อให้ n8n ใช้งาน HTTPS ได้บน GCP VM (ไม่มีโดเมนก็ใช้ได้)

### 📌 Prerequisites / ข้อกำหนดเบื้องต้น
ก่อนเริ่มใช้งาน คุณต้องเตรียมสิ่งต่อไปนี้ให้พร้อม:
- ✅ มี VM instance ที่ติดตั้ง `n8n` แล้ว (เข้าผ่าน http://your-external-ip/n8n ได้)
- ✅ ระบบปฏิบัติการ Ubuntu 20.04 หรือ 22.04 LTS
- ✅ เชื่อมต่ออินเทอร์เน็ตได้ และสามารถติดตั้งแพ็กเกจผ่าน apt
- ❌ **ไม่ต้องมีโดเมน ไม่ต้องเปิดพอร์ต**
---
### 📌 ขั้นตอนติดตั้ง Cloudflare Tunnel (ภาษาไทย)

### ขั้นตอนที่ 1: SSH เข้าไปใน VM
```bash
gcloud compute ssh [YOUR_VM_NAME] --zone=[YOUR_ZONE]
```
หรือเข้าผ่าน SSH ผ่าน GCP
### ขั้นตอนที่ 2: ดาวน์โหลดและรันสคริปต์ติดตั้ง

```bash
curl -O https://raw.githubusercontent.com/Jaruphat/n8n-gcp-cloudflare-setup/main/setup-n8n-cloudflare.sh
chmod +x setup-n8n-cloudflare.sh
./setup-n8n-cloudflare.sh
```

### ขั้นตอนที่ 3: รันคำสั่งเพื่อเปิด Tunnel

```bash
cloudflared tunnel --url http://localhost:5678
```

จะได้ลิงก์ HTTPS เช่น `https://n8n-yourname.trycloudflare.com`  
สามารถใช้เปิด `n8n` ได้ผ่านเบราว์เซอร์ พร้อมใช้งาน webhook ได้ทันที

---

### 🌍 Cloudflare Tunnel Setup for n8n (English)

### Step 1: SSH into your GCP VM

```bash
gcloud compute ssh [YOUR_VM_NAME] --zone=[YOUR_ZONE]
```

### Step 2: Download and run setup script

```bash
curl -O https://raw.githubusercontent.com/your-username/n8n-cloudflare-https/main/setup-n8n-cloudflare.sh
chmod +x setup-n8n-cloudflare.sh
./setup-n8n-cloudflare.sh
```

### Step 3: Start the public tunnel

```bash
cloudflared tunnel --url http://localhost:5678
```

You’ll get a public HTTPS link like `https://n8n-yourname.trycloudflare.com` that you can use to access your n8n dashboard securely.

---

### Script ติดตั้งอัตโนมัติ (1-click install script)
อยู่ในไฟล์ `setup-n8n-cloudflare.sh` ใน repository นี้
