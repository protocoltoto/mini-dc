```bash
#!/usr/bin/env bash

set -euo pipefail

# ======================================
# MINI-DC INSTALLER (PRODUCTION READY)
# ======================================

echo "======================================"
echo "🚀 Mini-DC Installation Started"
echo "======================================"

# ==============================
# GLOBAL CONFIG
# ==============================
RETRY=10
SLEEP=3

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

  for i in $(seq 1 $RETRY); do
    if curl -sf "$url" >/dev/null 2>&1; then
      echo "✅ $name is ready"
      return 0
    fi
    sleep $SLEEP
  done

  fail "$name not reachable: $url"
}

run() {
  local name=$1
  shift
  log "$name"
  "$@"
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
run "Step 1: Create MQTT" \
  bash mqtt/scripts/create-mqtt.sh

run "Step 1: Setup MQTT" \
  bash mqtt/scripts/setup-mqtt.sh

# ==============================
# STEP 2: INFLUXDB
# ==============================
run "Step 2: Create InfluxDB" \
  bash monitoring/scripts/create-influx.sh

wait_for_http "InfluxDB" "http://influxdb:8086"

run "Step 2: Setup InfluxDB" \
  bash monitoring/scripts/setup-influx.sh

# ==============================
# STEP 3: GRAFANA
# ==============================
run "Step 3: Create Grafana" \
  bash monitoring/scripts/create-grafana.sh

wait_for_http "Grafana" "http://grafana:3000"

run "Step 3: Setup Grafana" \
  bash monitoring/scripts/setup-grafana.sh

# ==============================
# STEP 4: TELEGRAF
# ==============================
run "Step 4: Create Telegraf" \
  bash collector/scripts/create-telegraf.sh

run "Step 4: Setup Telegraf" \
  bash collector/scripts/setup-telegraf.sh

# ==============================
# STEP 5: HOME ASSISTANT OS
# ==============================
run "Step 5: Create HAOS VM" \
  bash proxmox/scripts/create-haos.sh

# ==============================
# FINAL CHECK
# ==============================
log "Final Checks"

echo "👉 Verifying services..."

echo "- InfluxDB:"
curl -sf http://influxdb:8086 && echo "  OK" || echo "  FAILED"

echo "- Grafana:"
curl -sf http://grafana:3000 && echo "  OK" || echo "  FAILED"

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
echo "   - Run mqtt/config/mqtt.sh (test data)"
echo "   - Open Grafana dashboards"
echo ""
```
