#!/bin/bash

# ProjectOS Android 4.0+ Compatibility Check
# Validates device compatibility before flashing

set -e

echo "========================================"
echo "ProjectOS Compatibility Checker"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMPAT_SCORE=0
TOTAL_CHECKS=0

check_device() {
    echo -e "${YELLOW}[*] Checking device compatibility...${NC}"
    echo ""
    
    # Check if device is connected
    if ! adb devices | grep -q "device$"; then
        echo -e "${RED}[!] No ADB device found${NC}"
        echo "    Please ensure:"
        echo "    1. Device is connected via USB"
        echo "    2. USB debugging is enabled"
        echo "    3. ADB drivers are installed"
        return 1
    fi
    
    echo -e "${GREEN}[✓] Device connected via ADB${NC}"
    
    # Get device properties
    API_LEVEL=$(adb shell getprop ro.build.version.sdk)
    DEVICE_NAME=$(adb shell getprop ro.device.name)
    PRODUCT=$(adb shell getprop ro.product.name)
    MANUFACTURER=$(adb shell getprop ro.product.manufacturer)
    MODEL=$(adb shell getprop ro.product.model)
    CPU_ABI=$(adb shell getprop ro.product.cpu.abi)
    TOTAL_MEM=$(adb shell cat /proc/meminfo | grep MemTotal | awk '{print $2}')
    TOTAL_MEM_MB=$((TOTAL_MEM / 1024))
    
    echo "Device Information:"
    echo "  Device: $DEVICE_NAME"
    echo "  Manufacturer: $MANUFACTURER"
    echo "  Model: $MODEL"
    echo "  Android API: $API_LEVEL"
    echo "  CPU ABI: $CPU_ABI"
    echo "  RAM: ${TOTAL_MEM_MB}MB"
    echo ""
    
    # Check API Level (Android 4.0+ = API 14+)
    ((TOTAL_CHECKS++))
    echo -e "${YELLOW}[*] Checking API Level...${NC}"
    if [ "$API_LEVEL" -ge 14 ]; then
        ANDROID_VERSION=""
        case $API_LEVEL in
            14) ANDROID_VERSION="Android 4.0 IceCreamSandwich" ;;
            15) ANDROID_VERSION="Android 4.0.3 IceCreamSandwich" ;;
            16|17|18) ANDROID_VERSION="Android 4.1-4.3 JellyBean" ;;
            19) ANDROID_VERSION="Android 4.4 KitKat" ;;
            21|22) ANDROID_VERSION="Android 5.0-5.1 Lollipop" ;;
            23) ANDROID_VERSION="Android 6.0 Marshmallow" ;;
            24|25) ANDROID_VERSION="Android 7.0-7.1 Nougat" ;;
            26|27) ANDROID_VERSION="Android 8.0-8.1 Oreo" ;;
            28) ANDROID_VERSION="Android 9.0 Pie" ;;
            29) ANDROID_VERSION="Android 10" ;;
            30) ANDROID_VERSION="Android 11" ;;
            31|32) ANDROID_VERSION="Android 12" ;;
            33) ANDROID_VERSION="Android 13" ;;
            *) ANDROID_VERSION="Android $API_LEVEL" ;;
        esac
        echo -e "${GREEN}[✓] API Level $API_LEVEL ($ANDROID_VERSION) - COMPATIBLE${NC}"
        ((COMPAT_SCORE++))
    else
        echo -e "${RED}[!] API Level $API_LEVEL - NOT SUPPORTED (minimum API 14)${NC}"
    fi
    echo ""
    
    # Check CPU Architecture
    ((TOTAL_CHECKS++))
    echo -e "${YELLOW}[*] Checking CPU Architecture...${NC}"
    if [[ "$CPU_ABI" == "arm64-v8a" ]] || [[ "$CPU_ABI" == "armeabi-v7a" ]] || [[ "$CPU_ABI" == "armeabi" ]]; then
        echo -e "${GREEN}[✓] CPU Architecture $CPU_ABI - SUPPORTED${NC}"
        ((COMPAT_SCORE++))
    else
        echo -e "${RED}[!] CPU Architecture $CPU_ABI - NOT SUPPORTED${NC}"
        echo "    Supported: arm64-v8a, armeabi-v7a, armeabi"
    fi
    echo ""
    
    # Check RAM (minimum 512MB recommended)
    ((TOTAL_CHECKS++))
    echo -e "${YELLOW}[*] Checking available RAM...${NC}"
    if [ "$TOTAL_MEM_MB" -ge 512 ]; then
        echo -e "${GREEN}[✓] RAM ${TOTAL_MEM_MB}MB - SUFFICIENT${NC}"
        ((COMPAT_SCORE++))
    else
        echo -e "${YELLOW}[!] RAM ${TOTAL_MEM_MB}MB - MINIMAL (512MB+ recommended)${NC}"
    fi
    echo ""
    
    # Check Storage space
    ((TOTAL_CHECKS++))
    echo -e "${YELLOW}[*] Checking available storage...${NC}"
    AVAILABLE_STORAGE=$(adb shell df /system | tail -1 | awk '{print $4}')
    AVAILABLE_STORAGE_MB=$((AVAILABLE_STORAGE / 1024))
    if [ "$AVAILABLE_STORAGE_MB" -ge 500 ]; then
        echo -e "${GREEN}[✓] Storage ${AVAILABLE_STORAGE_MB}MB - SUFFICIENT${NC}"
        ((COMPAT_SCORE++))
    else
        echo -e "${YELLOW}[!] Storage ${AVAILABLE_STORAGE_MB}MB - LOW (500MB+ recommended)${NC}"
    fi
    echo ""
    
    # Check for custom recovery (optional)
    ((TOTAL_CHECKS++))
    echo -e "${YELLOW}[*] Checking for custom recovery...${NC}"
    if adb shell test -f /recovery/etc/recovery.fstab 2>/dev/null; then
        echo -e "${GREEN}[✓] Custom recovery detected - RECOMMENDED${NC}"
        ((COMPAT_SCORE++))
    else
        echo -e "${YELLOW}[!] Custom recovery not detected (TWRP recommended for easier installation)${NC}"
    fi
    echo ""
    
    # Summary
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Compatibility Score: $COMPAT_SCORE/$TOTAL_CHECKS${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    
    if [ "$COMPAT_SCORE" -ge 4 ]; then
        echo -e "${GREEN}[✓] Device is COMPATIBLE with ProjectOS${NC}"
        echo "    You can proceed with installation"
        return 0
    else
        echo -e "${YELLOW}[!] Device may have compatibility issues${NC}"
        echo "    Proceed with caution"
        return 0
    fi
}

show_help() {
    echo "ProjectOS Compatibility Checker"
    echo ""
    echo "Usage: ./compatibility_check.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  check        Check device compatibility (default)"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./compatibility_check.sh check"
    echo "  ./compatibility_check.sh"
    echo ""
}

COMMAND=${1:-check}

case "$COMMAND" in
    check)
        check_device
        ;;
    help|*)
        show_help
        ;;
esac
