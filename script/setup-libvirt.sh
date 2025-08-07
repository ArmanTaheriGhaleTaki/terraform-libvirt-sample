#!/bin/bash

set -e

YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 0. Check if KVM is supported
echo -e "${YELLOW}[+] install cpu-checker for kvm-ok ...${NC}"
sudo apt update
sudo apt install -y cpu-checker

echo -e "${YELLOW}[+] Checking KVM support...${NC}"
if ! kvm-ok > /dev/null 2>&1; then
  echo -e "${YELLOW}[!] KVM is not supported or not enabled in BIOS. Exiting.${NC}"
  exit 1
fi

# 1. Install prerequisites
echo -e "${YELLOW}[+] Installing prerequisites...${NC}"
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system virt-manager

# 2. Create and start the default storage pool if it doesn't exist
POOL_NAME="default"
POOL_PATH="/var/lib/libvirt/images/default"

echo -e "${YELLOW}[+] Checking if storage pool '$POOL_NAME' exists...${NC}"
if ! virsh pool-list --all | grep -q "$POOL_NAME"; then
  echo -e "${YELLOW}[+] Creating storage pool '$POOL_NAME' at $POOL_PATH...${NC}"
  sudo mkdir -p "$POOL_PATH"
  virsh pool-define-as "$POOL_NAME" dir - - - - "$POOL_PATH"
  virsh pool-build "$POOL_NAME"
  virsh pool-start "$POOL_NAME"
  virsh pool-autostart "$POOL_NAME"
else
  echo -e "${YELLOW}[+] Storage pool '$POOL_NAME' already exists.${NC}"
fi

# 3. Set proper permissions for the storage pool path
echo -e "${YELLOW}[+] Setting permissions for $POOL_PATH...${NC}"
sudo chown libvirt-qemu:libvirt-qemu "$POOL_PATH"
sudo chmod 755 "$POOL_PATH"

# 4. Restart libvirtd service
echo -e "${YELLOW}[+] Restarting libvirtd service...${NC}"
sudo systemctl restart libvirtd

# 5. Add current user to the libvirt group
USER_NAME=$(whoami)
echo -e "${YELLOW}[+] Adding user '$USER_NAME' to 'libvirt' group...${NC}"
sudo usermod -aG libvirt "$USER_NAME"

# 6. Download Ubuntu Cloud image if not already downloaded or if corrupted
IMG_NAME="jammy-server-cloudimg-amd64.img"
IMG_URL="https://cloud-images.ubuntu.com/jammy/current/$IMG_NAME"
SHA256SUM_URL="https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"

DOWNLOAD_IMAGE() {
  echo -e "${YELLOW}[+] Downloading Ubuntu image...${NC}"
  wget -O "$IMG_NAME" "$IMG_URL"
}

VERIFY_CHECKSUM() {
  echo -e "${YELLOW}[+] Verifying checksum...${NC}"
  wget -O SHA256SUMS "$SHA256SUM_URL"
  if sha256sum -c --ignore-missing SHA256SUMS; then
    echo -e "${YELLOW}[+] Checksum verification successful.${NC}"
    rm -f SHA256SUMS
    return 0
  else
    echo -e "${YELLOW}[!] Checksum verification failed.${NC}"
    rm -f SHA256SUMS
    return 1
  fi
}

if [ -f "$IMG_NAME" ]; then
  if VERIFY_CHECKSUM; then
    echo -e "${YELLOW}[+] Image '$IMG_NAME' already exists and checksum is valid.${NC}"
  else
    echo -e "${YELLOW}[!] Image exists but checksum verification failed. Re-downloading...${NC}"
    rm -f "$IMG_NAME"
    DOWNLOAD_IMAGE
    VERIFY_CHECKSUM
  fi
else
  DOWNLOAD_IMAGE
  VERIFY_CHECKSUM
fi

# 7. Resize the image by +50G
echo -e "${YELLOW}[+] Resizing image '$IMG_NAME' by +50G...${NC}"
qemu-img resize "$IMG_NAME" +50G

# 8. Show absolute path to use in Terraform variables
ABSOLUTE_PATH=$(readlink -f "$IMG_NAME")
echo -e "${YELLOW}[+] Use this absolute path in your Terraform 'variables.tf':${NC}"
echo "  $ABSOLUTE_PATH"

# 9. Ask user if they want to automatically update variables.tf
echo -e "${YELLOW}[?] Do you want to automatically update 'variables.tf' with this path? (y/N):${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}[+] Updating variables.tf...${NC}"
  # Create a backup of the original file
  cp variables.tf variables.tf.backup
  # Update the default value in variables.tf
  sed -i "s|default     = \".*\"|default     = \"$ABSOLUTE_PATH\"|" variables.tf
  echo -e "${YELLOW}[+] Updated variables.tf with the absolute path.${NC}"
  echo -e "${YELLOW}[+] Original file backed up as variables.tf.backup${NC}"
else
  echo -e "${YELLOW}[+] Skipping automatic update. Please manually update variables.tf with the path above.${NC}"
fi

echo -e "${YELLOW}[+] Done. Please log out and log back in for group membership changes to take effect.${NC}"
