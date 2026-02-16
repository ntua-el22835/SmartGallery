@echo off
REM Smart Gallery - Run on Android
REM No execution policy needed - double-click or run from cmd

echo Smart Gallery - Starting on Android...
echo.

REM Configure Flutter with Android SDK
set SDK_PATH=%LOCALAPPDATA%\Android\Sdk
if exist "%SDK_PATH%\platform-tools" (
    echo Android SDK: %SDK_PATH%
    flutter config --android-sdk "%SDK_PATH%" 2>nul
) else (
    set SDK_PATH=%USERPROFILE%\AppData\Local\Android\Sdk
    if exist "%SDK_PATH%\platform-tools" (
        echo Android SDK: %SDK_PATH%
        flutter config --android-sdk "%SDK_PATH%" 2>nul
    )
)

echo.
echo Checking devices...
flutter devices
echo.
echo Launching app...
echo.

REM Try emulator-5554 first (common), then fall back to any Android device
flutter run -d emulator-5554
if errorlevel 1 (
    echo.
    echo Trying any Android device...
    flutter run -d android
)

if errorlevel 1 (
    echo.
    echo --- If no Android device was found ---
    echo 1. Start the emulator from Android Studio Device Manager
    echo 2. Run: flutter devices
    echo 3. Then: flutter run -d YOUR_DEVICE_ID
    echo.
    pause
)
