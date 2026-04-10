# Mini-DC Architecture

## Overview

Mini-DC is a modular, MQTT-centric edge platform designed for:

- Energy observability
- Network observability
- Automation and control
- Future AI-driven optimization

The system is built using Infrastructure-as-Code (IaC) on Proxmox and follows a clean separation of concerns.

---

## High-Level Architecture

[Devices / Sensors]
        ↓
      MQTT
        ↓
    Telegraf
        ↓
    InfluxDB
        ↓
     Grafana

        ↓
 Home Assistant OS
        ↓
 Microservices (AI / Optimization)

---

## Core Layers

### 1. Infrastructure Layer

- Platform: Proxmox VE
- Provisioning: CLI-based IaC scripts

Components:
- LXC containers for services
- VM for Home Assistant OS

Key scripts:
- create-lxc.sh
- create-vm.sh
- create-haos.sh

---

### 2. Messaging Layer

- Technology: MQTT
- Role: Central data backbone

Responsibilities:
- Transport all telemetry data
- Decouple producers and consumers

Topic structure:

mini-dc/<zone>/<domain>/<device>

Examples:

mini-dc/zonea/energy/inverter1  
mini-dc/zonea/energy/battery1  
mini-dc/zonea/network/router1  

---

### 3. Ingestion Layer

- Technology: Telegraf

Responsibilities:
- Subscribe to MQTT topics
- Parse JSON payloads
- Enrich data with tags (zone, domain, device)
- Route data to appropriate storage buckets

Key design:
- No business logic
- Lightweight processing only

---

### 4. Storage Layer

- Technology: InfluxDB (Time-series database)

Data separation:

- energy bucket (retention: 30 days)
- network bucket (retention: 14 days)

Responsibilities:
- Store time-series metrics
- Enforce retention policies
- Provide query interface (Flux)

---

### 5. Visualization Layer

- Technology: Grafana

Responsibilities:
- Query InfluxDB
- Provide dashboards for:
  - energy monitoring
  - network performance
- Enable filtering by:
  - zone
  - device

---

### 6. Control Layer

- Technology: Home Assistant OS

Responsibilities:
- Device abstraction
- Automation rules
- Integration with MQTT

Important principle:
Home Assistant is NOT the system brain.
It executes actions, but does not own decision logic.

---

### 7. Intelligence Layer

- Technology: Microservices

Examples:
- optimize-engine
- weather-predict

Responsibilities:
- Subscribe to MQTT or query InfluxDB
- Perform analysis / prediction
- Publish decisions or trigger actions via Home Assistant API

---

## Data Flow

### Standard Flow

Device → MQTT → Telegraf → InfluxDB → Grafana

### Control Flow

Microservice → Home Assistant → Device

### Extended Flow

Device → MQTT → Telegraf → InfluxDB  
                        ↓  
                  Microservices  
                        ↓  
                Home Assistant  

---

## Data Model

### Topic Structure

mini-dc/<zone>/<domain>/<device>

### Payload Format (JSON)

Energy Example:

{
  "power": 3200,
  "voltage": 230,
  "current": 13.9
}

Network Example:

{
  "latency": 12,
  "throughput": 85,
  "packet_loss": 0.1
}

---

## Tagging Strategy

Tags extracted by Telegraf:

- zone
- domain
- device

Purpose:
- Efficient querying in InfluxDB
- Flexible filtering in Grafana

---

## Design Principles

### 1. MQTT-Centric

All data flows through MQTT to ensure:
- decoupling
- flexibility
- scalability

---

### 2. Separation of Concerns

Each component has a single responsibility:

- MQTT → transport
- Telegraf → ingestion
- InfluxDB → storage
- Grafana → visualization
- Home Assistant → control
- Microservices → intelligence

---

### 3. Lean Infrastructure

Designed for:

- Single node (Proxmox)
- 16 GB RAM baseline
- Minimal resource allocation

---

### 4. IaC First

All components are:

- reproducible
- script-driven
- version-controlled

---

### 5. Future-Ready

Architecture supports:

- AI integration
- multi-zone expansion
- multi-node deployment

---

## Deployment Model

Single-node deployment:

- Proxmox host
  - LXC: MQTT
  - LXC: Telegraf
  - LXC: InfluxDB
  - LXC: Grafana
  - VM: Home Assistant OS

---

## Conclusion

Mini-DC is a modular edge platform that:

- unifies energy and network observability
- enables automation and control
- prepares for AI-driven optimization

It is designed to operate reliably with minimal resources while remaining extensible for future growth.