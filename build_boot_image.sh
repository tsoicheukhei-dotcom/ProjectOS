#!/bin/bash

# ProjectOS Boot Image Creator
# Creates a bootable boot.img for Android devices

set -e

echo "Creating ProjectOS Boot Image..."

OUT_DIR="${1:-.}"
KERNEL_OFFSET=0x00008000
RAMDISK_OFFSET=0x01000000
BASE=0x00000000
PAGESIZE=4096

# Create minimal kernel (placeholder)
echo -e "\0ProjectOS Kernel Placeholder" > "$OUT_DIR/kernel"

# Create minimal ramdisk
mkdir -p "$OUT_DIR/ramdisk"
echo '#!/sbin/sh' > "$OUT_DIR/ramdisk/init"
echo 'mount -t proc proc /proc' >> "$OUT_DIR/ramdisk/init"
echo 'mount -t sysfs sys /sys' >> "$OUT_DIR/ramdisk/init"
echo 'echo "ProjectOS Boot" > /dev/kmsg' >> "$OUT_DIR/ramdisk/init"
chmod +x "$OUT_DIR/ramdisk/init"

# Create ramdisk cpio archive
cd "$OUT_DIR/ramdisk"
find . | cpio -o -H newc | gzip > ../ramdisk.cpio.gz
cd -

echo "Boot image components created:"
echo "  - Kernel: $OUT_DIR/kernel"
echo "  - Ramdisk: $OUT_DIR/ramdisk.cpio.gz"
echo ""
echo "Use 'mkbootimg' to create boot.img:"
echo "  mkbootimg --kernel kernel --ramdisk ramdisk.cpio.gz \\"
echo "    --cmdline 'root=/dev/ram0 ro init=/init console=ttyAMA0' \\"
echo "    --base 0x00000000 --kernel_offset 0x00008000 \\"
echo "    --ramdisk_offset 0x01000000 --pagesize 4096 \\"
echo "    -o boot.img"
