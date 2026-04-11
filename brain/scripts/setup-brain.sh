#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV
# ==============================
source ../../proxmox/scripts/load-env.sh brain

echo "📦 Setting up Brain ($CTID)..."

# ==============================
# INSTALL NODE + YARN
# ==============================
echo "⬇️ Installing Node.js & Yarn..."

pct exec $CTID -- bash -c "
set -e

apt update
apt install -y curl gnupg

# NodeSource (Node 18 LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Yarn
npm install -g yarn
"

# ==============================
# PREPARE APP DIR
# ==============================
echo "📁 Preparing app directory..."

pct exec $CTID -- bash -c "
mkdir -p /opt/brain
"

# ==============================
# COPY SOURCE CODE
# ==============================
echo "📤 Deploying brain source..."

pct push $CTID ../src /opt/brain/src -r
pct push $CTID ../package.json /opt/brain/package.json
pct push $CTID ../../env/.env.brain /opt/brain/.env

# ==============================
# INSTALL DEPENDENCIES
# ==============================
echo "📦 Installing dependencies..."

pct exec $CTID -- bash -c "
cd /opt/brain
yarn install
"

# ==============================
# CREATE SYSTEMD SERVICE
# ==============================
echo "⚙️ Creating systemd service..."

pct exec $CTID -- bash -c "
cat <<EOF > /etc/systemd/system/brain.service
[Unit]
Description=Mini-DC Brain Service
After=network.target

[Service]
WorkingDirectory=/opt/brain
ExecStart=/usr/bin/node src/index.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
"

# ==============================
# START SERVICE
# ==============================
echo "🚀 Starting Brain service..."

pct exec $CTID -- bash -c "
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable brain
systemctl restart brain
"

# ==============================
# HEALTH CHECK
# ==============================
echo "🔍 Checking Brain status..."

pct exec $CTID -- systemctl is-active brain

echo ""
echo "======================================"
echo "✅ Brain Service Ready"
echo "======================================"

echo ""
echo "👉 Logs:"
echo "   pct exec $CTID -- journalctl -u brain -f"
echo ""
echo "👉 Status:"
echo "   pct exec $CTID -- systemctl status brain"
echo ""