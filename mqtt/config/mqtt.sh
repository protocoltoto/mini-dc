```bash
#!/usr/bin/env bash

# ======================================
# MINI-DC MQTT BOOTSTRAP / TEST SCRIPT
# ======================================

MQTT_HOST="localhost"
MQTT_PORT="1883"

# ==============================
# FUNCTION: publish JSON
# ==============================
publish() {
  local topic=$1
  local payload=$2

  echo "📡 Publishing → $topic"
  mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t "$topic" -m "$payload"
}

# ==============================
# ENERGY: INVERTER
# ==============================
publish "mini-dc/zonea/energy/inverter1" '{
  "power": 3200,
  "voltage": 230,
  "current": 13.9,
  "temperature": 45
}'

# ==============================
# ENERGY: BATTERY
# ==============================
publish "mini-dc/zonea/energy/battery1" '{
  "soc": 85,
  "charge_power": 1200,
  "discharge_power": 0,
  "temperature": 30
}'

# ==============================
# NETWORK: ROUTER
# ==============================
publish "mini-dc/zonea/network/router1" '{
  "latency": 12,
  "throughput": 85,
  "packet_loss": 0.1,
  "uptime": 123456
}'

echo "✅ MQTT test data published"
```
