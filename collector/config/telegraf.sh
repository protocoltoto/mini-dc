```bash id="zpj91n"
#!/usr/bin/env bash

# ======================================
# GENERATE TELEGRAF CONFIG (SOURCE OF TRUTH)
# ======================================

OUTPUT_FILE="./telegraf.conf"

MQTT_BROKER="tcp://mqtt:1883"
INFLUX_URL="http://influxdb:8086"
INFLUX_TOKEN="mini-dc-token"
INFLUX_ORG="mini-dc"

echo "⚙️ Generating telegraf.conf..."

cat <<EOF > $OUTPUT_FILE

[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  flush_interval = "10s"

# ============================
# MQTT INPUT (JSON)
# ============================
[[inputs.mqtt_consumer]]
  servers = ["${MQTT_BROKER}"]
  topics = [
    "mini-dc/+/energy/+",
    "mini-dc/+/network/+"
  ]
  data_format = "json"

# ============================
# TAG EXTRACTION (FROM TOPIC)
# ============================
[[processors.regex]]

  [[processors.regex.tags]]
    key = "topic"
    pattern = "^mini-dc/([^/]+)/([^/]+)/([^/]+)"
    replacement = "\$1"
    result_key = "zone"

  [[processors.regex.tags]]
    key = "topic"
    pattern = "^mini-dc/([^/]+)/([^/]+)/([^/]+)"
    replacement = "\$2"
    result_key = "domain"

  [[processors.regex.tags]]
    key = "topic"
    pattern = "^mini-dc/([^/]+)/([^/]+)/([^/]+)"
    replacement = "\$3"
    result_key = "device"

# ============================
# NORMALIZE TAG TYPES
# ============================
[[processors.converter]]
  [processors.converter.tags]
    string = ["zone", "domain", "device"]

# ============================
# OUTPUT: ENERGY
# ============================
[[outputs.influxdb_v2]]
  urls = ["${INFLUX_URL}"]
  token = "${INFLUX_TOKEN}"
  organization = "${INFLUX_ORG}"
  bucket = "energy"

  tagpass = { topic = ["mini-dc/*/energy/*"] }

# ============================
# OUTPUT: NETWORK
# ============================
[[outputs.influxdb_v2]]
  urls = ["${INFLUX_URL}"]
  token = "${INFLUX_TOKEN}"
  organization = "${INFLUX_ORG}"
  bucket = "network"

  tagpass = { topic = ["mini-dc/*/network/*"] }

EOF

echo "✅ telegraf.conf generated at: $OUTPUT_FILE"
```
