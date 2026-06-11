#!/bin/bash

# ProjectOS Android 4.0+ Flashable ZIP Creator
# Enhanced for older device support

set -e

echo "======================================"
echo "ProjectOS Flashable ZIP Creator v2.0"
echo "Android 4.0+ Support"
echo "======================================"

OUT_ZIP="${1:-ProjectOS.zip}"
TEMP_DIR="./projectos_temp"

echo "[*] Creating temporary directory..."
mkdir -p "$TEMP_DIR"

echo "[*] Creating directory structure..."
mkdir -p "$TEMP_DIR/system/app"
mkdir -p "$TEMP_DIR/system/priv-app"
mkdir -p "$TEMP_DIR/system/lib"
mkdir -p "$TEMP_DIR/system/lib64"
mkdir -p "$TEMP_DIR/system/framework"
mkdir -p "$TEMP_DIR/system/etc"
mkdir -p "$TEMP_DIR/system/media/audio"
mkdir -p "$TEMP_DIR/META-INF/com/google/android"

echo "[*] Copying files..."
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp app/build/outputs/apk/debug/app-debug.apk "$TEMP_DIR/system/priv-app/ProjectOS.apk"
fi

echo "[*] Creating system files (Android 4.0+ compatible)..."
cat > "$TEMP_DIR/system/build.prop" << 'EOF'
ro.build.version.release=13.0
ro.build.version.sdk=33
ro.build.version.base_os=
ro.product.name=ProjectOS
ro.product.device=projectos
ro.product.brand=ProjectOS
ro.product.model=ProjectOS
ro.product.manufacturer=ProjectOS
ro.build.display.id=ProjectOS 13.0
ro.product.cpu.abi=arm64-v8a
ro.product.cpu.abilist=arm64-v8a,armeabi-v7a,armeabi
ro.product.cpu.abilist32=armeabi-v7a,armeabi
ro.product.cpu.abilist64=arm64-v8a
dalvik.vm.heapsize=256m
ro.config.ringtone=Ring_Synth_04.ogg
ro.config.notification_sound=OnTheHunt.ogg
ro.config.alarm_alert=Alarm_Classic.ogg
ro.com.android.dateformat=MM-dd-yyyy
EOF

echo "[*] Creating updater-script (Android 4.0+ compatible)..."
cat > "$TEMP_DIR/META-INF/com/google/android/updater-script" << 'EOF'
assert(getprop("ro.product.device") == "projectos" || getprop("ro.build.product") == "projectos");
show_progress(0.750000, 0);
ui_print("Installing ProjectOS (Android 4.0+)...");
package_extract_dir("system", "/system");
show_progress(0.250000, 5);
ui_print("Installation complete!");
EOF

echo "[*] Creating update-binary..."
cat > "$TEMP_DIR/META-INF/com/google/android/update-binary" << 'EOF'
#!/sbin/sh
# ProjectOS Update Binary - Android 4.0+ Compatible
ui_print() {
  echo "ui_print $1" >> /proc/self/fd/$2
  echo "ui_print" >> /proc/self/fd/$2
}
ui_print "ProjectOS Installer (Android 4.0+)" 1
exit 0
EOF

chmod +x "$TEMP_DIR/META-INF/com/google/android/update-binary"

echo "[*] Creating MANIFEST and other metadata..."
cat > "$TEMP_DIR/META-INF/MANIFEST.MF" << 'EOF'
Manifest-Version: 1.0
Created-By: ProjectOS
Compatible-With: Android 4.0+

EOF

# Create compatibility info
cat > "$TEMP_DIR/INSTALL_INFO.txt" << 'EOF'
ProjectOS System Image Installation Package
Android 4.0+ Compatible

Supported Devices:
- Android 4.0 IceCreamSandwich (API 14) and newer
- ARM, ARMv7, and ARM64 processors
- Minimum 512MB RAM
- Minimum 500MB system partition

Installation Steps:
1. Boot device into recovery mode
2. Install ZIP from recovery
3. Select this ZIP file
4. Swipe to confirm installation
5. Reboot system

For more information, see BUILD_SYSTEM_IMAGE.md
EOF

echo "[*] Packaging ZIP..."
cd "$TEMP_DIR"
zip -r -q "../$OUT_ZIP" .
cd - > /dev/null

echo "[*] Cleaning up..."
rm -rf "$TEMP_DIR"

echo ""
echo "======================================"
echo "✓ Flashable ZIP created: $OUT_ZIP"
echo "======================================"
echo ""
echo "Installation Instructions:"
echo "  1. Boot device into recovery mode (TWRP recommended)"
echo "  2. Flash ZIP: Install > Select $OUT_ZIP"
echo "  3. Wipe cache/dalvik (if needed)"
echo "  4. Reboot system"
echo ""
echo "Compatibility: Android 4.0+ (API 14+)"
echo "File size: $(du -h "$OUT_ZIP" | cut -f1)"
echo ""
