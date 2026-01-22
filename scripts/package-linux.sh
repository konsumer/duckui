#!/bin/bash
set -e

APP_NAME="duckui"
VERSION="0.0.1"
BUILD_DIR="target/release"
DIST_DIR="dist/linux"

echo "Building release for Linux..."
cargo build --release

echo "Creating distribution directory..."
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}/${APP_NAME}"

echo "Copying binary..."
cp "${BUILD_DIR}/duckui" "${DIST_DIR}/${APP_NAME}/"
chmod +x "${DIST_DIR}/${APP_NAME}/duckui"

echo "Creating README..."
cat > "${DIST_DIR}/${APP_NAME}/README.txt" << EOF
DuckUI v${VERSION}

To run:
./duckui

Requirements:
- WebKitGTK (usually pre-installed on most Linux distributions)
- If not installed, run: sudo apt install libwebkit2gtk-4.1-0 (Ubuntu/Debian)
  or equivalent for your distribution

Database location:
~/.local/share/duckui/data.db
EOF

echo "Creating tarball..."
cd "${DIST_DIR}"
tar -czf "${APP_NAME}-${VERSION}-linux-x64.tar.gz" "${APP_NAME}"
cd - > /dev/null

echo "✅ Linux package created: ${DIST_DIR}/${APP_NAME}-${VERSION}-linux-x64.tar.gz"
