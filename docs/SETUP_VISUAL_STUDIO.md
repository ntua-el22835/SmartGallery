# Visual Studio Setup Guide for Flutter Windows Development

## ⚡ Γρήγορη Λύση - Εκτέλεση ΤΩΡΑ (χωρίς εγκατάσταση)

**Αν δεν έχετε Visual Studio**, μπορείτε να τρέξετε την εφαρμογή στο **Web** με Microsoft Edge:

```powershell
# Επιλογή 1: PowerShell
.\run_web.ps1

# Επιλογή 2: Batch
run_web.bat

# Επιλογή 3: Απευθείας
flutter run -d edge
```

Το Microsoft Edge είναι ενσωματωμένο στο Windows 10/11 - δεν χρειάζεται εγκατάσταση.

---

## Προβλήματα flutter doctor

### Flutter βρίσκει SQL Server Management Studio αντί για Visual Studio

Το **SSMS** δεν είναι το ίδιο με το **Visual Studio**. Μετά την εγκατάσταση του Visual Studio, αν το Flutter εξακολουθεί να βρίσκει το SSMS, ορίστε το path χειροκίνητα:

```powershell
# Για Visual Studio 2022 Community
flutter config --vs2022-path "C:\Program Files\Microsoft Visual Studio\2022\Community"

# Για Visual Studio 2022 Professional
flutter config --vs2022-path "C:\Program Files\Microsoft Visual Studio\2022\Professional"
```

### Chrome δεν βρέθηκε

Αν έχετε Chrome σε άλλο path:

```powershell
$env:CHROME_EXECUTABLE = "C:\path\to\chrome.exe"
flutter run -d chrome
```

---

## Εγκατάσταση Visual Studio (για Windows desktop)

### Step 1: Download Visual Studio 2022 Community (FREE)

1. **Open this link:** https://visualstudio.microsoft.com/downloads/
2. **Click "Download"** under "Visual Studio 2022 Community"
3. **Run the installer**

### Step 2: Select Required Components

During installation, you MUST select:

✅ **"Desktop development with C++"** workload

This includes:
- MSVC v143 - VS 2022 C++ x64/x86 build tools
- Windows 10/11 SDK (latest version)
- CMake tools for Windows
- C++ core features

### Step 3: Install

1. Click **"Install"**
2. Wait for installation (may take 10-30 minutes depending on internet speed)
3. **Restart your computer** after installation completes

### Step 4: Verify Installation

After restart, open PowerShell and run:

```powershell
cd D:\Projects\SmartGallery
flutter doctor
```

You should see:
- ✅ Visual Studio - develop for Windows (installed)

### Step 5: Enable Developer Mode (if not already done)

1. Press `Win + I` to open Settings
2. Go to **Privacy & Security** → **For developers**
3. Turn on **Developer Mode**
4. Restart Cursor

### Step 6: Run Your App

```powershell
flutter run
```

## Alternative: Build Tools Only (Lighter Install)

If you don't want the full Visual Studio IDE:

1. Download **"Build Tools for Visual Studio 2022"** from the same page
2. Install **"Desktop development with C++"** workload
3. Restart and verify with `flutter doctor`

## Troubleshooting

### If Visual Studio still not detected:

1. Run `flutter doctor -v` to see detailed info
2. Make sure you selected "Desktop development with C++"
3. Try running Visual Studio Installer → Modify → Ensure C++ tools are checked
4. Restart computer

### If you get symlink errors:

- Enable Developer Mode (see Step 5 above)
- Restart Cursor after enabling

## Quick Commands Reference

```powershell
# Check Flutter setup
flutter doctor

# Check detailed setup
flutter doctor -v

# Run app on Windows
flutter run

# List available devices
flutter devices

# Run on web (no Visual Studio needed)
flutter run -d edge
# ή
flutter run -d chrome
```

## Estimated Time

- Download: 5-15 minutes (depends on internet)
- Installation: 10-30 minutes
- **Total: ~20-45 minutes**

## Next Steps After Installation

1. ✅ Visual Studio installed
2. ✅ Developer Mode enabled  
3. ✅ Restart computer
4. ✅ Run `flutter doctor` to verify
5. ✅ Run `flutter run` to launch your app!

---

**Note:** You can develop for Web (`flutter run -d chrome`) without Visual Studio, but Windows desktop apps require it.
