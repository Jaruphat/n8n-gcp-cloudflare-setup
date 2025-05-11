#!/bin/bash
# setup-n8n-cloudflare.sh - ติดตั้ง Cloudflared และเปิด HTTPS ให้ n8n บน GCP VM

set -e

echo "📦 กำลังติดตั้ง Docker (ถ้ายังไม่มี)..."
sudo apt update
sudo apt install -y docker.io curl

echo "🧰 ติดตั้ง cloudflared (Cloudflare Tunnel CLI)..."
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

echo ""
echo "✅ ติดตั้งเสร็จเรียบร้อย!"
echo "➡️ รันคำสั่งนี้เพื่อเปิดลิงก์ HTTPS สำหรับ n8n:"
echo ""
echo "   cloudflared tunnel --url http://localhost:5678"
echo ""
echo "ระบบจะสร้างลิงก์ HTTPS เช่น https://n8n-xxxx.trycloudflare.com"
