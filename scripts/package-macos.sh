#!/bin/bash
set -e

APP_NAME="DuckUI"
BUNDLE_ID="com.duckui.app"
VERSION="0.0.1"
BUILD_DIR="target/release"
DIST_DIR="dist/macos"

echo "Building release for macOS..."
cargo build --release

echo "Creating app bundle structure..."
rm -rf "${DIST_DIR}/${APP_NAME}.app"
mkdir -p "${DIST_DIR}/${APP_NAME}.app/Contents/MacOS"
mkdir -p "${DIST_DIR}/${APP_NAME}.app/Contents/Resources"

echo "Copying binary..."
cp "${BUILD_DIR}/duckui" "${DIST_DIR}/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
chmod +x "${DIST_DIR}/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

echo "Creating Info.plist..."
cat > "${DIST_DIR}/${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

echo "Creating DMG..."
rm -f "${DIST_DIR}/${APP_NAME}-${VERSION}-macos.dmg"
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DIST_DIR}/${APP_NAME}.app" \
    -ov -format UDZO \
    "${DIST_DIR}/${APP_NAME}-${VERSION}-macos.dmg"

echo "✅ macOS package created: ${DIST_DIR}/${APP_NAME}-${VERSION}-macos.dmg"
echo "   You can also use the .app directly: ${DIST_DIR}/${APP_NAME}.app"
