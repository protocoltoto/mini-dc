```bash
#!/usr/bin/env bash

# ==============================
# CONFIG (LEAN)
# ==============================
CTID=201
HOSTNAME="grafana"

CORES=1
MEMORY=512
DISK="5G"

BASE_SCRIPT="../../proxmox/scripts/create-lxc.sh"

echo "🚀 Provisioning Grafana LXC..."

# ==============================
# CREATE BASE CONTAINER
# ==============================
bash $BASE_SCRIPT $CTID $HOSTNAME $CORES $MEMORY $DISK

# ==============================
# INSTALL GRAFANA
# ==============================
echo "📦 Installing Grafana..."

pct exec $CTID -- bash -c "
apt update -y
apt install -y curl gnupg apt-transport-https software-properties-common

mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

echo 'deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main' \
> /etc/apt/sources.list.d/grafana.list

apt update -y
apt install -y grafana

systemctl enable grafana-server
systemctl start grafana-server
"

echo "✅ Grafana ready"
```
