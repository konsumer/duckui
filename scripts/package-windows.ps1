# Windows packaging script for DuckUI

$APP_NAME = "DuckUI"

# Get version from parameter or git tag, fallback to 0.0.1-dev if no tag
if ($args.Count -gt 0) {
    $VERSION = $args[0]
} else {
    try {
        $VERSION = (git describe --tags --abbrev=0 2>$null)
        if (-not $VERSION) {
            $VERSION = "0.0.1-dev"
        }
    } catch {
        $VERSION = "0.0.1-dev"
    }
}

# Remove 'v' prefix if present
$VERSION = $VERSION -replace '^v', ''

$BUILD_DIR = "target\release"
$DIST_DIR = "dist\windows"

Write-Host "Building version: $VERSION" -ForegroundColor Green
Write-Host "Building release for Windows..." -ForegroundColor Green
cargo build --release

if (-not (Test-Path "$BUILD_DIR\duckui.exe")) {
    Write-Host "❌ Build failed: Binary not found at $BUILD_DIR\duckui.exe" -ForegroundColor Red
    exit 1
}

Write-Host "Creating distribution directory..." -ForegroundColor Green
if (Test-Path $DIST_DIR) {
    Remove-Item -Recurse -Force $DIST_DIR
}
New-Item -ItemType Directory -Path $DIST_DIR -Force | Out-Null

Write-Host "Copying executable..." -ForegroundColor Green
Copy-Item "$BUILD_DIR\duckui.exe" "$DIST_DIR\$APP_NAME.exe"

Write-Host "Creating zip archive..." -ForegroundColor Green
$zipPath = "$DIST_DIR\$APP_NAME-$VERSION-windows-x64.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath
}
Compress-Archive -Path "$DIST_DIR\$APP_NAME.exe" -DestinationPath $zipPath

Write-Host "✅ Windows package created: $zipPath" -ForegroundColor Green
Write-Host "   Executable: $DIST_DIR\$APP_NAME.exe" -ForegroundColor Gray

# Verify the zip was created
if (-not (Test-Path $zipPath)) {
    Write-Host "❌ Zip file was not created!" -ForegroundColor Red
    exit 1
}
