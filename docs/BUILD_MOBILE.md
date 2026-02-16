# Smart Gallery - Οδηγίες Build για Android & iOS

## Android - Γρήγορη Εκκίνηση (με Android Studio εγκατεστημένο)

1. **Ξεκινήστε emulator ή συνδέστε τηλέφωνο** (USB debugging)
2. Τρέξτε:
```powershell
.\run_android.ps1
```

Το script ρυθμίζει αυτόματα το Flutter με το Android SDK και εκκινεί την εφαρμογή.

---

## Android - Ρύθμιση (πρώτη φορά)

Αν χρειάζεστε ρύθμιση χωρίς εκκίνηση:
```powershell
.\setup_android.ps1
```

---

## Android

### Προαπαιτήσεις
- **Android Studio** (με Android SDK)
- **Flutter SDK**

### Βήματα

1. **Εγκατάσταση Android Studio**
   - Κατέβασε: https://developer.android.com/studio
   - Κατά την πρώτη εκκίνηση, εγκατέστησε το Android SDK

2. **Έλεγχος ρύθμισης**
   ```powershell
   flutter doctor
   ```
   Πρέπει να εμφανίζεται: `[✓] Android toolchain`

3. **Build APK**
   ```powershell
   flutter build apk --release
   ```
   Το APK θα βρίσκεται στο: `build/app/outputs/flutter-apk/app-release.apk`

4. **Εκτέλεση σε συσκευή/emulator**
   ```powershell
   flutter run -d android
   ```

### Ρυθμίσεις (ήδη ρυθμισμένες)
- **minSdk**: 21 (Android 5.0+)
- **Δικαιώματα**: Camera, Storage, Location
- **Label**: Smart Gallery

---

## iOS

### Προαπαιτήσεις
- **Mac** με macOS
- **Xcode** (από App Store)
- **Apple Developer account** (για πραγματική συσκευή)

### Βήματα

1. **Εγκατάσταση Xcode**
   - Κατέβασε από App Store
   - Ανοίξτε Xcode και αποδεχτείτε τις άδειες χρήσης

2. **Έλεγχος ρύθμισης**
   ```bash
   flutter doctor
   ```
   Πρέπει να εμφανίζεται: `[✓] Xcode`

3. **Build για iOS**
   ```bash
   flutter build ios --release
   ```

4. **Εκτέλεση σε simulator**
   ```bash
   flutter run -d ios
   ```

5. **Εκτέλεση σε πραγματική συσκευή**
   - Συνδέστε το iPhone
   - Ανοίξτε `ios/Runner.xcworkspace` στο Xcode
   - Επιλέξτε την συσκευή σας
   - Ρυθμίστε το Team στο Signing & Capabilities
   - Πατήστε Run

### Ρυθμίσεις (ήδη ρυθμισμένες)
- **iOS Deployment Target**: 13.0+
- **Δικαιώματα**: Camera, Photo Library, Location
- **Display Name**: Smart Gallery

---

## Σύντομη Αναφορά

| Πλατφόρμα | Εντολή Build | Εντολή Run |
|-----------|--------------|------------|
| Android   | `flutter build apk --release` | `flutter run -d android` |
| iOS       | `flutter build ios --release` | `flutter run -d ios` |

---

## Αντιμετώπιση Προβλημάτων

### Android: "Unable to locate Android SDK"
- Ανοίξτε Android Studio → Settings → Android SDK
- Βεβαιωθείτε ότι το SDK είναι εγκατεστημένο
- Ορίστε: `flutter config --android-sdk <path>`

### iOS: "No valid code signing"
- Ανοίξτε το project στο Xcode
- Επιλέξτε το Team σας στο Signing & Capabilities
- Χρειάζεται Apple Developer account για πραγματική συσκευή

### Camera δεν λειτουργεί
- Ελέγξτε ότι έχετε δώσει δικαιώματα στην εφαρμογή
- Σε emulator: η κάμερα μπορεί να μην λειτουργεί - δοκιμάστε σε πραγματική συσκευή
