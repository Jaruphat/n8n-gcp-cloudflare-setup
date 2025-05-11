#!/bin/bash
# setup-n8n-cloudflare.sh - สำหรับ Debian/Ubuntu GCP VM ที่มี n8n ติดตั้งแล้ว

set -e

echo "📦 ติดตั้ง Docker จาก Debian repo..."
sudo apt update -y
sudo apt install -y docker.io

echo "✅ Docker ติดตั้งเรียบร้อยแล้ว"

echo "🧰 ติดตั้ง cloudflared (Cloudflare Tunnel CLI)..."
wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/

echo ""
echo "✅ พร้อมใช้งานแล้ว! รันคำสั่งนี้:"
echo ""
echo "   cloudflared tunnel --url http://localhost:5678"
