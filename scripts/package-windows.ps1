# Windows packaging script for DuckUI

$APP_NAME = "DuckUI"
$VERSION = "0.0.1"
$BUILD_DIR = "target\release"
$DIST_DIR = "dist\windows"

Write-Host "Building release for Windows..." -ForegroundColor Green
cargo build --release --target x86_64-pc-windows-msvc

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
