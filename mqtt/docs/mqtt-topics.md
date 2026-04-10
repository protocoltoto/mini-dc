# Mini-DC MQTT Topics Specification

## Overview

This document defines the MQTT topic structure and payload format
used in the Mini-DC platform.

This is the **single source of truth** for all data producers and consumers.

---

## Topic Structure

mini-dc/<zone>/<domain>/<device>

---

## Topic Components

| Component | Description | Example |
|----------|------------|---------|
| prefix   | system identifier | mini-dc |
| zone     | logical location | zonea |
| domain   | data category | energy, network |
| device   | data source | inverter1 |

---

## Domains

### Energy

Used for power-related devices.

Devices include:
- inverter
- battery
- ev charger (future)

---

### Network

Used for network monitoring.

Devices include:
- router
- switch (future)
- access point (future)

---

## Standard Topics

### Energy

mini-dc/<zone>/energy/inverter1  
mini-dc/<zone>/energy/battery1  

---

### Network

mini-dc/<zone>/network/router1  

---

## Payload Format

All payloads MUST be JSON.

---

## Energy Payloads

### Inverter

Topic:
mini-dc/zonea/energy/inverter1

Payload:
{
  "power": 3200,
  "voltage": 230,
  "current": 13.9,
  "temperature": 45
}

---

### Battery

Topic:
mini-dc/zonea/energy/battery1

Payload:
{
  "soc": 85,
  "charge_power": 1200,
  "discharge_power": 0,
  "temperature": 30
}

---

## Network Payloads

### Router

Topic:
mini-dc/zonea/network/router1

Payload:
{
  "latency": 12,
  "throughput": 85,
  "packet_loss": 0.1,
  "uptime": 123456
}

---

## Field Naming Rules

- lowercase only
- no spaces
- use underscore (_) if needed
- numeric values preferred

---

## Examples

✔ correct:

{
  "power": 3200,
  "voltage": 230
}

✘ incorrect:

{
  "Power": "3200W",
  "Voltage Level": "230V"
}

---

## Message Frequency Guidelines

| Domain  | Interval |
|--------|----------|
| energy | 5–10 seconds |
| network| 5–10 seconds |

---

## QoS Recommendation

- QoS: 0 or 1 (depending on reliability needs)
- Retain: false (default)

---

## Topic Usage Rules

### 1. Topic = Identity

Each topic represents a device, not a metric.

✔ correct:
mini-dc/zonea/energy/inverter1

✘ incorrect:
mini-dc/zonea/energy/power

---

### 2. Payload = State Snapshot

Each message should include multiple related metrics.

---

### 3. No Mixed Formats

Do NOT mix:

- JSON
- raw values

All topics must use JSON.

---

### 4. Consistency is Mandatory

All producers must follow:

- same topic structure
- same field naming
- same data types

---

## Reserved Topics (Future)

These topics are reserved for future use:

mini-dc/<zone>/control/<device>  
mini-dc/<zone>/alert/<device>  

---

## Extension Guidelines

New devices must follow:

mini-dc/<zone>/<domain>/<device>

Examples:

mini-dc/zoneb/energy/inverter1  
mini-dc/zonea/network/switch1  
mini-dc/zonea/energy/evcharger1  

---

## Anti-Patterns

### 1. Using metric in topic

✘ mini-dc/zonea/energy/power  

---

### 2. Inconsistent casing

✘ mini-dc/ZoneA/Energy/Inverter  

---

### 3. String-based metrics

✘ { "status": "ON" }

✔ { "status": 1 }

---

### 4. Overloading topics

✘ putting multiple devices in one topic  

---

## Summary

Mini-DC MQTT design:

- device-based topics
- JSON payloads
- consistent naming
- domain-based routing

This enables:

- clean ingestion (Telegraf)
- efficient storage (InfluxDB)
- flexible visualization (Grafana)
- future AI integration