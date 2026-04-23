#!/usr/bin/env bash
set -euox pipefail

trap 'exit 130' INT

DEVICE="foton"
ISO_PATH=""
USER_DATA_PATH=""
QEMU_ARGS=()

usage() {
  cat << EOF
Usage: launch.sh [OPTIONS]

Launch an Ubuntu QEMU virtual machine for testing 'autoinstall' configuration.

Options: 
  -h, --help         Display this help message
  --device NAME      Specify the device name (default: foton)
  --iso PATH         Path to the system installation ISO
  --userdata PATH    Path to the user-data file

Example:
  launch.sh --device foton --iso /path/to/ubuntu.iso --userdata /path/to/user-data.yaml

EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage ; exit 0 ;;
    --device)
      DEVICE="$2"; shift 2 ;;
    --iso)
      ISO_PATH="$2"; shift 2 ;;
    --userdata)
      USER_DATA_PATH="$2"; shift 2 ;;
  esac
done

CACHE_DIR="${PWD}/.cache/${DEVICE}"

# Setting up cache directory
mkdir -p "${CACHE_DIR}"

# Generate seed disk
touch "${CACHE_DIR}/meta-data"
cp "${USER_DATA_PATH}" "${CACHE_DIR}/user-data"
cloud-localds "${CACHE_DIR}/seed.img" "${CACHE_DIR}/user-data" "${CACHE_DIR}/meta-data"

# Create VM disk image
qemu-img create -f qcow2 "${CACHE_DIR}/disk.img" 100G

# Copy OVMF firmware files
cp /usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_VARS_4M.fd "${CACHE_DIR}"

# Run QEMU
QEMU_ARGS=(
  -accel kvm
  -machine q35
  -cpu host
  -smp 4
  -m 8G
  -cdrom "${ISO_PATH}"
  -device virtio-scsi-pci,id=scsi0
  -device scsi-cd,drive=seed,bus=scsi0.0
  -drive if=pflash,format=raw,readonly=on,file="${CACHE_DIR}/OVMF_CODE_4M.fd"
  -drive if=pflash,format=raw,file="${CACHE_DIR}/OVMF_VARS_4M.fd"
  -drive file="${CACHE_DIR}/seed.img",format=raw,cache=none,if=none,id=seed
  -drive file="${CACHE_DIR}/disk.img",format=qcow2,cache=none,if=none,id=disk0
  -nic user,model=virtio-net-pci
  -vga std
)

# Manage disk interface based on device
if [ $DEVICE == "foton" ] || [ $DEVICE == "buran" ]; then
  QEMU_ARGS+=(
    -device nvme,drive=disk0,serial=disk0
  )
else
  QEMU_ARGS+=(
    -device scsi-hd,drive=disk0,bus=scsi0.0
  )
fi

exec /usr/bin/qemu-system-amd64 "${QEMU_ARGS[@]}" || exit $? 