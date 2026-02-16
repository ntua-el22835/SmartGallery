# Smart Gallery - Run on Android
# Run this after installing Android Studio

$ErrorActionPreference = "Stop"
Write-Host "Smart Gallery - Starting on Android..." -ForegroundColor Cyan
Write-Host ""

# Find Android SDK (default location after Android Studio install)
$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
if (-not (Test-Path (Join-Path $sdkPath "platform-tools"))) {
    $sdkPath = "$env:USERPROFILE\AppData\Local\Android\Sdk"
}

if (Test-Path (Join-Path $sdkPath "platform-tools")) {
    Write-Host "Android SDK: $sdkPath" -ForegroundColor Green
    Write-Host "Configuring Flutter (if needed)..." -ForegroundColor Yellow
    flutter config --android-sdk $sdkPath 2>$null
} else {
    Write-Host "WARNING: Android SDK not found at $sdkPath" -ForegroundColor Yellow
    Write-Host "If installed elsewhere, run: flutter config --android-sdk YOUR_PATH" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Checking devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Run app (use emulator-5554 when -d android fails to detect)
Write-Host "Launching app..." -ForegroundColor Cyan
flutter run -d emulator-5554
if ($LASTEXITCODE -ne 0) { flutter run -d android }

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "--- If no Android device was found ---" -ForegroundColor Yellow
    Write-Host "1. Open Android Studio"
    Write-Host "2. Tools -> Device Manager -> Create Device (if you have no emulator)"
    Write-Host "3. Start the emulator (click play)"
    Write-Host "4. Or connect an Android phone with USB debugging enabled"
    Write-Host ""
    Write-Host "Then run again: .\run_android.ps1" -ForegroundColor Cyan
}
