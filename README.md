# Mini-DC

Mini-DC is a lean, MQTT-centric, Infrastructure-as-Code (IaC) platform  
for energy and network observability, automation, and future AI integration.

It is designed to run on a single Proxmox node and provide a modular, reproducible edge data platform.

---
## ☕ Support the Project

If you find Mini-DC useful, consider supporting its development.

Your support helps maintain and improve the platform.

### 💛 Donate

- Buy Me a Coffee: https://buymeacoffee.com/rujji
- PayPal: https://paypal.me/rujji

---

## 🧠 Support in Other Ways

You can also support by:

- ⭐ Starring the repository
- 🍴 Forking and contributing
- 🐛 Reporting issues
- 📢 Sharing the project

---

## Architecture Overview

Devices → MQTT → Telegraf → InfluxDB → Grafana
                          ↓
                       HAOS (Control)
                          ↓
                   Microservices (Future AI)

### Core Principles

- MQTT-first (single data backbone)
- Separation of concerns (data / control / intelligence)
- Lean resource usage (optimized for 16GB RAM systems)
- Fully reproducible via IaC (Proxmox CLI)

---

## Components

Infra         : Proxmox (VM + LXC provisioning)  
Messaging     : MQTT (data transport backbone)  
Ingestion     : Telegraf (data collection + routing)  
Storage       : InfluxDB (time-series database)  
Visualization : Grafana (dashboards)  
Control       : Home Assistant OS  
Intelligence  : Microservices (optimization / prediction)  

---

## Project Structure


>mini-dc/
>├── proxmox/        - IaC (VM + LXC provisioning)
>├── mqtt/           - MQTT broker setup
>├── collector/      - Telegraf (data ingestion)
>├── monitoring/     - InfluxDB + Grafana
>├── ha/             - Home Assistant
>├── microservices/  - Optimization / prediction
>├── docs/           - Architecture + runbook
>└── install.sh      - One-command deployment

---

## Quick Start

### Requirements

- Proxmox VE installed
- Minimum hardware:
  - CPU: Intel i5 (or equivalent)
  - RAM: 16 GB
  - Disk: 1 TB SSD

---

### Clone Repository

git clone <your-repo-url>  
cd mini-dc  

---

### Run Installation

chmod +x install.sh  
./install.sh  

---

## Services

After installation:

- InfluxDB : http://<IP>:8086  
- Grafana  : http://<IP>:3000  
- HAOS     : http://<IP>:8123  

---

## MQTT Topic Design

Base pattern:

mini-dc/{zone}/{domain}/{device}

Examples:

mini-dc/zonea/energy/inverter1  
mini-dc/zonea/energy/battery1  
mini-dc/zonea/network/router1  

---

## Payload Format

### Energy (JSON)

{
  "power": 3200,
  "voltage": 230,
  "current": 13.9
}

### Network (JSON)

{
  "latency": 12,
  "throughput": 85,
  "packet_loss": 0.1
}

---

## Data Flow

MQTT → Telegraf → InfluxDB (energy / network buckets)
                       ↓
                    Grafana

Retention policy:

- Energy  : 30 days  
- Network : 14 days  

---

## IaC Structure

create-lxc.sh → base container provisioning  
create-vm.sh  → base VM provisioning  
create-*.sh   → service installation  
setup-*.sh    → service configuration  

---

## License

This project is licensed for non-commercial use only.

You are free to:
- use
- modify
- fork

You may NOT:
- sell
- use in commercial products or services

See LICENSE file for details.

---

## Roadmap

- Grafana dashboards (energy + network)
- Optimize engine (load balancing / solar optimization)
- Weather prediction service
- Multi-zone / multi-node support

---

## Contributing

This project is designed as a platform blueprint.

You can:
- fork and experiment
- extend microservices
- improve observability

---

## Philosophy

Mini-DC is not just a homelab.

It is:

a modular, observable, and automation-ready edge platform  
designed to operate even without constant human intervention