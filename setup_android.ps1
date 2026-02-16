# Smart Gallery - Android Setup
# Run this after installing Android Studio

Write-Host "Smart Gallery - Android Setup..." -ForegroundColor Cyan
Write-Host ""

$sdkPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\Sdk",
    "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
)

$foundSdk = $null
foreach ($path in $sdkPaths) {
    if (Test-Path $path) {
        $platformTools = Join-Path $path "platform-tools"
        if (Test-Path $platformTools) {
            $foundSdk = $path
            break
        }
    }
}

if ($foundSdk) {
    Write-Host "Found Android SDK: $foundSdk" -ForegroundColor Green
    Write-Host "Configuring Flutter..." -ForegroundColor Yellow
    flutter config --android-sdk $foundSdk
    Write-Host ""
    Write-Host "Checking setup:" -ForegroundColor Yellow
    flutter doctor -v
    Write-Host ""
    Write-Host "Available devices:" -ForegroundColor Yellow
    flutter devices
} else {
    Write-Host "Android SDK not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Steps:" -ForegroundColor Yellow
    Write-Host "1. Open Android Studio"
    Write-Host "2. File -> Settings -> Languages & Frameworks -> Android SDK"
    Write-Host "3. Copy the Android SDK Location path"
    Write-Host "4. Run: flutter config --android-sdk YOUR_PATH"
    Write-Host ""
    $defaultPath = Join-Path $env:LOCALAPPDATA "Android\Sdk"
    Write-Host "Or check if SDK exists at: $defaultPath"
}
