#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV
# ==============================
set -a
source ../../proxmox/scripts/load-env.sh influxdb
set +a

echo "⚙️ Configuring InfluxDB..."

pct exec $CTID -- bash -c "
set -e

# ==============================
# WAIT FOR INFLUX READY
# ==============================
echo '⏳ Waiting for InfluxDB...'
until influx ping >/dev/null 2>&1; do
  sleep 2
done

echo '✅ InfluxDB is ready'

# ==============================
# CHECK IF ALREADY INITIALIZED
# ==============================
if influx auth list >/dev/null 2>&1; then
  echo '⚠️ InfluxDB already initialized, skipping setup'
else
  echo '🚀 Running initial setup...'

  influx setup \
    --org ${INFLUX_ORG} \
    --bucket temp \
    --username ${INFLUX_USERNAME} \
    --password ${INFLUX_PASSWORD} \
    --token ${INFLUX_TOKEN} \
    --force
fi

# ==============================
# CREATE BUCKETS (DYNAMIC)
# ==============================
IFS=',' read -ra BUCKETS <<< \"${INFLUX_BUCKETS}\"

for BUCKET in \"\${BUCKETS[@]}\"; do

  if [ \"\$BUCKET\" = \"energy\" ]; then
    RET=\"${INFLUX_RETENTION_ENERGY}\"
  elif [ \"\$BUCKET\" = \"network\" ]; then
    RET=\"${INFLUX_RETENTION_NETWORK}\"
  else
    RET=\"0\"
  fi

  echo \"📦 Ensuring bucket: \$BUCKET (retention=\$RET)\"

  if influx bucket find --name \"\$BUCKET\" >/dev/null 2>&1; then
    echo \" - exists, skip\"
  else
    influx bucket create \
      --name \"\$BUCKET\" \
      --org ${INFLUX_ORG} \
      --retention \"\$RET\"
  fi
done

# ==============================
# CLEANUP TEMP BUCKET
# ==============================
if influx bucket find --name temp >/dev/null 2>&1; then
  influx bucket delete --name temp
fi

echo '✅ InfluxDB setup complete'
"

echo "✅ Buckets configured:"
IFS=',' read -ra BUCKETS <<< "$INFLUX_BUCKETS"
for B in "${BUCKETS[@]}"; do
  echo " - $B"
done