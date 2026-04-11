#!/usr/bin/env bash
set -euo pipefail

# ======================================
# MINI-DC INSTALLER (LEAN + PRODUCTION)
# ======================================

echo "======================================"
echo "🚀 Mini-DC Installation Started"
echo "======================================"

# ==============================
# GLOBAL CONFIG
# ==============================
RETRY=${RETRY:-10}
SLEEP=${SLEEP:-3}
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# ==============================
# UTILS
# ==============================
log() {
  echo ""
  echo "--------------------------------------"
  echo "🔧 $1"
  echo "--------------------------------------"
}

fail() {
  echo "❌ ERROR: $1"
  exit 1
}

check_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 not found"
}

wait_for_http() {
  local name=$1
  local url=$2

  echo "⏳ Waiting for $name ($url)..."

  for i in $(seq 1 "$RETRY"); do
    if curl -sf "$url" >/dev/null 2>&1; then
      echo "✅ $name is ready"
      return 0
    fi
    sleep "$SLEEP"
  done

  fail "$name not reachable: $url"
}

run() {
  local name=$1
  shift
  log "$name"
  "$@"
}

svc() {
  local service=$1
  local action=$2

  bash "$BASE_DIR/$service/scripts/$action.sh"
}

# ==============================
# PRE-CHECK
# ==============================
log "Pre-check"

check_cmd pct
check_cmd qm
check_cmd curl

echo "✅ Environment OK"

# ==============================
# STEP 1: MQTT
# ==============================
run "Step 1: MQTT - Create" svc mqtt create
run "Step 1: MQTT - Setup"  svc mqtt setup

# ==============================
# STEP 2: INFLUXDB
# ==============================
run "Step 2: InfluxDB - Create" svc influxdb create

wait_for_http "InfluxDB" "http://influxdb:8086"

run "Step 2: InfluxDB - Setup" svc influxdb setup

# ==============================
# STEP 3: GRAFANA
# ==============================
run "Step 3: Grafana - Create" svc grafana create

wait_for_http "Grafana" "http://grafana:3000"

run "Step 3: Grafana - Setup" svc grafana setup

# ==============================
# STEP 4: TELEGRAF
# ==============================
run "Step 4: Telegraf - Create" svc telegraf create
run "Step 4: Telegraf - Setup"  svc telegraf setup

# ==============================
# STEP 5: HOME ASSISTANT
# ==============================
run "Step 5: HAOS - Create VM" \
  bash "$BASE_DIR/proxmox/scripts/create-haos.sh"

# ==============================
# FINAL CHECK
# ==============================
log "Final Checks"

check_service() {
  local name=$1
  local url=$2

  echo "- $name:"
  if curl -sf "$url" >/dev/null 2>&1; then
    echo "  OK"
  else
    echo "  FAILED"
  fi
}

check_service "InfluxDB" "http://influxdb:8086"
check_service "Grafana"  "http://grafana:3000"

echo ""
echo "======================================"
echo "✅ Mini-DC Installation Complete"
echo "======================================"

echo ""
echo "👉 Services:"
echo "   - InfluxDB : http://<IP>:8086"
echo "   - Grafana  : http://<IP>:3000"
echo "   - HAOS     : http://<IP>:8123"

echo ""
echo "👉 Next:"
echo "   - Publish MQTT test data"
echo "   - Open Grafana dashboards"
echo ""