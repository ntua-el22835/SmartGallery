# Smart Gallery - Εκτέλεση στο Web (χωρίς Visual Studio)
# Χρησιμοποιεί Microsoft Edge που είναι ενσωματωμένο στο Windows 10/11

Write-Host "Smart Gallery - Εκκίνηση στο Web..." -ForegroundColor Cyan
Write-Host ""

# Δοκιμή Edge πρώτα (ενσωματωμένο στο Windows)
Write-Host "Προσπάθεια εκκίνησης με Microsoft Edge..." -ForegroundColor Yellow
flutter run -d edge

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Edge δεν βρέθηκε. Δοκιμή Chrome..." -ForegroundColor Yellow
    
    # Δοκιμή Chrome σε κοινές τοποθεσίες
    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )
    
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            $env:CHROME_EXECUTABLE = $path
            Write-Host "Βρέθηκε Chrome: $path" -ForegroundColor Green
            flutter run -d chrome
            exit $LASTEXITCODE
        }
    }
    
    Write-Host ""
    Write-Host "ΣΦΑΛΜΑ: Δεν βρέθηκε Edge ή Chrome." -ForegroundColor Red
    Write-Host "Για εκτέλεση στο Windows desktop χρειάζεστε Visual Studio." -ForegroundColor Red
    Write-Host "Δείτε SETUP_VISUAL_STUDIO.md για οδηγίες." -ForegroundColor Yellow
    exit 1
}
