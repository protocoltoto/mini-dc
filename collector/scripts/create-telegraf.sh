```bash
#!/usr/bin/env bash

# ==============================
# CONFIG (ULTRA LEAN)
# ==============================
CTID=202
HOSTNAME="telegraf"

CORES=1
MEMORY=256
DISK="5G"

BASE_SCRIPT="../../proxmox/scripts/create-lxc.sh"

echo "🚀 Provisioning Telegraf LXC..."

# ==============================
# CREATE BASE CONTAINER
# ==============================
bash $BASE_SCRIPT $CTID $HOSTNAME $CORES $MEMORY $DISK

# ==============================
# INSTALL TELEGRAF
# ==============================
echo "📦 Installing Telegraf..."

pct exec $CTID -- bash -c "
apt update -y
apt install -y curl gnupg

curl -fsSL https://repos.influxdata.com/influxdata-archive_compat.key | \
gpg --dearmor -o /usr/share/keyrings/influxdata-archive_compat.gpg

echo 'deb [signed-by=/usr/share/keyrings/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' \
> /etc/apt/sources.list.d/influxdata.list

apt update -y
apt install -y telegraf

systemctl enable telegraf
"

echo "✅ Telegraf ready"
```
