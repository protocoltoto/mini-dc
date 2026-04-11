#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV
# ==============================
set -a
source ../../proxmox/scripts/load-env.sh grafana
set +a

echo "⚙️ Configuring Grafana datasources..."

pct exec $CTID -- bash -c "
set -e

mkdir -p /etc/grafana/provisioning/datasources

cat <<EOF > /etc/grafana/provisioning/datasources/influxdb.yaml
apiVersion: 1

datasources:
EOF
"

# ==============================
# GENERATE DATASOURCES PER BUCKET
# ==============================
IFS=',' read -ra BUCKETS <<< "$INFLUX_BUCKETS"

FIRST=true

for BUCKET in "${BUCKETS[@]}"; do
  NAME="${GRAFANA_DATASOURCE_NAME}-${BUCKET}"

  if [ "$FIRST" = true ]; then
    DEFAULT="true"
    FIRST=false
  else
    DEFAULT="false"
  fi

  pct exec $CTID -- bash -c "cat <<EOF >> /etc/grafana/provisioning/datasources/influxdb.yaml
  - name: ${NAME}
    type: influxdb
    access: proxy
    url: ${INFLUX_URL}
    isDefault: ${DEFAULT}
    jsonData:
      version: Flux
      organization: ${INFLUX_ORG}
      defaultBucket: ${BUCKET}
    secureJsonData:
      token: ${INFLUX_TOKEN}
EOF"
done

# ==============================
# PROVISION DASHBOARD
# ==============================
echo "📊 Provisioning dashboards..."

pct exec $CTID -- bash -c "
mkdir -p /var/lib/grafana/dashboards
mkdir -p /etc/grafana/provisioning/dashboards
"

# copy dashboard files
pct push $CTID ../config/dashboards/energy.json /var/lib/grafana/dashboards/energy.json
pct push $CTID ../config/dashboards/network.json /var/lib/grafana/dashboards/network.json

# copy provisioning config
pct push $CTID ../config/provisioning/dashboards.yamlc

# ==============================
# RESTART GRAFANA
# ==============================
pct exec $CTID -- systemctl restart grafana-server

echo "✅ Grafana datasources configured:"
for BUCKET in "${BUCKETS[@]}"; do
  echo " - ${GRAFANA_DATASOURCE_NAME}-${BUCKET}"
done