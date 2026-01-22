# Packaging DuckUI

This document describes how to build and package DuckUI for distribution.

## Versioning

All packaging scripts automatically detect the version from git tags:
- If a git tag exists (e.g., `v0.1.0`), it uses that version
- Otherwise, it defaults to `0.0.1-dev`
- You can also pass a version explicitly: `bash scripts/package-macos.sh 1.2.3`

## Platform-Specific Instructions

### macOS

Creates a `.app` bundle and `.dmg` installer:

```bash
# Uses version from git tag
bash scripts/package-macos.sh

# Or specify a version
bash scripts/package-macos.sh 1.2.3
```

Output:
- `dist/macos/DuckUI.app` - Application bundle (can be dragged to Applications)
- `dist/macos/DuckUI-{VERSION}-macos.dmg` - DMG installer

### Windows

Creates a standalone `.exe`:

```bash
# Uses version from git tag
powershell scripts/package-windows.ps1

# Or specify a version
powershell scripts/package-windows.ps1 1.2.3
```

Output:
- `dist/windows/DuckUI.exe` - Standalone executable
- `dist/windows/DuckUI-{VERSION}-windows-x64.zip` - Zip archive

**Requirements:**
- Rust with `x86_64-pc-windows-msvc` target installed

### Linux

Creates a tarball with the binary:

```bash
# Uses version from git tag
bash scripts/package-linux.sh

# Or specify a version
bash scripts/package-linux.sh 1.2.3
```

Output:
- `dist/linux/duckui-{VERSION}-linux-x64.tar.gz` - Tarball with binary

**Requirements:**
- WebKitGTK development libraries (`libwebkit2gtk-4.1-dev` on Ubuntu/Debian)

## Cross-Compilation

### Building Windows from Linux/macOS

Install the Windows target:

```bash
rustup target add x86_64-pc-windows-gnu
```

Then build:

```bash
cargo build --release --target x86_64-pc-windows-gnu
```

### Building for Linux from macOS

Use a Docker container:

```bash
docker run --rm -v "$(pwd)":/app -w /app rust:latest bash scripts/package-linux.sh
```

## GitHub Actions

A GitHub Actions workflow is provided in `.github/workflows/release.yml` that automatically builds and releases packages for all platforms when you push a tag:

```bash
git tag v0.0.1
git push origin v0.0.1
```

## Distribution Notes

### Self-Contained Binaries

All binaries are self-contained with:
- Embedded `loading.html` (the loading screen)
- Embedded `setup.sql` (database initialization)
- Bundled DuckDB (via `bundled` feature)

### User Data Location

The database is created at:
- **macOS**: `~/Library/Application Support/duckui/data.db`
- **Windows**: `%LOCALAPPDATA%\duckui\data.db`
- **Linux**: `~/.local/share/duckui/data.db`

### Runtime Requirements

- **macOS**: macOS 10.13+ (handled by the app bundle)
- **Windows**: Windows 10+ (no additional requirements)
- **Linux**: WebKitGTK 2.0 (usually pre-installed)

## Signing and Notarization

### macOS

For distribution outside the App Store, you should sign and notarize:

```bash
# Sign the app
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" dist/macos/DuckUI.app

# Notarize (requires Apple Developer account)
xcrun notarytool submit dist/macos/DuckUI-0.0.1-macos.dmg \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "app-specific-password"
```

### Windows

For production releases, consider code signing with a certificate:

```bash
signtool sign /f certificate.pfx /p password /tr http://timestamp.digicert.com /td sha256 /fd sha256 dist/windows/DuckUI.exe
```
