#!/bin/bash
set -e

# Unified packaging script that detects OS and runs appropriate packaging

OS="$(uname -s)"

case "${OS}" in
    Darwin*)
        echo "🍎 Detected macOS"
        bash scripts/package-macos.sh
        ;;
    Linux*)
        echo "🐧 Detected Linux"
        bash scripts/package-linux.sh
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "🪟 Detected Windows"
        powershell.exe -ExecutionPolicy Bypass -File scripts/package-windows.ps1
        ;;
    *)
        echo "❌ Unknown operating system: ${OS}"
        echo "Please run the platform-specific script manually:"
        echo "  - macOS: bash scripts/package-macos.sh"
        echo "  - Linux: bash scripts/package-linux.sh"
        echo "  - Windows: powershell scripts/package-windows.ps1"
        exit 1
        ;;
esac

echo ""
echo "✅ Packaging complete! Check the dist/ directory."
