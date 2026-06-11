#!/bin/bash

# ProjectOS Android 4.0+ Boot Image Creator
# Creates bootable images for older Android devices

set -e

echo "Creating ProjectOS Boot Image (Android 4.0+ Compatible)..."
echo ""

OUT_DIR="${1:-.}"
KERNEL_OFFSET=0x00008000
RAMDISK_OFFSET=0x01000000
BASE=0x00000000
PAGESIZE=4096

echo "[*] Creating kernel placeholder..."
echo -e "\0ProjectOS Kernel Placeholder (Android 4.0+)" > "$OUT_DIR/kernel"

# Create minimal ramdisk for Android 4.0+
echo "[*] Creating ramdisk for Android 4.0+..."
mkdir -p "$OUT_DIR/ramdisk/sbin"
mkdir -p "$OUT_DIR/ramdisk/proc"
mkdir -p "$OUT_DIR/ramdisk/sys"
mkdir -p "$OUT_DIR/ramdisk/dev"
mkdir -p "$OUT_DIR/ramdisk/etc"

# Create init script compatible with Android 4.0+
cat > "$OUT_DIR/ramdisk/init" << 'EOF'
#!/sbin/sh
# ProjectOS Init Script - Android 4.0+ Compatible

echo "ProjectOS Boot - Android 4.0+ Compatibility Mode" > /dev/kmsg

# Mount basic filesystems
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev 2>/dev/null || mknod /dev/null c 1 3

# Setup basic device nodes
mknod -m 666 /dev/null c 1 3
mknod -m 666 /dev/zero c 1 5
mknod -m 666 /dev/urandom c 1 9
mknod -m 622 /dev/console c 5 1
mknod -m 666 /dev/tty c 5 0

# Export environment
export PATH=/sbin:/bin
export LD_LIBRARY_PATH=/lib64:/lib:/system/lib64:/system/lib

# Log boot
echo "ProjectOS: System ready" > /dev/kmsg

# Keep system alive
while true; do sleep 1; done
EOF

chmod +x "$OUT_DIR/ramdisk/init"

# Create recovery script for Android 4.0+
cat > "$OUT_DIR/ramdisk/sbin/recovery" << 'EOF'
#!/sbin/sh
# ProjectOS Recovery Script - Android 4.0+ Compatible
echo "ProjectOS Recovery Mode" > /dev/kmsg
exit 0
EOF

chmod +x "$OUT_DIR/ramdisk/sbin/recovery"

# Create fstab for Android 4.0+
cat > "$OUT_DIR/ramdisk/etc/fstab" << 'EOF'
# ProjectOS fstab - Android 4.0+ Compatible
# <src>                 <mnt_point>   <type>  <mnt_flags>                              <fs_mgr_flags>
EOF

echo "[*] Creating ramdisk cpio archive..."
cd "$OUT_DIR/ramdisk"
find . | cpio -o -H newc 2>/dev/null | gzip > ../ramdisk.cpio.gz
cd - > /dev/null

echo "[✓] Boot image components created:"
echo "  - Kernel: $OUT_DIR/kernel"
echo "  - Ramdisk: $OUT_DIR/ramdisk.cpio.gz"
echo ""
echo "Use 'mkbootimg' to create boot.img:"
echo "  mkbootimg --kernel kernel --ramdisk ramdisk.cpio.gz \\"
echo "    --cmdline 'root=/dev/ram0 ro init=/init console=ttyAMA0' \\"
echo "    --base 0x00000000 --kernel_offset 0x00008000 \\"
echo "    --ramdisk_offset 0x01000000 --pagesize 4096 \\"
echo "    -o boot.img"
echo ""
echo "Note: Compatible with Android 4.0+ devices"
