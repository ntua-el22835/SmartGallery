# Backend / Frontend Διαίρεση Αρχείων

Αυτό το έγγραφο ορίζει ποια αρχεία ανήκουν στον Backend developer και ποια στον Frontend developer.

---

## Backend Developer

### Models (Data Structures)
- `lib/models/photo.dart`
- `lib/models/person.dart`
- `lib/models/location.dart`
- `lib/models/user.dart`

**Ευθύνη:**
- Ορισμός properties
- Serialization methods (toMap, fromMap)
- Validation logic

---

### Services (Business Logic)
- `lib/services/database_service.dart`
- `lib/services/camera_service.dart`
- `lib/services/gps_service.dart`
- `lib/services/ml_service.dart`

**Ευθύνη:**
- Database operations (CRUD, queries)
- Camera integration
- GPS location services
- Machine Learning (categorization, face recognition)
- Platform detection (mobile vs desktop)

---

## Frontend Developer

### Entry Point
- `lib/main.dart`

**Ευθύνη:**
- Flutter initialization
- MaterialApp setup
- Theme integration
- Navigation setup

---

### Screens (UI)
- `lib/screens/main_navigation.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/photo_detail_screen.dart`
- `lib/screens/albums_screen.dart`
- `lib/screens/explore_screen.dart`
- `lib/screens/search_screen.dart`
- `lib/screens/profile_screen.dart`

**Ευθύνη:**
- UI layout και design
- User interactions
- Navigation flows
- Data display (χρησιμοποιώντας services)
- Filter/Sort menus
- Empty states, loading states

---

### Theme
- `lib/theme/app_theme.dart`

**Ευθύνη:**
- Colors, typography
- Component styling
- Dark theme configuration

---

### Widgets (Future)
- `lib/widgets/*.dart` (αν υλοποιηθούν)

**Ευθύνη:**
- Reusable UI components
- Custom widgets

---

### Utils (Future)
- `lib/utils/*.dart` (αν υλοποιηθούν)

**Ευθύνη:**
- Helper functions για UI
- Formatting utilities

---

## Platform-Specific Files

### Android
- `android/app/src/main/AndroidManifest.xml` - Backend (permissions)
- `android/app/src/main/kotlin/` - Backend (αν χρειαστεί native code)

### iOS
- `ios/Runner/Info.plist` - Backend (permissions)
- `ios/Runner/` - Backend (αν χρειαστεί native code)

### Desktop (Windows/Linux/macOS)
- `windows/`, `linux/`, `macos/` - Backend (platform configuration)

---

## Dependencies

### Backend → Frontend
- Backend παρέχει services με public methods
- Frontend καλεί services για data

### Frontend → Backend
- Frontend χρησιμοποιεί models (read-only)
- Frontend καλεί service methods

---

## Workflow

1. Backend ορίζει models πρώτα
2. Backend υλοποιεί services
3. Frontend χρησιμοποιεί mock data αρχικά
4. Integration: Frontend αντικαθιστά mock με service calls

---

## Σύνοψη

**Backend (4 models + 4 services):**
- Models: photo, person, location, user
- Services: database, camera, gps, ml

**Frontend (1 main + 7 screens + 1 theme):**
- Main: main.dart
- Screens: main_navigation, home, photo_detail, albums, explore, search, profile
- Theme: app_theme

---

Last Updated: 2025-01-11

