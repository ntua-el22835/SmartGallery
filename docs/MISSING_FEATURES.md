# Εκκρεμείς Λειτουργίες – Smart Gallery

Λίστα με τις λειτουργίες που λείπουν από το Figma design και μπορούν να υλοποιηθούν.

---

## 1. Ενσωμάτωση ML κατά την αποθήκευση φωτογραφίας ✅ ΥΛΟΠΟΙΗΘΗΚΕ

**Περιγραφή:** Κατά την αποθήκευση φωτογραφίας, το ML algorithm κατηγοριοποιεί αυτόματα την εικόνα σε 3 κατηγορίες: portrait (1 πρόσωπο), landscape (0 πρόσωπα), group (2+ πρόσωπα). Οι φωτογραφίες αποθηκεύονται σε διαφορετικούς φακέλους (photos/portrait/, photos/landscape/, photos/group/).

**Τρέχουσα κατάσταση:** Υλοποιήθηκε στο `CameraScreen._savePhotoToDatabase()`, `MLService.categorizePhoto()`, `CameraService.moveToCategoryFolder()`.

**Υλοποίηση:**
- Στο `CameraScreen._savePhotoToDatabase()`: κλήση `MLService.categorizePhoto(imagePath)` πριν την αποθήκευση.
- Χρήση της επιστρεφόμενης κατηγορίας αντί για `PhotoCategory.other`.
- Διόρθωση `InputImageFormat` στο `ml_service.dart` (χρήση `InputImage.fromFilePath()` για JPEG αρχεία).

**Αρχεία:** `lib/screens/camera_screen.dart`, `lib/services/ml_service.dart`

---

## 2. Χρήση γυροσκοπίου για portrait/landscape (Προαιρετικό)

**Περιγραφή:** Κατά τη λήψη φωτογραφίας, το gyroscope να καθορίζει αν η φωτογραφία είναι portrait ή landscape.

**Τρέχουσα κατάσταση:** Το `CameraService.getOrientation()` υπάρχει. Η κατηγοριοποίηση γίνεται πλέον με ML (περιεχόμενο) που είναι πιο ακριβής.

**Υλοποίηση:**
- Στο `CameraScreen._savePhotoToDatabase()` ή στο `CameraService.takePicture()`: κλήση `getOrientation()` μετά τη λήψη.
- Αν `orientation == "landscape"` και η ML επιστρέψει `other`, χρήση `PhotoCategory.landscape`.
- Αν `orientation == "portrait"` και η ML επιστρέψει face, χρήση `PhotoCategory.portrait`.

**Αρχεία:** `lib/screens/camera_screen.dart`, `lib/services/camera_service.dart`

---

## 3. Εισαγωγή ονομάτων προσώπων ✅ ΥΛΟΠΟΙΗΘΗΚΕ

**Περιγραφή:** Μετά την ανίχνευση προσώπων σε μια φωτογραφία, ο χρήστης μπορεί να εισάγει τα ονόματά τους.

**Τρέχουσα κατάσταση:** Υλοποιήθηκε στο `PhotoDetailScreen` – αυτόματη ανίχνευση προσώπων, εμφάνιση ως chips, επεξεργασία ονόματος με dialog, αποθήκευση στη βάση.

**Υλοποίηση:**
- Στο `PhotoDetailScreen`: εμφάνιση αναγνωρισμένων προσώπων (π.χ. "Unknown 1", "Unknown 2").
- Κάθε πρόσωπο να έχει επιλογή "Επεξεργασία" για εισαγωγή ονόματος.
- Αποθήκευση ονομάτων στη βάση (πίνακας `persons` ή `recognized_persons`).
- Προαιρετικά: κλήση `recognizeFaces()` κατά το άνοιγμα της φωτογραφίας αν δεν υπάρχουν ήδη πρόσωπα.

**Αρχεία:** `lib/screens/photo_detail_screen.dart`, `lib/services/ml_service.dart`, `lib/services/database_service.dart`, `lib/models/person.dart`

---

## 4. Φόρτωση albums από τη βάση δεδομένων ✅ ΥΛΟΠΟΙΗΘΗΚΕ

**Περιγραφή:** Το `AlbumsScreen` φορτώνει albums/συλλογές από τη βάση δεδομένων.

**Τρέχουσα κατάσταση:** Υλοποιήθηκε – `DatabaseService.getAlbums()`, `getPhotosForAlbum()`, AlbumsScreen φορτώνει και εμφανίζει albums ανά κατηγορία και tag. Tap ανοίγει grid φωτογραφιών.

**Υλοποίηση:**
- Προσθήκη μεθόδου `getAlbums()` ή `getGroupedPhotos()` στο `DatabaseService`.
- Ομαδοποίηση φωτογραφιών ανά κατηγορία, ημερομηνία, τοποθεσία ή tags.
- Φόρτωση στο `AlbumsScreen.initState()` και ενημέρωση του `_albums`.
- Εμφάνιση κάθε album ως κάρτα με thumbnail και αριθμό φωτογραφιών.

**Αρχεία:** `lib/screens/albums_screen.dart`, `lib/services/database_service.dart`

---

## 5. Discover Page / ExploreScreen

**Περιγραφή:** Οθόνη "Discover" με swipeable single-photo view ("Next photo") όπως στο Figma.

**Τρέχουσα κατάσταση:** Το `ExploreScreen` υπάρχει αλλά είναι grid (όμοιο με Home) και δεν χρησιμοποιείται στο main navigation.

**Υλοποίηση:**
- Επιλογή Α: Προσθήκη `ExploreScreen` ως 4ο tab ή αντικατάσταση του Home σε κάποια κατάσταση.
- Επιλογή Β: Μετατροπή `ExploreScreen` σε PageView με μία φωτογραφία ανά οθόνη και swipe για "Next photo".
- Επιλογή Γ: Νέο `DiscoverScreen` με PageView και ενσωμάτωση στο navigation.

**Αρχεία:** `lib/screens/explore_screen.dart`, `lib/screens/main_navigation.dart`, πιθανόν νέο `lib/screens/discover_screen.dart`

---

## 6. Profile Screen – φόρτωση δεδομένων ✅ ΥΛΟΠΟΙΗΘΗΚΕ

**Περιγραφή:** Οθόνη προφίλ χρήστη με δεδομένα από τη βάση.

**Τρέχουσα κατάσταση:** Υλοποιήθηκε – `getOrCreateDefaultUser()`, ProfileScreen φορτώνει προφίλ, στατιστικά (φωτογραφίες, αγαπημένα), προτιμήσεις κατηγοριών, ρυθμίσεις. Προστέθηκε ως 5ο tab στο main navigation.

**Υλοποίηση:**
- Προσθήκη πίνακα `users` ή `user_profile` στη βάση (αν δεν υπάρχει).
- Μέθοδος `getUserProfile()` στο `DatabaseService`.
- Φόρτωση στο `ProfileScreen` και εμφάνιση στοιχείων (όνομα, αριθμός φωτογραφιών, κλπ.).

**Αρχεία:** `lib/screens/profile_screen.dart`, `lib/services/database_service.dart`

---

## Σύνοψη προτεραιότητας

| # | Λειτουργία | Δυσκολία | Επίδραση |
|---|------------|----------|----------|
| 1 | ML ενσωμάτωση | Μέτρια | Υψηλή |
| 2 | Gyroscope | Χαμηλή | Μέτρια |
| 3 | Ονόματα προσώπων | Μέτρια | Υψηλή |
| 4 | Albums από DB | Μέτρια | Υψηλή |
| 5 | Discover Page | Μέτρια | Μέτρια |
| 6 | Profile Screen | Χαμηλή | Χαμηλή |
