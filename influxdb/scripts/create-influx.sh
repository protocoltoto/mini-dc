#!/usr/bin/env bash

set -a
source ../../proxmox/scripts/load-env.sh influxdb
set +a

BASE_SCRIPT="../../proxmox/scripts/create-lxc.sh"

echo "🚀 Provisioning InfluxDB LXC..."

# ==============================
# CREATE BASE CONTAINER
# ==============================
bash $BASE_SCRIPT $CTID $HOSTNAME $CORES $MEMORY $DISK

# ==============================
# INSTALL INFLUXDB
# ==============================
echo "📦 Installing InfluxDB..."

pct exec $CTID -- bash -c "
set -e

apt update -y
apt install -y curl gnupg

curl -fsSL https://repos.influxdata.com/influxdata-archive_compat.key | \
gpg --dearmor -o /usr/share/keyrings/influxdata-archive_compat.gpg

echo 'deb [signed-by=/usr/share/keyrings/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' \
> /etc/apt/sources.list.d/influxdata.list

apt update -y
apt install -y influxdb2

systemctl enable influxdb
systemctl start influxdb
"

echo "✅ InfluxDB ready at port ${INFLUX_PORT}"