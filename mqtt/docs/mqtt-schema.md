# 📡 Mini-DC MQTT JSON Schema

## Overview

This document defines the **standard MQTT message schema** for the Mini-DC platform.

The schema is designed to be:

* **Scalable** → รองรับหลาย domain (energy, network, etc.)
* **Flexible** → เพิ่ม metric ใหม่ได้โดยไม่ต้องเปลี่ยน schema
* **Query-friendly** → ใช้งานกับ InfluxDB + Grafana ได้ง่าย
* **AI-ready** → รองรับ analytics / prediction ในอนาคต

---

## 📦 Schema Definition

```json
{
  "ts": 1712500000,
  "metric": "power",
  "value": 1200,
  "unit": "W",
  "quality": "good",
  "source": "modbus",
  "tags": {
    "zone": "zonea",
    "device": "inverter"
  }
}
```

---

## 🧩 Field Description

### 1. `ts` (Timestamp)

* Type: `integer`
* Format: Unix timestamp (seconds)

Represents the time when the measurement was generated.

```json
"ts": 1712500000
```

---

### 2. `metric`

* Type: `string`

Defines the type of measurement.

Examples:

* `power`
* `voltage`
* `current`
* `soc`
* `latency`
* `bandwidth`

```json
"metric": "power"
```

---

### 3. `value`

* Type: `number`

The actual measured value.

```json
"value": 1200
```

---

### 4. `unit`

* Type: `string`

Unit of the measurement.

Examples:

* `W` (watt)
* `V` (volt)
* `%`
* `ms`
* `Mbps`

```json
"unit": "W"
```

---

### 5. `quality` (optional)

* Type: `string`

Indicates data quality.

Examples:

* `good`
* `bad`
* `estimated`
* `offline`

```json
"quality": "good"
```

---

### 6. `source` (optional)

* Type: `string`

Specifies the data source.

Examples:

* `modbus`
* `snmp`
* `api`
* `simulator`

```json
"source": "modbus"
```

---

### 7. `tags`

* Type: `object`

Metadata used for filtering, grouping, and querying.

```json
"tags": {
  "zone": "zonea",
  "device": "inverter"
}
```

#### Common Tags

| Tag       | Description       |
| --------- | ----------------- |
| zone      | Physical location |
| device    | Device name/type  |
| phase     | Electrical phase  |
| interface | Network interface |

---

## 🧠 Design Principles

### 1. Metric-Based Model

Each message contains **one metric per message**.

✅ Good:

```json
{ "metric": "power", "value": 1200 }
```

❌ Bad:

```json
{ "power": 1200, "voltage": 220 }
```

---

### 2. Flat Structure

Avoid deeply nested JSON.

This ensures:

* Better compatibility with Telegraf
* Easier querying in InfluxDB

---

### 3. Tag-Driven Filtering

All dimensions (zone, device, etc.) must be inside `tags`.

This enables:

* Efficient filtering in Grafana
* Clean data modeling

---

## ⚡ Energy Examples

### Inverter Power

```json
{
  "ts": 1712500000,
  "metric": "power",
  "value": 1500,
  "unit": "W",
  "tags": {
    "zone": "zonea",
    "device": "inverter"
  }
}
```

---

### Battery State of Charge

```json
{
  "ts": 1712500000,
  "metric": "soc",
  "value": 85,
  "unit": "%",
  "tags": {
    "zone": "zonea",
    "device": "battery"
  }
}
```

---

## 🌐 Network Examples

### Router Latency

```json
{
  "ts": 1712500000,
  "metric": "latency",
  "value": 12,
  "unit": "ms",
  "tags": {
    "zone": "zonea",
    "device": "router"
  }
}
```

---

### Interface Bandwidth

```json
{
  "ts": 1712500000,
  "metric": "bandwidth",
  "value": 100,
  "unit": "Mbps",
  "tags": {
    "zone": "zonea",
    "device": "router",
    "interface": "eth0"
  }
}
```

---

## 🔄 MQTT Topic Mapping

Example topic:

```
mini-dc/zonea/energy/inverter
```

### Mapping

| Topic Segment | Tag    |
| ------------- | ------ |
| zonea         | zone   |
| energy        | domain |
| inverter      | device |

---

## 📊 InfluxDB Mapping

| JSON Field | InfluxDB |
| ---------- | -------- |
| metric     | _field   |
| value      | _value   |
| ts         | _time    |
| tags.*     | tags     |

---

## 🚀 Future Extensions

The schema supports future additions without breaking compatibility:

* Add new metrics (no schema change)
* Add new tags (e.g., `rack`, `site`)
* Add optional fields:

  * `quality`
  * `source`
  * `metadata`

---

## ✅ Summary

This schema provides:

* ✔ Domain-agnostic design (energy + network)
* ✔ High scalability
* ✔ Clean integration with Telegraf / Influx / Grafana
* ✔ Strong foundation for AI / analytics

---

> 💡 This schema is the **data contract** of the Mini-DC platform.
