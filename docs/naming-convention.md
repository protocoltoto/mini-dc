# Mini-DC Naming Convention

## Overview

This document defines naming conventions for the Mini-DC platform.

Goals:

- consistency across all components
- readability and predictability
- compatibility with MQTT, InfluxDB, Grafana, and scripts
- future scalability (multi-zone, multi-node)

---

## General Rules

### 1. Use lowercase only

✔ correct:
mini-dc, zonea, inverter1

✘ incorrect:
MiniDC, ZoneA, Inverter1

---

### 2. Use hyphen (-) for separation

✔ correct:
mini-dc, optimize-engine

✘ incorrect:
mini_dc, optimize_engine

---

### 3. No spaces

✔ correct:
weather-predict

✘ incorrect:
weather predict

---

### 4. Keep names short but meaningful

✔ correct:
inverter1, router1

✘ incorrect:
very-long-device-name-abc123

---

## Project-Level Naming

### Repository

mini-dc

---

### Folder Names

| Type | Convention | Example |
|------|----------|---------|
| domain | lowercase | mqtt, collector |
| service | lowercase | influxdb, grafana |
| grouping | plural | scripts, docs |

---

### Script Naming

Pattern:

create-<service>.sh  
setup-<service>.sh  

Examples:

create-influx.sh  
setup-telegraf.sh  
create-grafana.sh  

---

## Infrastructure Naming

### LXC Containers

Pattern:

<service>

Examples:

mqtt  
influxdb  
grafana  
telegraf  

---

### Virtual Machines

Pattern:

<service>

Examples:

haos  

---

### Proxmox IDs

| Type | Range |
|------|------|
| LXC  | 200–299 |
| VM   | 300–399 |

Examples:

200 → influxdb  
201 → grafana  
202 → telegraf  
300 → haos  

---

## MQTT Naming

### Topic Structure

mini-dc/<zone>/<domain>/<device>

---

### Components

| Part | Description | Example |
|------|------------|---------|
| prefix | system name | mini-dc |
| zone | location | zonea |
| domain | category | energy, network |
| device | source | inverter1 |

---

### Examples

mini-dc/zonea/energy/inverter1  
mini-dc/zonea/energy/battery1  
mini-dc/zonea/network/router1  

---

## Device Naming

Pattern:

<type><number>

Examples:

inverter1  
battery1  
router1  

---

### Rules

- no hyphen inside device name
- no uppercase
- numeric suffix required for scaling

---

## InfluxDB Naming

### Buckets

| Domain | Bucket |
|--------|--------|
| energy | energy |
| network| network |

---

### Measurements

Default:

mqtt_consumer

(optional future improvement: per-device-type)

---

### Tags

| Tag | Example |
|-----|--------|
| zone | zonea |
| domain | energy |
| device | inverter1 |

---

### Fields

- lowercase
- descriptive
- numeric values preferred

Examples:

power  
voltage  
current  
latency  
throughput  

---

## Grafana Naming

### Dashboard Names

Pattern:

<domain>-<purpose>

Examples:

energy-overview  
network-health  

---

### Panel Titles

Use human-readable format:

✔ Inverter Power  
✔ Battery State of Charge  

---

## Microservices Naming

### Folder Names

Pattern:

<function>-<type>

Examples:

optimize-engine  
weather-predict  

---

### Service Naming

- match folder name
- kebab-case

---

## Environment Variables

Pattern:

UPPERCASE_WITH_UNDERSCORE

Examples:

MQTT_HOST  
INFLUX_URL  
HA_TOKEN  

---

## File Naming

### Config Files

- lowercase
- hyphen-separated

Examples:

telegraf.conf  
mqtt-topics.md  

---

### Documentation

- lowercase
- hyphen-separated

Examples:

architecture.md  
data-flow.md  
naming-convention.md  

---

## Anti-Patterns (Avoid)

### 1. Mixed naming styles

✘ mini_dc / mini-dc / MiniDC (in same project)

---

### 2. Embedding logic in names

✘ inverter-high-power-1  

---

### 3. Inconsistent topics

✘ mini-dc/zoneA/Energy/Inverter  

---

### 4. Overly long names

✘ mini-dc-zone-a-energy-inverter-main-device  

---

## Summary

Mini-DC naming is:

- lowercase
- hyphen-separated (kebab-case)
- consistent across all layers
- aligned with MQTT + Influx + Grafana

This ensures:

- predictable structure
- easier debugging
- scalable system design