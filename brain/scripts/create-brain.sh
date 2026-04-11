#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV (STANDARD)
# ==============================
source ../../proxmox/scripts/load-env.sh brain

# ==============================
# CONFIG
# ==============================
BASE_SCRIPT="../../proxmox/scripts/create-lxc.sh"

echo "🚀 Creating Brain LXC ($CTID)..."

# ==============================
# VALIDATE
# ==============================
: "${CTID:?missing}"
: "${HOSTNAME:?missing}"
: "${TEMPLATE:?missing}"
: "${STORAGE:?missing}"
: "${IP:?missing}"
: "${GW:?missing}"

CORES=${CORES:-1}
MEMORY=${MEMORY:-512}
DISK=${DISK:-5G}

# ==============================
# CHECK EXIST
# ==============================
if pct status $CTID >/dev/null 2>&1; then
  echo "⚠️ CTID $CTID already exists, skipping"
  exit 0
fi

# ==============================
# CREATE VIA TEMPLATE
# ==============================
bash $BASE_SCRIPT \
  "$CTID" \
  "$HOSTNAME" \
  "$CORES" \
  "$MEMORY" \
  "$DISK" \
  "$TEMPLATE" \
  "$STORAGE" \
  "$IP" \
  "$GW"

# ==============================
# START CONTAINER
# ==============================
echo "📦 Starting Brain container..."
pct start $CTID

# ==============================
# HEALTH CHECK
# ==============================
echo "🔍 Checking status..."
pct status $CTID

echo "✅ Brain LXC created and running"