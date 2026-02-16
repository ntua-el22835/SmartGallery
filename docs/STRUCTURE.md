# Smart Gallery - Project Structure

## Περιγραφή
Αυτή είναι η δομή του έργου Smart Gallery, οργανωμένη σύμφωνα με τα patterns από τα παραδείγματα του καθηγητή (todotoday-part1, todotoday-part2).

## Περιγραφή Εφαρμογής

**Smart Gallery** είναι μια εφαρμογή που απλοποιεί την ταξινόμηση και αναζήτηση φωτογραφιών στο κινητό τηλεφώνιο. Ο χρήστης μπορεί να φιλτράρει την αναζήτηση του σύμφωνα με συγκεκριμένα κριτήρια (πρόσωπα, τοποθεσία, κατηγορία) και να βρίσκει γρήγορα αυτό που ψάχνει.

**Promo/Punchline:** A trip down the memory lane

**Κατηγορία:** Photography

## Δομή Φακέλων

```
lib/
├── main.dart                 # Entry point της εφαρμογής
├── models/                   # Data models
│   ├── photo.dart            # Model για φωτογραφίες
│   ├── person.dart           # Model για αναγνωρισμένα πρόσωπα
│   ├── location.dart         # Model για τοποθεσίες
│   └── user.dart             # Model για χρήστες
├── services/                  # Business logic services
│   ├── database_service.dart    # SQLite database operations
│   ├── camera_service.dart       # Camera operations & photo capture
│   ├── ml_service.dart           # Machine Learning (photo categorization, face recognition)
│   └── gps_service.dart         # GPS location services
├── screens/                  # UI Screens
│   ├── home_screen.dart          # Αρχική οθόνη (gallery view, categories)
│   ├── search_screen.dart        # Αναζήτηση φωτογραφιών (filters)
│   ├── photo_detail_screen.dart  # Λεπτομέρειες φωτογραφίας
│   └── profile_screen.dart       # Προφίλ χρήστη
├── widgets/                  # Reusable UI components
│   └── (θα προστεθούν αργότερα)
└── utils/                    # Utility functions
    └── (θα προστεθούν αργότερα)
```

## Λειτουργικότητες (ανά άξονα)

### 1. Machine Learning & Κατηγοριοποίηση
- **MLService**: Αλγόριθμος ML για κατηγοριοποίηση φωτογραφιών
- **Photo Model**: Κατηγορίες (portraits, landscapes, objects, etc.)
- Αυτόματη ομαδοποίηση φωτογραφιών

### 2. Camera & Face Recognition
- **CameraService**: Λήψη φωτογραφιών
- **Gyroscope**: Διαχωρισμός portraits/landscapes
- **MLService**: AI για αναγνώριση προσώπων
- **Person Model**: Αποθήκευση ονομάτων προσώπων

### 3. Location-based Grouping
- **GPSService**: Ανάκτηση τοποθεσίας φωτογραφίας
- **Location Model**: Ομαδοποίηση φωτογραφιών βάσει τοποθεσίας
- **Photo Model**: Metadata τοποθεσίας

## Dependencies

### Database
- `sqflite`: SQLite για mobile/desktop
- `sqflite_common_ffi`: Desktop support
- `path_provider`: File paths

### Camera & Image Processing
- `camera`: Camera access
- `image_picker`: Photo selection from gallery
- `google_mlkit_face_detection`: Face recognition

### Location
- `geolocator`: GPS services
- `geocoding`: Reverse geocoding

### Sensors
- `sensors_plus`: Gyroscope access

### Other
- `logging`: Application logging
- `path`: File path operations

## Next Steps

1. **Database Setup**: Υλοποίηση DatabaseService με SQLite για photos
2. **UI Implementation**: Ολοκλήρωση των screens με gallery widgets
3. **ML Integration**: Υλοποίηση ML algorithms για categorization και face recognition
4. **Camera Integration**: Υλοποίηση photo capture με gyroscope support
5. **Location Integration**: GPS metadata για photos

## Notes

- Όλα τα αρχεία είναι σκελετοί (skeletons) με TODO comments
- Η δομή ακολουθεί τα patterns από τα παραδείγματα todotoday
- Χρησιμοποιείται `WidgetsFlutterBinding.ensureInitialized()` όπως στα παραδείγματα
