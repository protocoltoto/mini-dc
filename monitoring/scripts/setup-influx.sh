```bash
#!/usr/bin/env bash

CTID=200

echo "⚙️ Configuring InfluxDB buckets..."

pct exec $CTID -- bash -c "

# wait for service
sleep 5

# initial setup (idempotent-safe if rerun carefully)
influx setup \
  --org mini-dc \
  --bucket temp \
  --username admin \
  --password admin123 \
  --token mini-dc-token \
  --force

# create energy bucket (30 days)
influx bucket create \
  --name energy \
  --retention 720h

# create network bucket (14 days)
influx bucket create \
  --name network \
  --retention 336h

# delete temp bucket
influx bucket delete --name temp
"

echo "✅ Buckets created:"
echo "   - energy (30 days)"
echo "   - network (14 days)"
```
