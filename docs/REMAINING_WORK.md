# Smart Gallery - Remaining Work

Brief checklist of what's still needed for full functionality, with file locations and descriptions.

---

## 1. Database Initialization

**File:** `lib/main.dart`  
**Location:** Lines 26-29 (uncomment block)

**What to do:** Uncomment the database initialization so the app creates/opens the SQLite database on startup.

**Functionality:** Ensures the database exists before any screen tries to read or write data. Without this, `DatabaseService.getPhotos()` and other calls will fail.

---

## 2. Photo Display (File Paths vs Assets)

**Files:**
- `lib/screens/home_screen.dart` — `_buildPhotoThumbnail()` (lines ~206-235)
- `lib/screens/photo_detail_screen.dart` — photo display in `build()` (lines ~47-56)
- `lib/screens/explore_screen.dart` — `_buildPhotoThumbnail()` (lines ~114-131)
- `lib/screens/search_screen.dart` — `_buildPhotoThumbnail()` (lines ~191-208)

**What to do:** Replace `Image.asset(photo.filePath)` with `Image.file(File(photo.filePath))` for photos loaded from the database.

**Functionality:** `Image.asset()` expects asset paths (e.g. `assets/icons/...`). Photos from the database use file paths (e.g. `/data/.../photos/photo_123.jpg`). Use `Image.file()` for those paths and add `dart:io` for `File`.

---

## 3. Camera Integration

**File:** `lib/screens/camera_screen.dart`  
**Current:** Placeholder screen with static content.

**What to do:**
- Use `CameraPreview` from the `camera` package with `CameraService`.
- Add a capture button that calls `CameraService.takePicture()`.
- After capture, save the photo to the database via `DatabaseService.insertPhoto()`.
- On desktop, use `image_picker` as a fallback instead of the camera.

**Functionality:** Real camera preview, capture, and saving to storage and database. Desktop uses file picker instead of camera.

---

## 4. CameraService → Database

**File:** `lib/services/camera_service.dart`  
**Location:** `takePicture()` method (lines ~45-75)

**What to do:** After saving the image file, create a `Photo` object and call `DatabaseService.insertPhoto()`. Optionally use `GPSService` for location and `MLService` for category.

**Functionality:** Ensures captured photos are stored in the database so they appear in the gallery.

---

## 5. PhotoDetailScreen Actions

**File:** `lib/screens/photo_detail_screen.dart`

| Action | Method | What to do |
|--------|--------|------------|
| **Delete** | `_deletePhoto()` (lines ~250-269) | Call `DatabaseService.deletePhoto(photo.id)`, delete the file with `File(photo.filePath).deleteSync()`, then `Navigator.pop(context)`. |
| **Save** | `_savePhoto()` (lines ~279-284) | Build updated `Photo` with current `_tags` and `isFavorite`, call `DatabaseService.updatePhoto()`, then `Navigator.pop(context)`. |
| **Download/Share** | `_downloadPhoto()` (lines ~272-276) | Use `share_plus` to share the file at `photo.filePath`. |
| **Edit** | `_editPhoto()` (lines ~242-247) | Open a simple editor or placeholder screen; optional for MVP. |

**Functionality:** All actions perform real operations on the database and files, and update the UI/navigation accordingly.

---

## 6. Tags Persistence

**File:** `lib/screens/photo_detail_screen.dart`  
**Locations:**
- `_buildTagsSection()` — `onDeleted` callback (line ~218)
- `_addTag()` — after adding tag (line ~311)

**What to do:** When adding or removing tags, call `DatabaseService.updatePhoto()` with the updated `Photo` object (including the new `tags` list).

**Functionality:** Tag changes are persisted so they survive app restarts.

---

## 7. Filter & Sort Menus

**Files:**
- `lib/screens/home_screen.dart` — `_showFilterMenu()`, `_showSortMenu()`, `_buildFilterOption()`, `_buildSortOption()`
- `lib/screens/explore_screen.dart` — same methods
- `lib/screens/search_screen.dart` — `_buildFilterOverlay()`, `_performSearch()`

**What to do:** When a filter or sort option is chosen, call `DatabaseService.getPhotos()` with the right parameters (e.g. `category`, `locationId`, `personId`, `startDate`, `endDate`, `favoritesOnly`) and update the displayed list. For sort, reorder the list by date or filename before display.

**Functionality:** Filters and sorting actually change which photos are shown and in what order.

---

## 8. Search Implementation

**File:** `lib/screens/search_screen.dart`  
**Method:** `_performSearch()` (lines ~235-242)

**What to do:** Call `DatabaseService.getPhotos()` with filters from `_searchController.text`, `_selectedCategory`, `_selectedLocation`, `_selectedPerson`, `_startDate`, `_endDate`, `_favoritesOnly`. Store the result in `_searchResults` and call `setState()`.

**Functionality:** Search bar and filters produce real search results from the database.

---

## 9. ExploreScreen Data Loading

**File:** `lib/screens/explore_screen.dart`  
**Location:** `initState()` (lines ~21-24)

**What to do:** Import `DatabaseService`, create an instance, and in `initState()` call `getPhotos()` and assign the result to `_allPhotos`. Add `Navigator.push` to `PhotoDetailScreen` in `_buildPhotoThumbnail` `onTap`.

**Functionality:** Explore tab shows all photos from the database and opens detail on tap.

---

## 10. AlbumsScreen Data Loading

**File:** `lib/screens/albums_screen.dart`  
**Location:** `initState()` (lines ~26-29)

**What to do:** Load albums from the database. Use `DatabaseService.getPhotosByCategory()` to group photos by category and build album entries (name, count, thumbnail). Populate `_albums` and call `setState()`.

**Functionality:** Albums tab shows real albums (e.g. by category) instead of an empty list.

---

## 11. HomeScreen Filter/Sort Wiring

**File:** `lib/screens/home_screen.dart`  
**Methods:** `_showFilterMenu()`, `_showSortMenu()` (lines ~238-282)

**What to do:** In `_buildFilterOption` and `_buildSortOption` `onTap`, apply the selected filter/sort, call `_databaseService.getPhotos()` with filters, sort the result, update `_filteredPhotos`, and call `setState()`.

**Functionality:** Filter and sort menus on Home actually change the displayed photos.

---

## 12. Sample Data (Optional)

**File:** `lib/main.dart` or new `lib/services/seed_service.dart`

**What to do:** On first launch (e.g. when DB is empty), insert 3–5 sample `Photo` records with file paths to bundled assets or sample images. Ensures the app has content for testing and demos.

**Functionality:** App starts with a non-empty gallery for evaluation and demos.

---

## 13. AlbumsScreen Syntax Check

**File:** `lib/screens/albums_screen.dart`  
**Location:** Around line 287

**What to do:** Verify brace structure. There may be an extra `}` that closes the class too early; remove it if present.

**Functionality:** Ensures the file compiles and the class structure is correct.

---

## Summary Table

| # | File | Block/Method | Purpose |
|---|------|--------------|---------|
| 1 | main.dart | Database init | Start DB on app launch |
| 2 | home_screen, photo_detail_screen, explore_screen, search_screen | Photo display | Show DB photos with `Image.file` |
| 3 | camera_screen.dart | Full screen | Real camera + capture + save |
| 4 | camera_service.dart | takePicture() | Save photo to DB after capture |
| 5 | photo_detail_screen.dart | Delete, Save, Download, Edit | Implement actions |
| 6 | photo_detail_screen.dart | Tags callbacks | Persist tags to DB |
| 7 | home_screen, explore_screen, search_screen | Filter/Sort menus | Apply filters and sort |
| 8 | search_screen.dart | _performSearch() | Query DB with filters |
| 9 | explore_screen.dart | initState() | Load photos from DB |
| 10 | albums_screen.dart | initState() | Load albums from DB |
| 11 | home_screen.dart | Filter/Sort onTap | Wire menus to DB |
| 12 | main.dart or seed_service | First-run logic | Insert sample photos |
| 13 | albums_screen.dart | Braces | Fix structure if needed |
