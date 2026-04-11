#!/usr/bin/env bash

set -a
source ../../proxmox/scripts/load-env.sh grafana
set +a

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
set -e

apt update -y
apt install -y curl gnupg apt-transport-https software-properties-common

mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

echo 'deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main' \
> /etc/apt/sources.list.d/grafana.list

apt update -y
apt install -y grafana

# optional: change port
sed -i 's/^;http_port = .*/http_port = ${GRAFANA_PORT}/' /etc/grafana/grafana.ini

systemctl enable grafana-server
systemctl restart grafana-server
"

echo "✅ Grafana ready at port ${GRAFANA_PORT}"