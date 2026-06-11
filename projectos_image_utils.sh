#!/bin/bash

# ProjectOS System Image Helper Script
# Utilities for building and flashing system images

set -e

COMMAND=${1:-help}

show_help() {
    echo "ProjectOS System Image Builder - Utilities"
    echo ""
    echo "Usage: ./projectos_image_utils.sh [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build-system    Build complete system image"
    echo "  build-boot      Build boot image"
    echo "  build-flashable Build flashable ZIP"
    echo "  build-iso       Build Linux ISO image"
    echo "  build-all       Build all images"
    echo "  info            Show device info"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./projectos_image_utils.sh build-system ./out"
    echo "  ./projectos_image_utils.sh build-flashable ProjectOS.zip"
    echo "  ./projectos_image_utils.sh build-all ./images"
    echo ""
}

check_requirements() {
    echo "Checking system requirements..."
    
    local missing=0
    
    if ! command -v zip &> /dev/null; then
        echo "  [!] zip not found"
        missing=1
    else
        echo "  [✓] zip found"
    fi
    
    if ! command -v cpio &> /dev/null; then
        echo "  [!] cpio not found"
        missing=1
    else
        echo "  [✓] cpio found"
    fi
    
    if ! command -v gzip &> /dev/null; then
        echo "  [!] gzip not found"
        missing=1
    else
        echo "  [✓] gzip found"
    fi
    
    if ! command -v mkfs.ext4 &> /dev/null; then
        echo "  [!] mkfs.ext4 not found (optional)"
    else
        echo "  [✓] mkfs.ext4 found"
    fi
    
    if [ $missing -eq 1 ]; then
        echo ""
        echo "Missing required tools. Please install them:"
        echo "  Ubuntu/Debian: sudo apt-get install zip cpio gzip e2fsprogs"
        return 1
    fi
    
    return 0
}

case "$COMMAND" in
    build-system)
        echo "Building system image..."
        bash build_system_image.sh "${2:-.}"
        ;;
    build-boot)
        echo "Building boot image..."
        bash build_boot_image.sh "${2:-.}"
        ;;
    build-flashable)
        echo "Building flashable ZIP..."
        bash build_flashable_zip.sh "${2:-ProjectOS.zip}"
        ;;
    build-iso)
        echo "Building ISO image..."
        bash build_iso_image.sh "${2:-ProjectOS.iso}"
        ;;
    build-all)
        echo "Building all images..."
        mkdir -p "${2:-./images}"
        bash build_system_image.sh "${2:-./images}"
        bash build_boot_image.sh "${2:-./images}"
        bash build_flashable_zip.sh "${2:-./images}/ProjectOS.zip"
        bash build_iso_image.sh "${2:-./images}/ProjectOS.iso"
        echo ""
        echo "All images built in: ${2:-./images}"
        ;;
    info)
        check_requirements
        echo ""
        echo "System Information:"
        echo "  OS: $(uname -s)"
        echo "  Kernel: $(uname -r)"
        echo "  Architecture: $(uname -m)"
        echo ""
        echo "ProjectOS Target:"
        echo "  Platform: Android 13.0"
        echo "  API Level: 33"
        echo "  Architecture: arm64-v8a"
        echo "  Min API: 21 (Android 5.0)"
        ;;
    help|*)
        show_help
        ;;
esac
