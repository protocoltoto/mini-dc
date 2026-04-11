#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV
# ==============================
set -a
source ../../proxmox/scripts/load-env.sh mqtt
set +a

echo "📦 Installing MQTT (Mosquitto)..."

pct exec $CTID -- bash -c "
set -e

apt update
apt install -y mosquitto mosquitto-clients
"

# ==============================
# CONFIGURE MQTT
# ==============================
echo "⚙️ Configuring MQTT..."

pct exec $CTID -- bash -c "cat > /etc/mosquitto/mosquitto.conf <<EOF
listener ${MQTT_PORT:-1883}
allow_anonymous ${MQTT_ALLOW_ANON:-false}
password_file /etc/mosquitto/passwd
persistence true
persistence_location /var/lib/mosquitto/
EOF"

# ==============================
# CREATE USER (NON-INTERACTIVE)
# ==============================
echo "👤 Creating MQTT user..."

pct exec $CTID -- bash -c "
mosquitto_passwd -b -c /etc/mosquitto/passwd ${MQTT_USER:-admin} ${MQTT_PASSWORD:-admin123}
"

# ==============================
# ENABLE SERVICE
# ==============================
echo "🚀 Starting MQTT..."

pct exec $CTID -- systemctl enable mosquitto
pct exec $CTID -- systemctl restart mosquitto

echo "✅ MQTT Ready on port ${MQTT_PORT:-1883}"