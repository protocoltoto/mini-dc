#!/usr/bin/env bash
set -e

# ==============================
# LOAD ENV (STANDARD WAY)
# ==============================
source ../../proxmox/scripts/load-env.sh ha

echo "🚀 Creating Home Assistant OS VM ($CTID)..."

# ==============================
# VALIDATE
# ==============================
: "${CTID:?missing}"
: "${HOSTNAME:?missing}"
: "${STORAGE:?missing}"

CORES=${CORES:-2}
MEMORY=${MEMORY:-2048}
DISK=${DISK:-32G}
BRIDGE=${BRIDGE:-vmbr0}

# ==============================
# CHECK EXIST
# ==============================
if qm status $CTID >/dev/null 2>&1; then
  echo "⚠️ VM $CTID already exists, skipping"
  exit 0
fi

# ==============================
# DOWNLOAD IMAGE
# ==============================
TMP_DIR="/tmp/haos"
mkdir -p "$TMP_DIR"

IMAGE="$TMP_DIR/haos.qcow2.xz"

if [ ! -f "$IMAGE" ]; then
  echo "📥 Downloading HAOS image..."
  curl -L -o "$IMAGE" \
    https://github.com/home-assistant/operating-system/releases/latest/download/haos_ova.qcow2.xz
fi

echo "📦 Extracting image..."
unxz -f "$IMAGE"

QCOW2="${IMAGE%.xz}"

# ==============================
# CREATE VM
# ==============================
qm create $CTID \
  --name $HOSTNAME \
  --memory $MEMORY \
  --cores $CORES \
  --net0 virtio,bridge=$BRIDGE

# ==============================
# IMPORT DISK
# ==============================
qm importdisk $CTID "$QCOW2" $STORAGE

qm set $CTID \
  --scsihw virtio-scsi-pci \
  --scsi0 $STORAGE:vm-$CTID-disk-0 \
  --boot c \
  --bootdisk scsi0

# ==============================
# FEATURES
# ==============================
qm set $CTID \
  --agent enabled=1 \
  --serial0 socket \
  --vga serial0

# ==============================
# START
# ==============================
qm start $CTID

echo "✅ HAOS VM ready"