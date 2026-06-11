# ProjectOS Android 4.0+ System Image Guide

## Overview

This guide covers building and flashing ProjectOS system images with extended support for Android 4.0 and older devices.

## Supported Android Versions

### API Levels
- **API 14**: Android 4.0 IceCreamSandwich
- **API 15**: Android 4.0.3 IceCreamSandwich
- **API 16-18**: Android 4.1-4.3 JellyBean
- **API 19**: Android 4.4 KitKat
- **API 21-22**: Android 5.0-5.1 Lollipop
- **API 23**: Android 6.0 Marshmallow
- **API 24-25**: Android 7.0-7.1 Nougat
- **API 26-27**: Android 8.0-8.1 Oreo
- **API 28**: Android 9.0 Pie
- **API 29**: Android 10
- **API 30**: Android 11
- **API 31-32**: Android 12
- **API 33**: Android 13 (Target)

## Device Requirements

### Minimum Specifications
- **Android Version**: 4.0+ (API 14+)
- **RAM**: 512MB minimum, 1GB+ recommended
- **Storage**: 500MB+ for system partition
- **Processor**: ARM (32-bit or 64-bit)
- **Bootloader**: Unlocked

### Supported Architectures
- **ARM64** (arm64-v8a) - Primary
- **ARMv7** (armeabi-v7a) - Full support
- **ARMv6** (armeabi) - Legacy support

## Building System Image

### Step 1: Check Device Compatibility

```bash
chmod +x compatibility_check.sh
./compatibility_check.sh check
```

This will verify:
- Android API level (minimum 14)
- CPU architecture
- Available RAM
- Storage space
- Custom recovery presence

### Step 2: Build System Image

```bash
chmod +x build_system_image.sh
./build_system_image.sh ./out
```

Generated files:
- `system/` - System partition files
- `system.img` - ext4 system image
- `COMPATIBILITY.txt` - Device compatibility info

### Step 3: Create Flashable ZIP

```bash
chmod +x build_flashable_zip.sh
./build_flashable_zip.sh ProjectOS-Android4.0+.zip
```

## Backward Compatibility Features

### Library Support
- **32-bit libraries** in `/system/lib`
- **64-bit libraries** in `/system/lib64`
- **Dual ABI** support (arm64-v8a, armeabi-v7a)
- **Legacy libc** compatibility layer

### Framework Compatibility
- Android framework compatibility
- Legacy API support
- Media codec support for older formats
- Audio file format compatibility (OGG, WAV)

### Performance Optimization
- **Low heap size** (256MB) for devices with 512MB RAM
- **Disabled JIT** for stability on older devices
- **Optimized battery** management
- **Reduced background** services

## Installation Methods

### Method 1: Custom Recovery (Recommended)

```bash
# Push ZIP to device
adb push ProjectOS-Android4.0+.zip /sdcard/

# Boot to recovery
adb reboot recovery

# In recovery:
# 1. Select "Install"
# 2. Choose ProjectOS-Android4.0+.zip
# 3. Swipe to confirm
# 4. Reboot
```

### Method 2: Fastboot

```bash
# Boot to fastboot
adb reboot bootloader

# Flash system image
fastboot flash system out/system.img
fastboot flash boot out/boot.img

# Reboot
fastboot reboot
```

### Method 3: ADB Sideload

```bash
# Boot to recovery with sideload option
adb reboot recovery

# In recovery, select "Apply update from ADB"
adb sideload ProjectOS-Android4.0+.zip
```

## Configuration for Older Devices

### Adjust Heap Size

In `build_system_image.sh`, modify:

```bash
# For 512MB devices
dalvik.vm.heapsize=128m

# For 1GB+ devices
dalvik.vm.heapsize=256m
```

### Enable Features for Specific API Levels

Edit `system/build.prop`:

```properties
# Android 4.0 specific
ro.build.version.release=4.0
ro.build.version.sdk=14

# Hardware acceleration
ro.hardware.keystore=msm8974
```

### Disable Unnecessary Services

For low-RAM devices, remove from `system/etc/init.rc`:

```bash
# Reduce background services
# Keep only essential ones
```

## Troubleshooting

### Device Not Compatible

```bash
# Check API level
adb shell getprop ro.build.version.sdk

# Must be 14 or higher
```

### Installation Fails

1. **Verify device bootloader is unlocked**
   ```bash
   fastboot oem unlock
   ```

2. **Check custom recovery**
   ```bash
   adb shell test -f /recovery/etc/recovery.fstab
   ```

3. **Ensure sufficient storage**
   ```bash
   adb shell df /system
   ```

### System Won't Boot

1. Boot to recovery
2. Wipe cache/dalvik cache
3. Try again
4. If still fails, restore backup or flash original ROM

## Performance Tips

### For Low-RAM Devices (512MB)

```properties
dalvik.vm.heapsize=128m
dalvik.vm.usejit=false
ro.vendor.extension_library=/vendor/lib/rfsa/adsp/libfastcvopt.so
```

### For Mid-Range Devices (1-2GB)

```properties
dalvik.vm.heapsize=256m
dalvik.vm.usejit=true
dalvik.vm.usejitprofiles=true
```

### Battery Optimization

```properties
ro.power_profile.extension=1
power.saving_mode=1
ro.hwui.drop_shadow_cache_size=0
```

## Advanced Configuration

### Custom Kernel Parameters

Edit `boot/bootimg.cfg`:

```bash
--cmdline="root=/dev/ram0 ro init=/init console=ttyAMA0 printk.time=1 mem=512M"
```

### Vendor Partition (If Supported)

```bash
mkdir -p vendor/lib
# Add vendor-specific libraries
```

### SELinux Configuration

For older devices, disable SELinux in `build.prop`:

```properties
ro.boot.selinux=disabled
```

## Distribution

### Creating Release Package

```bash
zip -r ProjectOS-Android4.0+-v1.0.zip \
    system.img \
    boot.img \
    build_system_image.sh \
    compatibility_check.sh \
    BUILD_SYSTEM_IMAGE.md \
    README.md
```

### Generate Checksums

```bash
sha256sum ProjectOS-Android4.0+-v1.0.zip > ProjectOS-Android4.0+-v1.0.zip.sha256
md5sum ProjectOS-Android4.0+-v1.0.zip > ProjectOS-Android4.0+-v1.0.zip.md5
```

## Testing Matrix

| Device | API | RAM | CPU | Status |
|--------|-----|-----|-----|--------|
| Android 4.0 | 14 | 512MB | ARMv7 | ✓ Tested |
| Android 4.4 | 19 | 1GB | ARMv7 | ✓ Tested |
| Android 5.0 | 21 | 2GB | ARM64 | ✓ Tested |
| Android 6.0 | 23 | 2GB | ARM64 | ✓ Tested |
| Android 7.0 | 24 | 3GB | ARM64 | ✓ Tested |
| Android 13 | 33 | 4GB+ | ARM64 | ✓ Target |

## References

- [Android Version History](https://en.wikipedia.org/wiki/Android_version_history)
- [Android API Levels](https://developer.android.com/guide/topics/manifest/uses-sdk-element)
- [ARM Processors](https://en.wikipedia.org/wiki/ARM_architecture)
- [Dalvik VM Tuning](https://source.android.com/devices/dalvik)
- [Android Boot Process](https://source.android.com/docs/core/boot)

## License

MIT
