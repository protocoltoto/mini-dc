#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV
# ==============================
set -a
source ../../proxmox/scripts/load-env.sh telegraf
set +a

# ==============================
# CONFIG
# ==============================
BASE_SCRIPT="../../proxmox/scripts/create-lxc.sh"

echo "🚀 Creating Telegraf LXC ($CTID)..."

# ==============================
# VALIDATE REQUIRED VARS
# ==============================
: "${CTID:?missing}"
: "${HOSTNAME:?missing}"
: "${TEMPLATE:?missing}"
: "${STORAGE:?missing}"
: "${IP:?missing}"
: "${GW:?missing}"

# ==============================
# CREATE VIA TEMPLATE
# ==============================
bash $BASE_SCRIPT \
  "$CTID" \
  "$HOSTNAME" \
  "${CORES:-1}" \
  "${MEMORY:-256}" \
  "${DISK:-4}" \
  "$TEMPLATE" \
  "$STORAGE" \
  "$IP" \
  "$GW"

echo "📦 Starting container..."
pct start $CTID

# ==============================
# BASIC HEALTH CHECK
# ==============================
echo "🔍 Checking container status..."
pct status $CTID

echo "✅ Telegraf LXC created and running"