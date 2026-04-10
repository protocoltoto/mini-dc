```bash
#!/usr/bin/env bash

# ==============================
# CONFIG
# ==============================
VMID=300
NAME="haos"

CORES=2
MEMORY=4096
DISK_SIZE="40G"

# HAOS IMAGE
HAOS_IMAGE="haos.qcow2"

BASE_SCRIPT="./create-vm.sh"
STORAGE="local-lvm"

# ==============================
# VALIDATION
# ==============================
if [ ! -f "$HAOS_IMAGE" ]; then
  echo "❌ HAOS image not found: $HAOS_IMAGE"
  echo "👉 Download from Home Assistant OS release page"
  exit 1
fi

echo "🚀 Provisioning Home Assistant OS VM..."

# ==============================
# CREATE BASE VM (NO ISO)
# ==============================
bash $BASE_SCRIPT $VMID $NAME $CORES $MEMORY $DISK_SIZE

# ==============================
# IMPORT HAOS DISK
# ==============================
echo "📦 Importing HAOS disk..."

qm importdisk $VMID $HAOS_IMAGE $STORAGE

# Attach imported disk
qm set $VMID \
  --scsihw virtio-scsi-pci \
  --scsi0 ${STORAGE}:vm-${VMID}-disk-0

# ==============================
# BOOT CONFIG (IMPORTANT)
# ==============================
qm set $VMID \
  --boot order=scsi0 \
  --bootdisk scsi0 \
  --agent enabled=1

# ==============================
# OPTIONAL: NETWORK + PERFORMANCE
# ==============================
qm set $VMID \
  --cpu host \
  --memory $MEMORY \
  --cores $CORES

# ==============================
# RESTART VM (ensure correct boot)
# ==============================
echo "🔄 Restarting VM..."
qm stop $VMID
sleep 2
qm start $VMID

# ==============================
# DONE
# ==============================
echo "✅ Home Assistant OS ready"
echo "👉 Access: http://<VM-IP>:8123"
```
