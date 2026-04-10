```bash
#!/usr/bin/env bash

# ======================================
# GENERIC VM CREATION SCRIPT (LEAN)
# ======================================

set -e

# ==============================
# INPUT PARAMETERS
# ==============================
VMID=$1
NAME=$2

# Optional (defaults)
CORES=${3:-2}
MEMORY=${4:-2048}
DISK_SIZE=${5:-32G}
ISO=${6:-""}

# ==============================
# STATIC CONFIG
# ==============================
STORAGE="local-lvm"
BRIDGE="vmbr0"
OS_TYPE="l26"   # Linux

# ==============================
# VALIDATION
# ==============================
if [ -z "$VMID" ] || [ -z "$NAME" ]; then
  echo "❌ Usage:"
  echo "   $0 <VMID> <NAME> [CORES] [MEMORY_MB] [DISK_SIZE] [ISO]"
  echo ""
  echo "👉 Example:"
  echo "   $0 300 haos 2 4096 32G"
  exit 1
fi

echo "🚀 Creating VM: $NAME (VMID: $VMID)"

# ==============================
# CREATE VM
# ==============================
qm create $VMID \
  --name $NAME \
  --memory $MEMORY \
  --cores $CORES \
  --net0 virtio,bridge=$BRIDGE \
  --ostype $OS_TYPE

# ==============================
# CREATE DISK
# ==============================
qm set $VMID \
  --scsihw virtio-scsi-pci \
  --scsi0 ${STORAGE}:${DISK_SIZE}

# ==============================
# ATTACH ISO (OPTIONAL)
# ==============================
if [ -n "$ISO" ]; then
  echo "📀 Attaching ISO: $ISO"
  qm set $VMID --cdrom $ISO
fi

# ==============================
# BOOT CONFIG
# ==============================
qm set $VMID \
  --boot order=scsi0 \
  --serial0 socket \
  --vga serial0

# ==============================
# START VM
# ==============================
echo "▶️ Starting VM..."
qm start $VMID

# ==============================
# DONE
# ==============================
echo "✅ VM created successfully"
echo "👉 VMID: $VMID"
echo "👉 Name: $NAME"
```
