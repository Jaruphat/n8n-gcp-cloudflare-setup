#!/bin/bash
# setup-n8n-cloudflare.sh - สำหรับ Debian/Ubuntu VM ที่มี n8n ติดตั้งแล้ว

set -e

echo "📦 ติดตั้ง Docker (จาก repo ของ Debian)..."
sudo apt update -y
sudo apt install -y docker.io

echo "✅ Docker ติดตั้งเรียบร้อยแล้ว"

echo "🧰 ติดตั้ง cloudflared (Cloudflare Tunnel CLI)..."
wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/

echo ""
echo "✅ พร้อมใช้งานแล้ว!"
echo "➡️ รันคำสั่งนี้เพื่อเปิดลิงก์ HTTPS ให้กับ n8n:"
echo ""
echo "   cloudflared tunnel --url http://localhost:5678"
echo ""
echo "ระบบจะสร้างลิงก์เช่น https://xxx.trycloudflare.com"
