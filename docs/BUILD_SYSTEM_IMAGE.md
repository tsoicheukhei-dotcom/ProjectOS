# ProjectOS System Image Build Guide

## Overview

This guide explains how to build and flash a complete Android system image for ProjectOS on various devices.

## System Image Components

### 1. System Partition (system.img)
- Contains the OS and system apps
- Size: 2GB (configurable)
- Format: ext4
- Includes ProjectOS shell launcher

### 2. Boot Image (boot.img)
- Contains kernel and ramdisk
- Required for device boot
- Architecture: arm64-v8a

### 3. Recovery Image (recovery.img)
- Custom recovery for flashing updates
- Used for system maintenance

### 4. Flashable ZIP
- Complete package for custom recovery
- Compatible with TWRP, ClockworkMod, etc.

## Building System Image

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get install -y \
    zip cpio gzip \
    e2fsprogs \
    android-tools-adb \
    android-tools-fastboot

# macOS
brew install zip cpio gzip e2fsprogs
```

### Build Process

#### Step 1: Build APK
```bash
./gradlew build
```

#### Step 2: Create System Image
```bash
chmod +x build_system_image.sh
./build_system_image.sh ./out
```

This creates:
- `out/system/` - System partition files
- `out/system.img` - Ext4 system image
- `out/system.transfer.list` - File transfer list

#### Step 3: Build Flashable ZIP
```bash
chmod +x build_flashable_zip.sh
./build_flashable_zip.sh ProjectOS-13.0.zip
```

#### Step 4: Build Boot Image (Optional)
```bash
chmod +x build_boot_image.sh
./build_boot_image.sh ./out
```

### Complete Build
```bash
chmod +x projectos_image_utils.sh
./projectos_image_utils.sh build-all ./images
```

## Flashing to Device

### Method 1: Using Fastboot (For Unlocked Bootloader)

```bash
# Boot device into fastboot mode
# Typically: Hold Volume Down + Power

# Verify device is connected
fastboot devices

# Flash system image
fastboot flash system images/system.img

# Flash boot image
fastboot flash boot images/boot.img

# Reboot
fastboot reboot
```

### Method 2: Using Custom Recovery (TWRP)

```bash
# Prerequisites:
# 1. Device must have custom recovery installed
# 2. Phone in recovery mode (Volume Up + Power)

# Push ZIP to device
adb push ProjectOS-13.0.zip /sdcard/

# In TWRP recovery:
# Install -> Select ProjectOS-13.0.zip
# Swipe to confirm
# Reboot System
```

### Method 3: Using ADB Sideload

```bash
# Boot into recovery
adb reboot recovery

# In recovery, select "Apply update from ADB"

# Sideload the ZIP
adb sideload ProjectOS-13.0.zip
```

## Device Requirements

### Hardware
- **Processor**: ARM64 (arm64-v8a)
- **RAM**: Minimum 2GB
- **Storage**: Minimum 2GB for system partition
- **Bootloader**: Must be unlocked

### Software
- **Android Version**: 5.0+ (API 21+)
- **Custom Recovery**: TWRP 3.5+ recommended
- **ADB/Fastboot**: Latest version

## Supported Devices

ProjectOS has been tested on:
- Google Pixel series
- OnePlus devices
- Samsung Galaxy series (with unlocked bootloader)
- Generic ARM64 Android devices

## Configuration

### Modify System Properties

Edit `system/build.prop`:

```properties
ro.product.name=ProjectOS
ro.product.device=projectos
ro.build.version.release=13.0
ro.build.version.sdk=33
```

### Adjust Partition Size

In `build_system_image.sh`, change:

```bash
IMAGE_SIZE="2048M"  # Change to desired size
BLOCK_SIZE="4096"
```

## Troubleshooting

### Image Won't Flash
- Ensure bootloader is unlocked: `fastboot flashing unlock`
- Verify device compatibility
- Check device is in correct mode (fastboot/recovery)

### System Won't Boot
- Verify boot.img is compatible
- Check kernel version
- Try with minimal ramdisk

### Missing Files
- Run `./gradlew build` first
- Ensure all dependencies are installed
- Check build scripts have execute permissions

## Advanced Options

### Sparse Image Format

For faster flashing over ADB:

```bash
img2simg system.img system.sparse.img
```

### Vendor Image

To include vendor partition:

```bash
mkdir -p vendor/lib64
# Add vendor libraries
```

### Custom Kernel

Replace kernel in boot.img:

```bash
mkbootimg --kernel custom-kernel --ramdisk ramdisk.cpio.gz -o boot.img
```

## Distribution

### Creating Release ZIP

```bash
zip -r ProjectOS-13.0-release.zip \
    system.img \
    boot.img \
    recovery.img \
    flashall.sh \
    README.md
```

### Checksum Verification

```bash
sha256sum ProjectOS-13.0.zip > ProjectOS-13.0.zip.sha256
```

## Performance Optimization

### Compress Images

```bash
gzip -9 system.img
# Reduces ~1.5GB to ~400MB
```

### Parallel Flashing

```bash
fastboot --set-active=a
fastboot flash system_a system.img
fastboot --set-active=b
fastboot flash system_b system.img
```

## References

- [Android Boot Image Format](https://source.android.com/docs/core/boot)
- [Fastboot Documentation](https://developer.android.com/studio/command-line/fastboot)
- [ext4 Filesystem](https://www.kernel.org/doc/html/latest/filesystems/ext4/index.html)
- [TWRP Installation Guide](https://twrp.me/)

## License

MIT
