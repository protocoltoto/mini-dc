```bash id="9krxch"
#!/usr/bin/env bash

set -e

echo "======================================"
echo "🚀 Mini-DC Installation Started"
echo "======================================"

# ==============================
# CHECK REQUIREMENTS
# ==============================
command -v pct >/dev/null 2>&1 || { echo "❌ pct not found"; exit 1; }
command -v qm  >/dev/null 2>&1 || { echo "❌ qm not found"; exit 1; }

echo "✅ Proxmox CLI available"

# ==============================
# STEP 1: MQTT
# ==============================
echo "--------------------------------------"
echo "📡 Step 1: MQTT"
echo "--------------------------------------"

bash mqtt/scripts/create-mqtt.sh
bash mqtt/scripts/setup-mqtt.sh

# ==============================
# STEP 2: INFLUXDB
# ==============================
echo "--------------------------------------"
echo "📊 Step 2: InfluxDB"
echo "--------------------------------------"

bash monitoring/scripts/create-influx.sh
bash monitoring/scripts/setup-influx.sh

# ==============================
# STEP 3: GRAFANA
# ==============================
echo "--------------------------------------"
echo "📈 Step 3: Grafana"
echo "--------------------------------------"

bash monitoring/scripts/create-grafana.sh
bash monitoring/scripts/setup-grafana.sh

# ==============================
# STEP 4: TELEGRAF
# ==============================
echo "--------------------------------------"
echo "📥 Step 4: Telegraf"
echo "--------------------------------------"

bash collector/scripts/create-telegraf.sh
bash collector/scripts/setup-telegraf.sh

# ==============================
# STEP 5: HOME ASSISTANT OS
# ==============================
echo "--------------------------------------"
echo "🏠 Step 5: Home Assistant OS"
echo "--------------------------------------"

bash proxmox/scripts/create-haos.sh

# ==============================
# DONE
# ==============================
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
echo "   - Verify MQTT data flow"
echo "   - Open Grafana dashboards"
echo ""
```
