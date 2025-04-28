#!/bin/bash
set -e

# Constants
MOUNTDIR="./mnt"
ISODIR="./extract-cd"
NEWIMAGENAME="ubuntu-16.04.6-estonian-remix"
NEWIMAGENAME_LABEL="UBUNTU1604ESTONIA" # Used in ISO label
WORKDIR="./work"
CHROOTDIR="./edit"
SOURCEMOUNT="./iso"
OUTPUT_FILE="custom-ubuntu.iso"
ISOFILE="$1"

if [[ -z "$ISOFILE" ]]; then
    echo "Usage: $0 <path-to-iso>"
    exit 1
fi

# Ensure required tools are installed
for tool in squashfs-tools genisoimage syslinux-utils xorriso; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Missing required tool: $tool"
        exit 1
    fi
done

# Clean up previous work
echo "[*] Cleaning previous working directories if they exist..."
sudo umount "${MOUNTDIR}/dev" || true
sudo umount "${MOUNTDIR}/proc" || true
sudo umount "${MOUNTDIR}/sys" || true
sudo rm -rf "$WORKDIR" "$MOUNTDIR" "$ISODIR" "$CHROOTDIR" custom-ubuntu.iso

mkdir -p "$MOUNTDIR" "$ISODIR" "$WORKDIR" "$CHROOTDIR" "$SOURCEMOUNT"

# Mount original ISO
echo "[*] Mounting original ISO..."
sudo mount -o loop "$ISOFILE" "$SOURCEMOUNT"

# Copy ISO contents
echo "[*] Copying ISO contents..."
rsync --exclude=/casper/filesystem.squashfs -a "$SOURCEMOUNT/" "$ISODIR"

# Extract filesystem
echo "[*] Extracting filesystem.squashfs..."
unsquashfs -d "$CHROOTDIR" "$SOURCEMOUNT/casper/filesystem.squashfs"

# Mount special filesystems
echo "[*] Mounting special filesystems in chroot..."
sudo mount --bind /dev "$CHROOTDIR/dev"
sudo mount --bind /run "$CHROOTDIR/run"
sudo mount -t proc /proc "$CHROOTDIR/proc"
sudo mount -t sysfs /sys "$CHROOTDIR/sys"

# Prepare chroot environment
echo "[*] Copying DNS info..."
sudo cp /etc/resolv.conf "$CHROOTDIR/etc/"

# Chroot and customize
echo "[*] Entering chroot for customization..."
cat << 'EOT' | sudo chroot "$CHROOTDIR" /bin/bash
export HOME=/root
export LC_ALL=C

echo "[*] Updating package lists..."
apt update

# Install Estonian language packs
echo "[*] Installing Estonian language packs..."
apt install -y language-pack-et language-pack-gnome-et myspell-et thunderbird-locale-et libreoffice-l10n-et

# Set Estonian as default language
echo "[*] Setting Estonian as default language..."
echo "et_EE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen et_EE.UTF-8
update-locale LANG=et_EE.UTF-8

# Set timezone to Tallinn
echo "[*] Setting timezone to Europe/Tallinn..."
ln -sf /usr/share/zoneinfo/Europe/Tallinn /etc/localtime
echo "Europe/Tallinn" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Cleanup
echo "[*] Cleaning up inside chroot..."
apt clean
apt autoremove -y
rm -rf /tmp/* ~/.bash_history

# Exit chroot
exit
EOT

# Cleanup mounts
echo "[*] Cleaning up special mounts..."
sudo umount "$CHROOTDIR/dev"
sudo umount "$CHROOTDIR/proc"
sudo umount "$CHROOTDIR/sys"
sudo umount "$CHROOTDIR/run"

# Compress modified filesystem
echo "[*] Recompressing modified filesystem..."
mksquashfs "$CHROOTDIR" "$ISODIR/casper/filesystem.squashfs" -noappend

# Update filesystem.size
echo "[*] Updating filesystem.size..."
printf $(du -sx --block-size=1 "$CHROOTDIR" | cut -f1) > "$ISODIR/casper/filesystem.size"

# Update md5sum.txt
echo "[*] Updating md5sum.txt..."
cd "$ISODIR"
find . -type f -print0 | xargs -0 md5sum > md5sum.txt
cd ..

# Create new ISO
echo "[*] Creating the new ISO..."
mkisofs -D -r -V "$NEWIMAGENAME_LABEL" -cache-inodes -J -l \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -o "$OUTPUT_FILE" "$ISODIR"

# Make ISO hybrid for USB boot
echo "[*] Making ISO hybrid (USB bootable)..."
isohybrid "$OUTPUT_FILE"

# Unmount original ISO
echo "[*] Unmounting original ISO..."
sudo umount "$SOURCEMOUNT"

echo "[*] Done! New ISO created: $OUTPUT_FILE"
