```bash
#!/usr/bin/env bash

# ==============================
# CONFIG
# ==============================
CTID=201

INFLUX_URL="http://influxdb:8086"
INFLUX_ORG="mini-dc"
INFLUX_BUCKET="energy"
INFLUX_TOKEN="mini-dc-token"

GRAFANA_DATASOURCE_NAME="InfluxDB"

# ==============================
# SETUP DATASOURCE
# ==============================
echo "⚙️ Configuring Grafana datasource..."

pct exec $CTID -- bash -c "

mkdir -p /etc/grafana/provisioning/datasources

cat <<EOF > /etc/grafana/provisioning/datasources/influxdb.yaml
apiVersion: 1

datasources:
  - name: ${GRAFANA_DATASOURCE_NAME}
    type: influxdb
    access: proxy
    url: ${INFLUX_URL}
    isDefault: true
    jsonData:
      version: Flux
      organization: ${INFLUX_ORG}
      defaultBucket: ${INFLUX_BUCKET}
    secureJsonData:
      token: ${INFLUX_TOKEN}
EOF

systemctl restart grafana-server
"

# ==============================
# DONE
# ==============================
echo "✅ Grafana datasource configured"
echo "👉 InfluxDB connected"
```
