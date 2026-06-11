#!/bin/bash

# ProjectOS Flash Script
# Quick flashing utility for fastboot

set -e

echo "========================================"
echo "ProjectOS Flash Tool"
echo "========================================"
echo ""

if [ "$#" -lt 1 ]; then
    echo "Usage: ./flash.sh [system|boot|all] [device_index]"
    echo ""
    echo "Examples:"
    echo "  ./flash.sh system       # Flash only system image"
    echo "  ./flash.sh boot         # Flash only boot image"
    echo "  ./flash.sh all          # Flash system and boot"
    echo ""
    exit 1
fi

echo "[*] Checking for connected devices..."
if ! fastboot devices | grep -q "fastboot"; then
    echo "[!] No devices in fastboot mode"
    echo "[*] Please boot device into fastboot:"
    echo "    - Hold Volume Down + Power"
    echo "    - Select Fastboot"
    exit 1
fi

echo "[✓] Device found"
echo ""

FLASH_SYSTEM=false
FLASH_BOOT=false

case "$1" in
    system)
        FLASH_SYSTEM=true
        ;;
    boot)
        FLASH_BOOT=true
        ;;
    all)
        FLASH_SYSTEM=true
        FLASH_BOOT=true
        ;;
    *)
        echo "[!] Unknown option: $1"
        exit 1
        ;;
esac

if [ "$FLASH_SYSTEM" = true ]; then
    if [ ! -f "images/system.img" ]; then
        echo "[!] system.img not found"
        echo "[*] Building system image first..."
        bash build_system_image.sh ./images
    fi
    echo "[*] Flashing system partition..."
    fastboot flash system images/system.img
    echo "[✓] System flashed"
    echo ""
fi

if [ "$FLASH_BOOT" = true ]; then
    if [ ! -f "images/boot.img" ]; then
        echo "[!] boot.img not found"
        echo "[*] Building boot image first..."
        bash build_boot_image.sh ./images
    fi
    echo "[*] Flashing boot partition..."
    fastboot flash boot images/boot.img
    echo "[✓] Boot flashed"
    echo ""
fi

echo "[*] Rebooting device..."
fastboot reboot

echo ""
echo "========================================"
echo "✓ Flash complete!"
echo "========================================"
echo ""
echo "Device should boot with ProjectOS shortly."
echo ""
