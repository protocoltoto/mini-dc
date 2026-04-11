#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV
# ==============================
set -a
source ../../proxmox/scripts/load-env.sh telegraf
set +a

echo "📦 Installing Telegraf..."

pct exec $CTID -- bash -c "
set -e

apt update
apt install -y curl gnupg

curl -fsSL https://repos.influxdata.com/influxdata-archive_compat.key | \
gpg --dearmor -o /usr/share/keyrings/influxdata-archive_compat.gpg

echo 'deb [signed-by=/usr/share/keyrings/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' \
> /etc/apt/sources.list.d/influxdata.list

apt update
apt install -y telegraf
"

echo "⚙️ Generating telegraf.conf..."

pct exec $CTID -- bash -c "
set -e

cat <<EOF > /etc/telegraf/telegraf.conf
[agent]
  interval = \"${INTERVAL}\"
  flush_interval = \"${FLUSH_INTERVAL}\"

# ==============================
# MQTT INPUT
# ==============================
[[inputs.mqtt_consumer]]
  servers = [\"tcp://${MQTT_HOST}:${MQTT_PORT}\"]
  topics = [$(echo $MQTT_TOPICS | sed 's/,/","/g' | sed 's/^/"/;s/$/"/')]
  username = \"${MQTT_USER}\"
  password = \"${MQTT_PASSWORD}\"
  data_format = \"json\"
  topic_tag = \"topic\"

# ==============================
# PARSE TOPIC → TAG
# ==============================
[[processors.regex]]
  namepass = [\"mqtt_consumer\"]

  [[processors.regex.tags]]
    key = \"topic\"
    pattern = \"mini-dc/([^/]+)/([^/]+)/([^/]+)\"
    replacement = \"\${1}\"
    result_key = \"zone\"

  [[processors.regex.tags]]
    key = \"topic\"
    pattern = \"mini-dc/([^/]+)/([^/]+)/([^/]+)\"
    replacement = \"\${2}\"
    result_key = \"domain\"

  [[processors.regex.tags]]
    key = \"topic\"
    pattern = \"mini-dc/([^/]+)/([^/]+)/([^/]+)\"
    replacement = \"\${3}\"
    result_key = \"device\"

# ==============================
# OUTPUT → ENERGY
# ==============================
[[outputs.influxdb_v2]]
  urls = [\"${INFLUX_URL}\"]
  token = \"${INFLUX_TOKEN}\"
  organization = \"${INFLUX_ORG}\"
  bucket = \"${BUCKET_ENERGY}\"

  [outputs.influxdb_v2.tagpass]
    topic = [\"mini-dc/*/energy/*\"]

# ==============================
# OUTPUT → NETWORK
# ==============================
[[outputs.influxdb_v2]]
  urls = [\"${INFLUX_URL}\"]
  token = \"${INFLUX_TOKEN}\"
  organization = \"${INFLUX_ORG}\"
  bucket = \"${BUCKET_NETWORK}\"

  [outputs.influxdb_v2.tagpass]
    topic = [\"mini-dc/*/network/*\"]
EOF
"

echo "🚀 Starting Telegraf..."

pct exec $CTID -- systemctl enable telegraf
pct exec $CTID -- systemctl restart telegraf

# ==============================
# HEALTH CHECK
# ==============================
echo "🔍 Checking Telegraf status..."
pct exec $CTID -- systemctl is-active telegraf

echo "✅ Telegraf ready"
echo "👉 MQTT → Influx pipeline active"