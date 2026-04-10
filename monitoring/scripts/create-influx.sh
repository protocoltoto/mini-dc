```bash
#!/usr/bin/env bash

# ==============================
# CONFIG (LEAN + RETENTION AWARE)
# ==============================
CTID=200
HOSTNAME="influxdb"

CORES=1
MEMORY=1024
DISK="20G"

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

echo "✅ InfluxDB ready"
```
