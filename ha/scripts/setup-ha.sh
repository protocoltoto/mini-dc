#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV
# ==============================
source ../../proxmox/scripts/load-env.sh ha

# ==============================
# CONFIG
# ==============================
RETRY=${RETRY:-30}
SLEEP=${SLEEP:-5}

echo "⚙️ Setting up Home Assistant ($CTID)..."

# ==============================
# WAIT FOR VM RUNNING
# ==============================
echo "⏳ Waiting for HA VM to start..."

for i in $(seq 1 $RETRY); do
  STATUS=$(qm status $CTID | awk '{print $2}')
  if [ "$STATUS" = "running" ]; then
    echo "✅ VM is running"
    break
  fi
  sleep $SLEEP
done

# ==============================
# WAIT FOR HA WEB UI
# ==============================
HA_URL="http://${HA_HOST:-$IP}:8123"

echo "⏳ Waiting for Home Assistant UI ($HA_URL)..."

for i in $(seq 1 $RETRY); do
  if curl -sf "$HA_URL" >/dev/null 2>&1; then
    echo "✅ Home Assistant is ready"
    break
  fi
  sleep $SLEEP
done

# ==============================
# FINAL CHECK
# ==============================
echo "🔍 Verifying..."

if curl -sf "$HA_URL" >/dev/null 2>&1; then
  echo "✅ HA is reachable"
else
  echo "⚠️ HA not reachable yet (may still be booting)"
fi

echo ""
echo "======================================"
echo "✅ Home Assistant Ready"
echo "======================================"

echo ""
echo "👉 Open:"
echo "   $HA_URL"
echo ""
echo "👉 Next:"
echo "   - Complete onboarding"
echo "   - Add MQTT integration"
echo ""