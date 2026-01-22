# Windows packaging script for DuckUI

$APP_NAME = "DuckUI"
$VERSION = "0.0.1"
$DIST_DIR = "dist\windows"

# Check if a specific target was built, otherwise use default
if (Test-Path "target\x86_64-pc-windows-msvc\release\duckui.exe") {
    $BUILD_DIR = "target\x86_64-pc-windows-msvc\release"
} else {
    $BUILD_DIR = "target\release"
}

# Only build if binary doesn't exist
if (-not (Test-Path "$BUILD_DIR\duckui.exe")) {
    Write-Host "Building release for Windows..." -ForegroundColor Green
    cargo build --release
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
