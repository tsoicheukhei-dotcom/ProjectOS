# ProjectOS System Image Files

## Directory Structure

This document explains the system image file structure and how to build each component.

## File Organization

```
ProjectOS/
├── build_system_image.sh       # Main system image builder
├── build_boot_image.sh         # Boot image builder
├── build_flashable_zip.sh      # Flashable ZIP creator
├── build_iso_image.sh          # ISO image builder
├── projectos_image_utils.sh    # Utility script
├── flash.sh                    # Quick flash script
└── docs/
    └── BUILD_SYSTEM_IMAGE.md   # Complete build guide
```

## System Image Format

### system.img
- **Format**: ext4 filesystem
- **Size**: 2GB (configurable)
- **Partition**: /system
- **Contains**:
  - ProjectOS launcher APK
  - System libraries
  - Framework files
  - Build properties

### boot.img
- **Format**: Android boot image
- **Contains**:
  - Linux kernel
  - Ramdisk (initrd)
  - Device tree blob (dtb)
  - Command line parameters

### Flashable ZIP
- **Format**: ZIP archive
- **Contains**:
  - system/ directory
  - recovery/ directory (optional)
  - META-INF/ (updater scripts)
  - Compatible with TWRP, ClockworkMod, etc.

## Building Process

### Quick Start

```bash
# Build all components
chmod +x projectos_image_utils.sh
./projectos_image_utils.sh build-all ./output

# Flash to device
chmod +x flash.sh
./flash.sh all
```

### Individual Builds

```bash
# System image only
bash build_system_image.sh ./output

# Boot image only
bash build_boot_image.sh ./output

# Flashable ZIP only
bash build_flashable_zip.sh ProjectOS.zip
```

## Image Specifications

### Architecture
- **Primary**: ARM64 (arm64-v8a)
- **Secondary**: ARMv7 (armeabi-v7a) - compatibility
- **Support**: Full 64-bit support

### Android Version
- **Release**: Android 13.0
- **API Level**: 33
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 33

### Partition Details

| Partition | Size | Format | Mount Point |
|-----------|------|--------|-------------|
| system | 2GB | ext4 | /system |
| boot | 32MB | Android img | /boot |
| recovery | 64MB | Android img | /recovery |
| userdata | Remaining | f2fs/ext4 | /data |
| cache | 256MB | ext4 | /cache |

## Customization

### Modify Build Properties

Edit system files before building:

```bash
# Edit build.prop
echo "ro.product.brand=ProjectOS" >> system/build.prop

# Then build
bash build_system_image.sh ./output
```

### Add Custom Apps

```bash
# Copy APK to system
cp myapp.apk system/priv-app/

# Include in system image
bash build_system_image.sh ./output
```

### Change Partition Size

In `build_system_image.sh`:

```bash
IMAGE_SIZE="4096M"  # Change 2GB to 4GB
```

## Output Files

After building, you'll have:

```
output/
├── system/
│   ├── app/
│   ├── priv-app/
│   ├── lib64/
│   ├── framework/
│   ├── etc/
│   ├── build.prop
│   └── default.prop
├── system.img              # Ext4 image
├── system.transfer.list    # Transfer list
├── system.map              # Block map
├── boot/
│   ├── kernel
│   ├── ramdisk.cpio.gz
│   └── bootimg.cfg
├── recovery/
│   ├── recovery.txt
│   └── updater-script
└── META-INF/
    ├── MANIFEST.MF
    └── com/google/android/
        ├── update-binary
        └── updater-script
```

## File Descriptions

### build.prop
- System properties and settings
- Device information
- Build fingerprint
- Product metadata

### default.prop
- Default system properties
- Security settings
- ADB configuration

### updater-script
- Installation instructions
- Device assertions
- File extraction commands

### update-binary
- Recovery updater binary
- Installation UI feedback
- Progress reporting

## Size Reference

Typical image sizes:

| Component | Size | Compressed |
|-----------|------|------------|
| system.img | 2GB | ~500MB |
| boot.img | 32MB | ~10MB |
| recovery.img | 64MB | ~15MB |
| Flashable ZIP | ~520MB | ~520MB |

## Verification

Verify built images:

```bash
# Check system.img
file system.img
# Should show: Linux rev 1.0 ext4 filesystem data

# Verify ZIP integrity
unzip -t ProjectOS.zip

# Check file count
ls -la system/ | wc -l
```

## Deployment

### USB Flashing

```bash
fastboot flash system system.img
fastboot flash boot boot.img
fastboot reboot
```

### OTA (Over-The-Air)

Create OTA package:

```bash
zip -r ProjectOS-OTA.zip META-INF/ system/
```

## Troubleshooting

### Build Errors

```bash
# Permission denied
chmod +x build_system_image.sh

# Missing tools
sudo apt-get install zip cpio gzip e2fsprogs

# Disk space
df -h .  # Check available space
```

### Flash Errors

```bash
# Device not found
fastboot devices

# Permission denied
sudo fastboot flash system system.img

# Checksum failed
# Rebuild image, ensure file integrity
```

## References

- [Android System Images](https://source.android.com/docs/setup/build/building)
- [ext4 Format](https://en.wikipedia.org/wiki/Ext4)
- [Fastboot Commands](https://developer.android.com/studio/command-line/fastboot)
- [Android Boot Image](https://android.googlesource.com/platform/system/tools/mkbootimg/)

## License

MIT
