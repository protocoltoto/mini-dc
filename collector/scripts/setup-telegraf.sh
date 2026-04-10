```bash
#!/usr/bin/env bash

# ==============================
# CONFIG
# ==============================
CTID=202

MQTT_BROKER="tcp://mqtt:1883"
INFLUX_URL="http://influxdb:8086"
INFLUX_TOKEN="mini-dc-token"
INFLUX_ORG="mini-dc"

# ==============================
# APPLY CONFIG
# ==============================
echo "⚙️ Configuring Telegraf (JSON + multi-device)..."

pct exec $CTID -- bash -c "

cat <<EOF > /etc/telegraf/telegraf.conf

[agent]
  interval = \"10s\"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  flush_interval = \"10s\"

# ============================
# MQTT INPUT (JSON)
# ============================
[[inputs.mqtt_consumer]]
  servers = [\"${MQTT_BROKER}\"]
  topics = [
    \"mini-dc/+/energy/+\",   # inverter1, battery1
    \"mini-dc/+/network/+\"   # router1
  ]
  data_format = \"json\"

# ============================
# PROCESSOR: EXTRACT TAGS
# ============================
[[processors.regex]]

  [[processors.regex.tags]]
    key = \"topic\"
    pattern = \"^mini-dc/([^/]+)/([^/]+)/([^/]+)\"
    replacement = \"\$1\"
    result_key = \"zone\"

  [[processors.regex.tags]]
    key = \"topic\"
    pattern = \"^mini-dc/([^/]+)/([^/]+)/([^/]+)\"
    replacement = \"\$2\"
    result_key = \"domain\"

  [[processors.regex.tags]]
    key = \"topic\"
    pattern = \"^mini-dc/([^/]+)/([^/]+)/([^/]+)\"
    replacement = \"\$3\"
    result_key = \"device\"

# ============================
# PROCESSOR: NORMALIZE MEASUREMENT
# ============================
[[processors.converter]]
  [processors.converter.tags]
    string = [\"zone\", \"domain\", \"device\"]

# ============================
# OUTPUT: ENERGY (inverter1, battery1)
# ============================
[[outputs.influxdb_v2]]
  urls = [\"${INFLUX_URL}\"]
  token = \"${INFLUX_TOKEN}\"
  organization = \"${INFLUX_ORG}\"
  bucket = \"energy\"

  tagpass = { topic = [\"mini-dc/*/energy/*\"] }

# ============================
# OUTPUT: NETWORK (router1)
# ============================
[[outputs.influxdb_v2]]
  urls = [\"${INFLUX_URL}\"]
  token = \"${INFLUX_TOKEN}\"
  organization = \"${INFLUX_ORG}\"
  bucket = \"network\"

  tagpass = { topic = [\"mini-dc/*/network/*\"] }

EOF

systemctl restart telegraf
"

# ==============================
# DONE
# ==============================
echo "✅ Telegraf configured (JSON mode)"
echo "👉 Devices supported: inverter1, battery1, router1"
echo "👉 Routing: energy / network buckets"
```
