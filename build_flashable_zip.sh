#!/bin/bash

# ProjectOS Flashable ZIP Creator
# Creates a complete flashable ZIP for custom recovery

set -e

echo "======================================"
echo "ProjectOS Flashable ZIP Creator"
echo "======================================"

OUT_ZIP="${1:-ProjectOS.zip}"
TEMP_DIR="./projectos_temp"

echo "[*] Creating temporary directory..."
mkdir -p "$TEMP_DIR"

echo "[*] Creating directory structure..."
mkdir -p "$TEMP_DIR/system/app"
mkdir -p "$TEMP_DIR/system/priv-app"
mkdir -p "$TEMP_DIR/system/lib64"
mkdir -p "$TEMP_DIR/system/framework"
mkdir -p "$TEMP_DIR/system/etc"
mkdir -p "$TEMP_DIR/META-INF/com/google/android"

echo "[*] Copying files..."
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp app/build/outputs/apk/debug/app-debug.apk "$TEMP_DIR/system/priv-app/ProjectOS.apk"
fi

echo "[*] Creating system files..."
cat > "$TEMP_DIR/system/build.prop" << 'EOF'
ro.build.version.release=13.0
ro.build.version.sdk=33
ro.product.name=ProjectOS
ro.product.device=projectos
ro.product.brand=ProjectOS
ro.product.model=ProjectOS
ro.product.manufacturer=ProjectOS
ro.build.display.id=ProjectOS 13.0
EOF

echo "[*] Creating updater-script..."
cat > "$TEMP_DIR/META-INF/com/google/android/updater-script" << 'EOF'
assert(getprop("ro.product.device") == "projectos" || getprop("ro.build.product") == "projectos");
show_progress(0.750000, 0);
ui_print("Installing ProjectOS...");
package_extract_dir("system", "/system");
show_progress(0.250000, 5);
ui_print("Installation complete!");
EOF

echo "[*] Creating update-binary..."
cat > "$TEMP_DIR/META-INF/com/google/android/update-binary" << 'EOF'
#!/sbin/sh
ui_print() {
  echo "ui_print $1" >> /proc/self/fd/$2
  echo "ui_print" >> /proc/self/fd/$2
}
ui_print "ProjectOS Installer" 1
exit 0
EOF

chmod +x "$TEMP_DIR/META-INF/com/google/android/update-binary"

echo "[*] Creating MANIFEST..."
cat > "$TEMP_DIR/META-INF/MANIFEST.MF" << 'EOF'
Manifest-Version: 1.0
Created-By: ProjectOS

EOF

echo "[*] Packaging ZIP..."
cd "$TEMP_DIR"
zip -r -q "../$OUT_ZIP" .
cd ..

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
echo "  3. Wipe cache/dalvik"
echo "  4. Reboot system"
echo ""
echo "File size: $(du -h "$OUT_ZIP" | cut -f1)"
echo ""
