#!/bin/bash
# ติดตั้ง Docker + cloudflared สำหรับ Debian/Ubuntu GCP VM

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
echo "✅ ติดตั้งสำเร็จ! รันคำสั่งนี้:"
echo ""
echo "   cloudflared tunnel --url http://localhost:5678"
