#!/bin/bash
set -e

source .env

echo "== Installing MQTT =="

pct exec $CTID -- bash -c "
apt update &&
apt install -y mosquitto mosquitto-clients
"

echo "== Configuring MQTT =="

pct exec $CTID -- bash -c "cat > /etc/mosquitto/mosquitto.conf <<EOF
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
persistence true
persistence_location /var/lib/mosquitto/
EOF"

echo "== Creating user =="

pct exec $CTID -- mosquitto_passwd -c /etc/mosquitto/passwd admin

echo "== Enable service =="

pct exec $CTID -- systemctl enable mosquitto
pct exec $CTID -- systemctl restart mosquitto

echo "== MQTT Ready =="