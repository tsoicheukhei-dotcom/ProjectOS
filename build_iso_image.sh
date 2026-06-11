#!/bin/bash

# ProjectOS ISO Creator for Linux Tablets
# Creates a bootable ISO image for testing

set -e

echo "Creating ProjectOS Linux ISO..."

OUT_ISO="${1:-ProjectOS.iso}"
TEMP_DIR="./iso_temp"

mkdir -p "$TEMP_DIR/boot/grub"
mkdir -p "$TEMP_DIR/ProjectOS"

# Copy ProjectOS app
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp app/build/outputs/apk/debug/app-debug.apk "$TEMP_DIR/ProjectOS/ProjectOS.apk"
fi

# Create GRUB config
cat > "$TEMP_DIR/boot/grub/grub.cfg" << 'EOF'
insmod gfxterm
insmod png

set default=0
set timeout=5

menuentry 'ProjectOS' {
    echo 'Starting ProjectOS...'
    linux /vmlinuz root=/dev/ram0 ro
    initrd /initrd.img
}
EOF

echo "ISO structure created at: $TEMP_DIR"
echo "Note: A full ISO requires kernel and initrd files"
echo ""
echo "To create a complete ISO, you need:"
echo "  1. Linux kernel (vmlinuz)"
echo "  2. Initial ramdisk (initrd.img)"
echo "  3. GRUB bootloader"
echo ""
echo "Command to create ISO (requires grub-mkrescue):"
echo "  grub-mkrescue -o $OUT_ISO $TEMP_DIR"
echo ""
