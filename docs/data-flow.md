# Mini-DC Data Flow

## Overview

This document defines the end-to-end data flow of Mini-DC:

- MQTT topic structure
- Payload format
- Telegraf ingestion and transformation
- InfluxDB storage model

This is the **data contract of the system**.

---

## End-to-End Flow

Device
  ↓
MQTT (mini-dc/... topics)
  ↓
Telegraf (parse + tag + route)
  ↓
InfluxDB (energy / network buckets)
  ↓
Grafana (visualization)

---

## 1. MQTT Layer

### Topic Structure

mini-dc/<zone>/<domain>/<device>

### Definitions

- zone   : logical location (e.g., zonea)
- domain : energy | network
- device : inverter1 | battery1 | router1

---

### Examples

mini-dc/zonea/energy/inverter1  
mini-dc/zonea/energy/battery1  
mini-dc/zonea/network/router1  

---

## 2. Payload Format

All payloads use JSON.

### Energy (Inverter)

Topic:
mini-dc/zonea/energy/inverter1

Payload:
{
  "power": 3200,
  "voltage": 230,
  "current": 13.9
}

---

### Energy (Battery)

Topic:
mini-dc/zonea/energy/battery1

Payload:
{
  "soc": 85,
  "charge_power": 1200,
  "discharge_power": 0
}

---

### Network (Router)

Topic:
mini-dc/zonea/network/router1

Payload:
{
  "latency": 12,
  "throughput": 85,
  "packet_loss": 0.1
}

---

## 3. Telegraf Processing

### Input

Telegraf subscribes to:

mini-dc/+/energy/+  
mini-dc/+/network/+  

### Parsing

- data_format = json
- each JSON key becomes a field

---

### Tag Extraction

From topic:

mini-dc/<zone>/<domain>/<device>

Telegraf extracts:

- zone
- domain
- device

---

### Example (Parsed Metric)

Input:

Topic:
mini-dc/zonea/energy/inverter1

Payload:
{
  "power": 3200
}

Result:

measurement: mqtt_consumer  
tags:
  zone=zonea
  domain=energy
  device=inverter1

fields:
  power=3200

---

## 4. Routing Logic

Telegraf routes data based on topic.

### Energy

Topic match:
mini-dc/*/energy/*

→ bucket: energy

---

### Network

Topic match:
mini-dc/*/network/*

→ bucket: network

---

## 5. InfluxDB Storage Model

### Buckets

| Bucket  | Retention |
|--------|----------|
| energy | 30 days  |
| network| 14 days  |

---

### Measurement

Default measurement:
mqtt_consumer

(You may later customize per device type)

---

### Example Stored Data

energy bucket:

time=...
zone=zonea
device=inverter1

power=3200  
voltage=230  

---

network bucket:

time=...
zone=zonea
device=router1

latency=12  
throughput=85  

---

## 6. Query Model (Grafana / Flux)

### Example: Inverter Power

from(bucket: "energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device == "inverter1")
  |> filter(fn: (r) => r._field == "power")

---

### Example: Network Latency

from(bucket: "network")
  |> range(start: -30m)
  |> filter(fn: (r) => r.device == "router1")
  |> filter(fn: (r) => r._field == "latency")

---

## 7. Design Rules

### 1. Topic = Identity

Topics define:
- where data comes from
- what system it belongs to

---

### 2. Payload = State Snapshot

Each message should represent:

- current state of device
- multiple metrics in one JSON

---

### 3. No Business Logic in Telegraf

Telegraf only:
- parses
- tags
- routes

---

### 4. Numeric Fields Preferred

Good:
{
  "power": 3200
}

Avoid:
{
  "status": "ON"
}

---

### 5. Consistency is Critical

All producers must follow:

- same topic structure
- same JSON schema

---

## 8. Future Extensions

You can extend topics without breaking design:

mini-dc/zoneb/energy/inverter1  
mini-dc/zonea/energy/evcharger1  
mini-dc/zonea/network/switch1  

---

## 9. Summary

Mini-DC data flow is:

- MQTT-centric
- JSON-based
- tag-driven
- bucket-separated

This ensures:

- clean querying
- scalable design
- AI-ready data pipeline