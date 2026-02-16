@echo off
REM Smart Gallery - Εκτέλεση στο Web (χωρίς Visual Studio)
REM Χρησιμοποιεί Microsoft Edge

echo Smart Gallery - Εκκίνηση στο Web...
echo.

flutter run -d edge

if errorlevel 1 (
    echo.
    echo Δοκιμή Chrome...
    set "CHROME_EXECUTABLE=C:\Program Files\Google\Chrome\Application\chrome.exe"
    if exist "%CHROME_EXECUTABLE%" (
        flutter run -d chrome
    ) else (
        set "CHROME_EXECUTABLE=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        if exist "%CHROME_EXECUTABLE%" (
            flutter run -d chrome
        ) else (
            echo ΣΦΑΛΜΑ: Δεν βρέθηκε Edge ή Chrome.
            echo Δείτε SETUP_VISUAL_STUDIO.md για οδηγίες.
            pause
            exit /b 1
        )
    )
)
