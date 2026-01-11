# Smart Gallery - Implementation Plan

## Επισκόπηση

Αυτό το έγγραφο περιγράφει το σχέδιο υλοποίησης για την εφαρμογή Smart Gallery. Η εργασία χωρίζεται μεταξύ 2 συνεργατών με βάση την προσέγγιση Backend/Frontend.

Στόχος: Να ολοκληρωθεί ένα fully functional MVP της εφαρμογής Smart Gallery με όλες τις βασικές λειτουργίες, σύμφωνα με τα wireframes και Figma designs.

---

## Ομάδα & Ευθύνες

### Συνεργάτης Α: Backend & Services
Ευθύνη: Services, database, ML algorithms, business logic

### Συνεργάτης Β: Frontend & UI
Ευθύνη: Screens, widgets, UI components, user experience

---

## Φάσεις Υλοποίησης

### Φάση 1: Database & Data Foundation (Εβδομάδες 1-2)

#### Συνεργάτης Α - Backend Tasks

**1.1 DatabaseService Implementation**
- [x] Αρχικοποίηση SQLite database
  - [x] Platform detection (mobile vs desktop)
  - [x] Database path setup με path_provider
  - [x] Database connection initialization
- [x] Δημιουργία Database Schema
  - photos (id, file_path, thumbnail_path, date_taken, category, location_id, is_favorite, metadata)
  - persons (id, name, face_id, confidence, photo_id, face_coordinates)
  - locations (id, latitude, longitude, address, city, country, place_name)
  - users (id, username, email, profile_image_url, auto_categorize_enabled)
  - photo_persons (photo_id, person_id) -- junction table
- [x] CRUD Operations για Photos
  - [x] insertPhoto(Photo photo) -> int
  - [x] getPhotos({filters}) -> List<Photo>
  - [x] updatePhoto(Photo photo) -> void
  - [x] deletePhoto(int photoId) -> void
  - [x] getPhotosByCategory() -> Map<PhotoCategory, List<Photo>>
- [x] CRUD Operations για Persons
  - [x] getAllPersons() -> List<Person>
  - [x] getPhotosByPerson(int personId) -> List<Photo>
  - [x] upsertPerson(Person person) -> int
  - [x] deletePerson(int personId) -> void
- [x] CRUD Operations για Locations
  - [x] getAllLocations() -> List<Location>
  - [x] getPhotosByLocation(int locationId) -> List<Photo>
  - [x] upsertLocation(Location location) -> int
- [x] User Management - ΟΛΟΚΛΗΡΩΘΗΚΕ
  - [x] getUser(int userId) -> User?
  - [x] updateUser(User user) -> void

**1.2 Models Enhancement**
- [x] Photo model - Tags support added
  - [ ] Map<String, dynamic> toMap()
  - [ ] Photo.fromMap(Map<String, dynamic> map)
  - [ ] Validation methods
- [ ] Person model
  - [ ] Map<String, dynamic> toMap()
  - [ ] Person.fromMap(Map<String, dynamic> map)
- [ ] Location model
  - [ ] Map<String, dynamic> toMap()
  - [ ] Location.fromMap(Map<String, dynamic> map)
- [ ] User model
  - [ ] Map<String, dynamic> toMap()
  - [ ] User.fromMap(Map<String, dynamic> map)

**1.3 Tags System - Database**
- [x] Tags column added to photos table
- [x] Tags storage (comma-separated string)
- [x] Tags parsing in getPhotos()
- [ ] Tags search/filter queries
- [ ] Tag recommendations query (most used tags)

**Deliverables:**
- [x] Fully functional DatabaseService
- [ ] All models με serialization
- [ ] Unit tests για database operations
- [x] Database schema documentation

---

#### Συνεργάτης Β - Frontend Tasks

**1.3 Navigation Structure**
- [x] Bottom Navigation Bar (Home, Albums, Explore)
- [x] MainNavigation screen με IndexedStack
- [ ] Navigation flows μεταξύ screens
- [ ] Back navigation handling

**1.4 HomeScreen - Gallery View**
- [x] Custom header με "Smart Gallery" title + date
- [x] Gallery Grid Layout (3 columns)
- [x] Expandable menu (arrow up/down)
- [ ] Load photos from database
- [ ] Photo thumbnail tap → Navigate to PhotoDetailScreen
- [ ] Filter icon → Open Filter Overlay Menu
- [ ] Sort icon → Open Sort Menu
- [ ] Search icon (when menu expanded) → Navigate to SearchScreen
- [ ] Empty state widget

**1.5 PhotoDetailScreen**
- [x] Full-size photo display
- [x] Custom header με date
- [x] Overlay actions (Edit, Delete, Download) top-right
- [x] Expandable menu (arrow up/down)
- [x] Save button (when menu collapsed)
- [x] Tags section display
- [ ] Load photo data from database
- [ ] Edit action → Open Photo Editor
- [ ] Delete action → Delete photo + return to gallery
- [ ] Download action → Share sheet
- [ ] Save action → Save changes to database
- [ ] Add/Remove tags functionality
- [ ] Back button → Return to previous screen

**1.6 AlbumsScreen**
- [x] Basic screen structure
- [ ] Load albums from database
- [ ] Albums grid/list view
- [ ] Tap album → Navigate to album detail (not shown in wireframes)
- [ ] Custom header με date

**1.7 ExploreScreen**
- [x] Basic screen structure
- [ ] Load all photos from database
- [ ] Gallery grid view (3 columns)
- [ ] Filter & Sort menus (same as HomeScreen)
- [ ] Tap photo → Navigate to PhotoDetailScreen
- [ ] Custom header με date

**1.8 Filter & Sort Menus (Overlay)**
- [ ] Filter Overlay Menu
  - [ ] Date picker option
  - [ ] Location picker option
  - [ ] People picker option
  - [ ] Favorites toggle
  - [ ] Apply filters → Update gallery
- [ ] Sort Menu
  - [ ] Newest First option
  - [ ] Oldest First option
  - [ ] Name (A-Z) option
  - [ ] Name (Z-A) option
  - [ ] Apply sort → Update gallery

**1.9 Tags System - UI**
- [x] Tags display στο PhotoDetailScreen
- [ ] Tag chips με delete functionality
- [ ] Add tag dialog
- [ ] Tag filter functionality
- [ ] Tag menu (Main, Summer, Sunset, Party)
- [ ] Tag recommendations display
- [ ] Filter by tag → Tag filtered gallery

**1.10 Reusable Widgets**
- [ ] PhotoThumbnail widget
  - [ ] Image display
  - [ ] Favorite indicator
  - [ ] Tap to navigate
- [ ] CustomHeader widget (reusable)
  - [ ] Title (left)
  - [ ] Date (center)
  - [ ] Actions (right)
- [ ] FilterMenu widget (overlay)
- [ ] SortMenu widget (overlay)

**Deliverables:**
- [x] Navigation structure (bottom nav)
- [x] HomeScreen skeleton με custom header
- [x] PhotoDetailScreen skeleton με overlay actions
- [x] AlbumsScreen & ExploreScreen skeletons
- [ ] Load data from database
- [ ] Filter & Sort menus
- [ ] Tags UI functionality
- [ ] Navigation flows

---

### Φάση 2: Camera Integration (Εβδομάδες 3-4)

#### Συνεργάτης Α - Backend Tasks

**2.1 CameraService Implementation**
- [ ] Camera Initialization
  - [ ] Request camera permissions
  - [ ] Get available cameras
  - [ ] Initialize camera controller
  - [ ] Handle permissions denied
  - [ ] Platform check (mobile only, desktop fallback)
- [ ] Photo Capture
  - [ ] takePicture() -> String? (returns file path)
  - [ ] Save image to device storage
  - [ ] Generate thumbnail
  - [ ] Error handling
- [ ] Desktop Fallback
  - [ ] File picker integration για desktop
  - [ ] Platform detection
- [ ] Camera Cleanup
  - [ ] dispose() method
  - [ ] Release camera resources

**2.2 GPSService Implementation**
- [ ] Location Permissions
  - [ ] Request location permissions
  - [ ] Handle permission states
  - [ ] Platform check (desktop fallback)
- [ ] Current Location
  - [ ] getCurrentLocation() -> Map<String, double>?
  - [ ] Get latitude/longitude
  - [ ] Error handling (GPS disabled, etc.)
  - [ ] Desktop: IP-based location (optional)
- [ ] Reverse Geocoding
  - [ ] getLocationFromCoordinates(lat, lng) -> Location?
  - [ ] Convert coordinates to address
  - [ ] Get city, country
- [ ] EXIF GPS Data
  - [ ] getPhotoLocation(imagePath) -> Location?
  - [ ] Read EXIF metadata
  - [ ] Extract GPS coordinates

**2.3 Integration Flow**
- [ ] Photo Capture Flow
  - [ ] Take photo -> Get GPS -> Save to database
  - [ ] Auto-attach location metadata
  - [ ] Error handling at each step

**Deliverables:**
- [ ] Functional CameraService
- [ ] Functional GPSService
- [ ] Photo capture με location metadata
- [ ] Desktop fallbacks
- [ ] Unit tests

---

#### Συνεργάτης Β - Frontend Tasks

**2.4 Camera UI Screen**
- [ ] Camera Preview Screen
  - [ ] CameraPreview widget
  - [ ] Full-screen camera view
  - [ ] Camera controls overlay
- [ ] Capture Button
  - [ ] Floating action button
  - [ ] Capture animation
  - [ ] Loading state after capture
- [ ] Camera Controls
  - [ ] Switch camera (front/back)
  - [ ] Flash toggle
  - [ ] Close button
- [ ] Desktop File Picker UI
  - [ ] File picker button
  - [ ] Image selection dialog
- [ ] Integration με HomeScreen
  - [ ] FAB button opens camera
  - [ ] Navigate back after capture
  - [ ] Refresh gallery after new photo

**2.5 Location Display**
- [ ] PhotoDetailScreen Enhancement
  - [ ] Location display section
  - [ ] Address formatting
  - [ ] Map view (optional)
- [ ] HomeScreen Enhancement
  - [ ] Location badge on thumbnails (optional)

**Deliverables:**
- [ ] Functional Camera UI
- [ ] Photo capture flow
- [ ] Location display in UI
- [ ] Desktop file picker UI

---

### Φάση 3: Search & Filtering (Εβδομάδες 5-6)

#### Συνεργάτης Α - Backend Tasks

**3.1 Advanced Database Queries**
- [ ] Search Implementation
  - [x] getPhotos() με multiple filters
  - [x] Category filter
  - [x] Location filter
  - [ ] Person filter (requires join with photo_persons)
  - [x] Date range filter
  - [ ] Text search (filename/metadata)
  - [ ] Tags search/filter
  - [x] Combined filters
- [ ] Query Optimization
  - [ ] Indexes on frequently queried columns
  - [ ] Efficient joins
  - [ ] Person-photo join implementation

**3.2 Search Service (Optional)**
- [ ] Search helper methods
- [ ] Search result ranking
- [ ] Search history (optional)

**Deliverables:**
- [x] Advanced search queries (basic)
- [ ] Person filter implementation
- [ ] Text search
- [ ] Tags search
- [ ] Performance optimization

---

#### Συνεργάτης Β - Frontend Tasks

**3.3 SearchScreen Implementation**
- [x] Search Bar (basic structure)
- [x] Filter icon → Open Filter Overlay Menu
- [ ] Text search functionality
- [ ] Search results grid (3 columns)
- [ ] Empty state
- [ ] Loading state
- [ ] Result count display
- [ ] Tap photo → Navigate to PhotoDetailScreen
- [ ] Filter Overlay Menu (same as HomeScreen)
  - [ ] Date picker
  - [ ] Location picker
  - [ ] People picker
  - [ ] Favorites toggle
- [ ] Apply filters → Update search results

**3.4 Date Grouping**
- [ ] Group photos by date
- [ ] Date headers ("August 2nd 2024", "November 17th 2023")
- [ ] Expand/Collapse date groups
- [ ] Display in HomeScreen & ExploreScreen

**Deliverables:**
- [ ] Fully functional SearchScreen
- [ ] Multiple filter options
- [ ] Search results display

---

### Φάση 4: Gyroscope & Orientation (Εβδομάδα 7)

#### Συνεργάτης Α - Backend Tasks

**4.1 Gyroscope Integration**
- [ ] Sensors Setup
  - [ ] Initialize sensors_plus
  - [ ] Gyroscope stream subscription
  - [ ] Platform check (mobile only)
- [ ] Orientation Detection
  - [ ] getOrientation() -> String? ("portrait" | "landscape")
  - [ ] Device orientation calculation
  - [ ] Threshold values
- [ ] CameraService Enhancement
  - [ ] Integrate orientation detection
  - [ ] Auto-set category based on orientation
  - [ ] Portrait -> PhotoCategory.portrait
  - [ ] Landscape -> PhotoCategory.landscape
- [ ] Desktop Fallback
  - [ ] Return null ή default orientation

**Deliverables:**
- [ ] Gyroscope orientation detection
- [ ] Auto-categorization by orientation
- [ ] Integration with photo capture

---

#### Συνεργάτης Β - Frontend Tasks

**4.2 UI Feedback**
- [ ] Orientation Indicator (Optional)
  - [ ] Show orientation during capture
  - [ ] Visual feedback
- [ ] Category Display
  - [ ] Show auto-detected category
  - [ ] Category badge on thumbnails

**Deliverables:**
- [ ] UI feedback for orientation
- [ ] Category display enhancement

---

### Φάση 5: ML - Photo Categorization (Εβδομάδες 8-9)

#### Συνεργάτης Α - Backend Tasks

**5.1 MLService - Categorization**
- [ ] ML Kit Setup
  - [ ] Google ML Kit integration
  - [ ] Image labeling model
  - [ ] Model initialization
  - [ ] Platform check (mobile only)
- [ ] Photo Categorization
  - [ ] categorizePhoto(imagePath) -> PhotoCategory
  - [ ] Image analysis
  - [ ] Category prediction
  - [ ] Confidence scores
  - [ ] Fallback to "other" category
- [ ] Desktop Fallback
  - [ ] Basic image analysis (optional)
  - [ ] Return "other" category
- [ ] Auto-categorization Flow
  - [ ] Trigger after photo capture
  - [ ] Update photo category in database
  - [ ] Background processing (optional)

**5.2 Batch Processing (Optional)**
- [ ] processPhotosBatch() implementation
- [ ] Process existing photos
- [ ] Progress tracking

**Deliverables:**
- [ ] ML photo categorization
- [ ] Auto-categorization on capture
- [ ] Desktop fallback
- [ ] Category accuracy testing

---

#### Συνεργάτης Β - Frontend Tasks

**5.3 Category UI Enhancements**
- [ ] Category display in PhotoDetailScreen
  - [ ] ML category display
  - [ ] Confidence indicator (optional)
- [ ] Category filter in Filter Menu
- [ ] Category badges on thumbnails (optional)
- [ ] Category grouping in AlbumsScreen (optional)

**5.4 Loading States**
- [ ] Categorization loading indicator
- [ ] Progress feedback

**Deliverables:**
- [ ] Category-based browsing
- [ ] ML category display
- [ ] User feedback for categorization

---

### Φάση 6: ML - Face Recognition (Εβδομάδες 10-11)

#### Συνεργάτης Α - Backend Tasks

**6.1 MLService - Face Detection**
- [ ] Face Detection Setup
  - [ ] Google ML Kit Face Detection
  - [ ] Face detector configuration
  - [ ] Model initialization
  - [ ] Platform check (mobile only)
- [ ] Face Recognition
  - [ ] recognizeFaces(imagePath, photoId) -> List<Person>
  - [ ] Detect faces in photo
  - [ ] Extract face coordinates
  - [ ] Multiple faces support
  - [ ] Confidence scores
- [ ] Desktop Fallback
  - [ ] Return empty list
  - [ ] Optional: Alternative face detection library
- [ ] Face-Photo Relationships
  - [ ] Store face coordinates
  - [ ] Link faces to photos
  - [ ] Person-photo junction table

**6.2 Person Management**
- [ ] Person CRUD operations
- [ ] Face ID tracking
- [ ] Person search by face ID (optional)

**Deliverables:**
- [ ] Face detection functionality
- [ ] Person recognition system
- [ ] Face coordinates storage
- [ ] Desktop fallback

---

#### Συνεργάτης Β - Frontend Tasks

**6.3 Person Tagging UI**
- [ ] PhotoDetailScreen - Person Section
  - [ ] Display detected faces
  - [ ] Face bounding boxes overlay (optional)
  - [ ] Person list with names
  - [ ] "Unknown" labels for untagged faces
- [ ] Add Person Dialog
  - [ ] Text input for person name
  - [ ] Select face (if multiple)
  - [ ] Save person
- [ ] Edit Person
  - [ ] Edit person name
  - [ ] Update person info
- [ ] Person Search
  - [ ] Person filter in SearchScreen
  - [ ] Get photos by person
  - [ ] Person gallery view
- [ ] Desktop UI
  - [ ] Disable face recognition features
  - [ ] Show message "Face recognition available on mobile only"

**6.4 Person Management Screen (Optional)**
- [ ] List all persons
- [ ] Person photo count
- [ ] Delete person
- [ ] Merge persons (advanced)

**Deliverables:**
- [ ] Person tagging interface
- [ ] Face recognition UI
- [ ] Search by person
- [ ] Desktop graceful degradation

---

### Φάση 7: Profile & Settings (Εβδομάδα 12)

#### Συνεργάτης Α - Backend Tasks

**7.1 User Preferences**
- [ ] Category Preferences
  - [ ] Store user preferences
  - [ ] Filter photos by preferences
- [ ] Settings Management
  - [ ] Auto-categorization toggle
  - [ ] Auto-face-detection toggle
  - [ ] Save settings to database

**Deliverables:**
- [ ] User preferences system
- [ ] Settings persistence

---

#### Συνεργάτης Β - Frontend Tasks

**7.2 ProfileScreen Implementation**
- [ ] User Profile Display
  - [ ] Profile picture
  - [ ] Username
  - [ ] Email (if available)
- [ ] Statistics Section
  - [ ] Total photos count
  - [ ] Favorite photos count
  - [ ] Recent photos count
  - [ ] Categories count
- [ ] Category Preferences
  - [ ] Toggle switches per category
  - [ ] Save preferences
- [ ] Settings Section
  - [ ] Auto-categorization toggle
  - [ ] Auto-face-detection toggle
  - [ ] Location services toggle
- [ ] Navigation
  - [ ] Access from HomeScreen
  - [ ] Back navigation

**Deliverables:**
- [ ] Complete ProfileScreen
- [ ] Settings management UI
- [ ] User statistics display

---

### Φάση 8: Polish & Advanced Features (Εβδομάδες 13-14)

#### Κοινές Εργασίες

**8.1 Error Handling**
- [ ] Backend: Error handling σε όλα τα services
- [ ] Frontend: Error messages UI
- [ ] Network error handling
- [ ] Permission error handling
- [ ] Platform-specific error messages

**8.2 Performance Optimization**
- [ ] Image caching
- [ ] Lazy loading για gallery
- [ ] Database query optimization
- [ ] Memory management

**8.3 Testing**
- [ ] Backend: Unit tests για services
- [ ] Frontend: Widget tests
- [ ] Integration tests
- [ ] Manual testing checklist
- [ ] Platform-specific testing (mobile & desktop)

**8.4 Documentation**
- [ ] Code comments
- [ ] API documentation
- [ ] User guide (optional)
- [ ] Setup instructions
- [ ] Platform compatibility notes

**8.5 Advanced Features (Optional)**
- [ ] Photo sharing (Download action)
- [ ] Photo deletion (Delete action)
- [ ] Photo editing (Edit action)
- [ ] Next/Previous photo navigation (swipe gestures)
- [ ] Batch operations
- [ ] Export/Import
- [ ] Neumorphic styling (embossed/debossed buttons)
- [ ] Tag recommendations based on ML
- [ ] Auto-generated albums from ML

---

## Git Workflow

### Branch Strategy

```
main                    # Production-ready code
├── develop             # Integration branch
    ├── feature/backend-*
    ├── feature/frontend-*
    └── feature/integration-*
```

### Workflow Rules

1. Feature Branches
   - Κάθε task σε ξεχωριστό branch
   - Naming: feature/backend-database, feature/frontend-home-screen
   - Merge στο develop μετά από code review

2. Commits
   - Meaningful commit messages
   - Small, frequent commits
   - No commits directly to develop ή main

3. Code Review
   - Κάθε PR review από τον άλλο συνεργάτη
   - Approval required before merge

4. Sync Meetings
   - Weekly sync (30 min)
   - Discuss progress, blockers, dependencies
   - Plan next week

---

## Dependencies & Integration Points

### Critical Dependencies

1. Database → UI
   - Frontend needs DatabaseService methods
   - Solution: Backend defines API first, Frontend uses mock data

2. Camera → Database
   - CameraService saves to DatabaseService
   - Solution: Backend implements both, Frontend just calls

3. ML → UI
   - ML results displayed in UI
   - Solution: Backend provides results, Frontend displays

4. GPS → Photo
   - GPS metadata attached to photos
   - Solution: Backend handles integration, Frontend displays

### Integration Checklist

- [x] DatabaseService ready → Frontend can integrate
- [ ] CameraService ready → Frontend can build camera UI
- [ ] GPSService ready → Frontend can display locations
- [ ] MLService ready → Frontend can show categories/persons
- [ ] All services tested → Full integration testing

---

## Testing Strategy

### Backend Testing
- [ ] Unit tests για κάθε service
- [ ] Database operations tests
- [ ] ML algorithm tests
- [ ] Error handling tests
- [ ] Platform detection tests

### Frontend Testing
- [ ] Widget tests για screens
- [ ] Navigation tests
- [ ] UI interaction tests
- [ ] Integration tests με mock services

### Manual Testing
- [ ] Photo capture flow
- [ ] Search functionality
- [ ] Face recognition flow
- [ ] Location features
- [ ] Category browsing
- [ ] Profile settings
- [ ] Desktop compatibility
- [ ] Mobile compatibility

---

## Platform Compatibility

### Mobile (Android/iOS)
- Database: Fully supported
- Camera: Fully supported
- GPS: Fully supported
- Face Recognition: Fully supported (ML Kit)
- Gyroscope: Fully supported
- Image Picker: Fully supported

### Desktop (Windows/Linux/macOS)
- Database: Fully supported (sqflite_common_ffi)
- Camera: Fallback to file picker (needs implementation)
- GPS: Limited support (IP-based, optional)
- Face Recognition: Not supported (ML Kit mobile-only)
- Gyroscope: Not supported (mobile-only)
- Image Picker: Fully supported (file picker)

### Platform Checks Needed
- [ ] CameraService: Platform detection + file picker fallback
- [ ] MLService: Platform detection + graceful degradation
- [ ] GPSService: Platform detection + optional desktop support
- [ ] UI: Hide/disable mobile-only features on desktop

---

## Timeline Summary

| Φάση | Εβδομάδες | Backend Focus | Frontend Focus |
|------|-----------|---------------|----------------|
| 1. Database | 1-2 | DatabaseService, Models, Tags | Navigation, HomeScreen, PhotoDetailScreen, AlbumsScreen, ExploreScreen, Filter/Sort Menus |
| 2. Camera | 3-4 | CameraService, GPSService | Camera UI, Location Display |
| 3. Search | 5-6 | Advanced Queries, Tags Search | SearchScreen, Date Grouping |
| 4. Gyroscope | 7 | Orientation Detection | UI Feedback |
| 5. ML Categorization | 8-9 | MLService Categorization | Category UI |
| 6. Face Recognition | 10-11 | MLService Face Detection | Person Tagging UI |
| 7. Profile | 12 | User Preferences | ProfileScreen |
| 8. Polish | 13-14 | Error Handling, Testing | Error Handling, Testing, Neumorphic Styling |

Total: 14 εβδομάδες (3.5 μήνες)

---

## Success Criteria

### MVP Requirements
- Photo capture με camera (mobile) / file picker (desktop)
- Photo storage σε database
- Gallery view με categories
- Search με filters
- Location metadata
- Basic ML categorization
- Face recognition & tagging (mobile only)
- Profile & settings

### Quality Requirements
- No critical bugs
- Smooth user experience
- Proper error handling
- Code documentation
- Test coverage > 60%
- Platform compatibility (mobile + desktop)

---

## Navigation Flow Summary

### Main Flows από Wireframes:

**HomeScreen → PhotoDetailScreen**
- Tap photo thumbnail → Navigate to PhotoDetailScreen
- Filter icon → Open Filter Overlay Menu → Apply filters → Update gallery
- Sort icon → Open Sort Menu → Apply sort → Update gallery
- Search icon → Navigate to SearchScreen

**PhotoDetailScreen Actions**
- Arrow up/down → Toggle menu (expand/collapse actions)
- Edit → Open Photo Editor
- Delete → Delete photo + Return to gallery
- Download → Share sheet
- Save → Save changes + Return to gallery
- Tag chip → Filter by tag → Tag filtered gallery
- Add tag → Add Tag Dialog → Update photo

**Filter & Sort Menus**
- Date → Date Picker → Filtered View
- Location → Location Picker → Filtered View
- People → People Picker → Filtered View
- Favorites → Toggle → Filtered View
- Sort options → Sorted View

**Tag System**
- Tag chip → Tag Filtered Gallery
- Tag menu → Select tag → Filtered View
- Add tag → Add Tag Dialog → Update photo

## Notes

- Communication: Daily standup (10 min) για sync
- Blockers: Report immediately, don't wait
- Documentation: Update as you go, don't leave for the end
- Testing: Test each feature before moving to next
- Code Quality: Follow Flutter best practices, use linter
- Platform Awareness: Always consider mobile AND desktop compatibility
- Wireframes: Follow the navigation flows and UI patterns from wireframes

---

## Resources

- Flutter Documentation: https://docs.flutter.dev/
- SQLite with Flutter: https://docs.flutter.dev/cookbook/persistence/sqlite
- Google ML Kit: https://developers.google.com/ml-kit
- Camera Plugin: https://pub.dev/packages/camera
- Todotoday Examples: ../Παρουσιάσεις και υλικό εργαστηρίου/
- Platform-Specific Code: https://docs.flutter.dev/platform-integration/platform-channels

---

Last Updated: 2025-01-11
Version: 2.0
Status: In Progress - Updated με wireframes & navigation flows
