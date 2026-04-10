#!/bin/bash
set -e

./scripts/create-mqtt.sh

pct start 103

sleep 5

./scripts/setup-mqtt.sh

echo "== ALL DONE =="