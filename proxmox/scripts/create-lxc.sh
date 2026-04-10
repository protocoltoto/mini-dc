```bash
#!/usr/bin/env bash

# ======================================
# GENERIC LXC CREATION SCRIPT (LEAN)
# ======================================

set -e

# ==============================
# INPUT PARAMETERS
# ==============================
CTID=$1
HOSTNAME=$2

# Optional (with defaults)
CORES=${3:-1}
MEMORY=${4:-512}
DISK_SIZE=${5:-5G}
IP=${6:-dhcp}

# ==============================
# STATIC CONFIG
# ==============================
TEMPLATE="local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
STORAGE="local-lvm"
BRIDGE="vmbr0"

# ==============================
# VALIDATION
# ==============================
if [ -z "$CTID" ] || [ -z "$HOSTNAME" ]; then
  echo "❌ Usage:"
  echo "   $0 <CTID> <HOSTNAME> [CORES] [MEMORY_MB] [DISK_SIZE] [IP]"
  echo ""
  echo "👉 Example:"
  echo "   $0 200 influxdb 1 1024 10G dhcp"
  exit 1
fi

echo "🚀 Creating LXC: $HOSTNAME (CTID: $CTID)"

# ==============================
# CREATE CONTAINER
# ==============================
pct create $CTID $TEMPLATE \
  --hostname $HOSTNAME \
  --cores $CORES \
  --memory $MEMORY \
  --rootfs ${STORAGE}:${DISK_SIZE} \
  --net0 name=eth0,bridge=$BRIDGE,ip=$IP \
  --unprivileged 1

# ==============================
# START CONTAINER
# ==============================
echo "▶️ Starting container..."
pct start $CTID

sleep 3

# ==============================
# BASIC SETUP (LEAN BASE)
# ==============================
echo "⚙️ Applying base setup..."

pct exec $CTID -- bash -c "
apt update -y
apt upgrade -y
apt install -y curl ca-certificates gnupg
"

# ==============================
# DONE
# ==============================
echo "✅ LXC created successfully"
echo "👉 CTID: $CTID"
echo "👉 Hostname: $HOSTNAME"
```
