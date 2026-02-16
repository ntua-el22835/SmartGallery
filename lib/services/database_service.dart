import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/models/person.dart';
import 'package:smartgallery/models/location.dart';
import 'package:smartgallery/models/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'dart:convert'; // για jsonEncode/jsonDecode

// Εισαγωγές για database - sqflite_common_ffi λειτουργεί σε Android, iOS, Windows, Linux
// Web: stub για αποφυγή σφαλμάτων μεταγλώττισης
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.html) 'package:sqflite_common_ffi_stub/sqflite_ffi_stub.dart';

/// Service για τη διαχείριση της βάσης δεδομένων SQLite
///
/// Περιέχει: CRUD για φωτογραφίες, πρόσωπα, τοποθεσίες, χρήστες.
/// Χρησιμοποιεί sqflite (mobile) ή sqflite_common_ffi (desktop).
class DatabaseService {
  final log = Logger('DatabaseServiceLogger');
  Database? _database;
  String dbfile = "smartgallery.db";

  /// Ανάκτηση instance της βάσης δεδομένων
  Future<Database> get database async {
    if (_database != null) {
      log.config("Κλήση get database, επιστροφή υπάρχοντος instance");
      return _database!;
    }
    _database = await initDB(); // Αρχικοποίηση της βάσης δεδομένων
    log.config("get database called, return initDB");
    return _database!;
  }

  /// Αρχικοποίηση database με platform detection
  /// 
  /// Mobile (Android/iOS): Χρησιμοποιεί sqflite
  /// Desktop (Windows/Linux): Χρησιμοποιεί sqflite_common_ffi
  Future<Database> initDB() async {
    log.config("Κλήση initDB, Πλατφόρμα: ${Platform.operatingSystem}");
    
    if (Platform.isWindows || Platform.isLinux) {
      // Desktop: Χρήση sqflite_common_ffi
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentsDir.path, "databases", dbfile);
      
      return await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          onCreate: _onCreate,
          version: 1,
        ),
      );
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      // Mobile (Android/iOS/macOS): Χρήση κανονικού sqflite
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, dbfile);
      
      // Άνοιγμα της βάσης δεδομένων
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
    throw Exception("Unsupported platform: ${Platform.operatingSystem}"); // Πετάει error αν το platform δεν υποστηρίζεται
  }

  /// Δημιουργία tables
  Future<void> _onCreate(Database db, int version) async {
    log.config("Κλήση _onCreate, έκδοση: $version");
    
    // Photos table
    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        thumbnail_path TEXT,
        date_taken INTEGER NOT NULL,
        category TEXT NOT NULL,
        location_id INTEGER,
        is_favorite INTEGER DEFAULT 0,
        tags TEXT,
        metadata TEXT,
        FOREIGN KEY (location_id) REFERENCES locations(id)
      )
    ''');
    
    // Πίνακας προσώπων
    await db.execute('''
      CREATE TABLE persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        face_id TEXT,
        confidence REAL,
        photo_id INTEGER NOT NULL,
        face_coordinates TEXT,
        FOREIGN KEY (photo_id) REFERENCES photos(id)
      )
    ''');
    
    // Πίνακας τοποθεσιών
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        city TEXT,
        country TEXT,
        place_name TEXT
      )
    ''');
    
    // Πίνακας χρηστών
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT,
        profile_image_url TEXT,
        favorite_photo_ids TEXT,
        recent_photo_ids TEXT,
        category_preferences TEXT,
        auto_categorize_enabled INTEGER DEFAULT 1
      )
    ''');
    
    // Πίνακας σύνδεσης φωτογραφιών-προσώπων (πολλά-προς-πολλά)
    await db.execute('''
      CREATE TABLE photo_persons (
        photo_id INTEGER NOT NULL,
        person_id INTEGER NOT NULL,
        PRIMARY KEY (photo_id, person_id),
        FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE,
        FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
      )
    ''');
    
    log.config("Database tables created successfully");
  }

  
  // Μέθοδοι για τις φωτογραφίες
  
  /// Ανάκτηση φωτογραφιών από τη βάση δεδομένων με filters
  /// Μπορεί να φιλτραριστεί βάσει κατηγορίας, τοποθεσίας, προσώπου, κλπ.
  Future<List<Photo>> getPhotos({
    PhotoCategory? category,
    int? locationId,
    int? personId,
    DateTime? startDate,
    DateTime? endDate,
    bool? favoritesOnly,
  }) async {
    final db = await database;
    var query = 'SELECT * FROM photos WHERE 1=1';
    List<dynamic> args = [];
    
    if (category != null) {
      query += ' AND category = ?';
      args.add(category.toString().split('.').last);
    }
    
    if (locationId != null) {
      query += ' AND location_id = ?';
      args.add(locationId);
    }
    
    if (personId != null) {
      query += ' AND id IN (SELECT photo_id FROM photo_persons WHERE person_id = ?)';
      args.add(personId);
    }
    
    if (favoritesOnly == true) {
      query += ' AND is_favorite = 1';
    }
    
    if (startDate != null) {
      query += ' AND date_taken >= ?';
      args.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      query += ' AND date_taken <= ?';
      args.add(endDate.millisecondsSinceEpoch);
    }
    
    query += ' ORDER BY date_taken DESC';
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    
    // Φόρτωση related persons και locations για κάθε φωτογραφία
    final List<Photo> photos = [];
    
    for (var map in maps) {
      // Ανάλυση tags από comma-separated string
      List<String> tags = [];
      if (map['tags'] != null && map['tags'].toString().isNotEmpty) {
        try {
          tags = List<String>.from(
            map['tags'].toString().split(',').map((t) => t.trim()).where((t) => t.isNotEmpty)
          );
        } catch (e) {
          log.warning("Σφάλμα ανάλυσης tags: $e");
        }
      }
      
      // Φόρτωση location
      Location? location;
      if (map['location_id'] != null) {
        final locationMaps = await db.query(
          'locations',
          where: 'id = ?',
          whereArgs: [map['location_id']],
        );
        if (locationMaps.isNotEmpty) {
          location = Location.fromMap(locationMaps.first);
        }
      }

      // Φόρτωση persons για αυτή τη φωτογραφία
      final personMaps = await db.rawQuery('''
        SELECT p.* FROM persons p
        INNER JOIN photo_persons pp ON p.id = pp.person_id
        WHERE pp.photo_id = ?
      ''', [map['id']]);
      final persons = personMaps.map((pMap) => Person.fromMap(pMap)).toList();

      // Ανάλυση metadata από JSON string
      Map<String, dynamic>? metadata;
      if (map['metadata'] != null && map['metadata'].toString().isNotEmpty) {
        try {
          metadata = jsonDecode(map['metadata'] as String) as Map<String, dynamic>;
        } catch (e) {
          log.warning("Σφάλμα ανάλυσης metadata: $e");
        }
      }

      photos.add(Photo(
        id: map['id'],
        filePath: map['file_path'],
        thumbnailPath: map['thumbnail_path'],
        dateTaken: DateTime.fromMillisecondsSinceEpoch(map['date_taken']),
        category: _parseCategory(map['category']),
        isFavorite: map['is_favorite'] == 1,
        tags: tags,
        location: location,
        recognizedPersons: persons,
        metadata: metadata,
      ));
    }
    
    return photos;
  }

  /// Αποθήκευση φωτογραφίας
  Future<int> insertPhoto(Photo photo) async {
    final db = await database;
    final photoMap = photo.toMap();
    photoMap.remove('id'); // Αφαίρεση id για insert
    
    final photoId = await db.insert(
      'photos',
      photoMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Αποθήκευση σχέσεων photo-persons
    if (photo.recognizedPersons.isNotEmpty) {
      for (var person in photo.recognizedPersons) {
        // Προσθήκη/Ενημέρωση person αν δεν έχει id
        int personId;
        if (person.id != null) {
          personId = person.id!;
        } else {
          personId = await upsertPerson(person);
        }
        
        // Προσθήκη σχέσης στο junction table
        await db.insert(
          'photo_persons',
          {
            'photo_id': photoId,
            'person_id': personId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    
    return photoId;
  }

  /// Ενημέρωση φωτογραφίας
  Future<void> updatePhoto(Photo photo) async {
    if (photo.id == null) {
      throw Exception("Δεν μπορεί να γίνει update φωτογραφίας χωρίς id");
    }
    final db = await database;
    final photoMap = photo.toMap();
    photoMap.remove('id'); // Αφαίρεση id για update
    
    await db.update(
      'photos',
      photoMap,
      where: 'id = ?',
      whereArgs: [photo.id],
    );
    
    // Ενημέρωση σχέσεων photo-persons
    if (photo.recognizedPersons.isNotEmpty) {
      // Διαγραφή παλιών σχέσεων
      await db.delete(
        'photo_persons',
        where: 'photo_id = ?',
        whereArgs: [photo.id],
      );
      
      // Προσθήκη νέων σχέσεων
      for (var person in photo.recognizedPersons) {
        int personId;
        if (person.id != null) {
          personId = person.id!;
        } else {
          personId = await upsertPerson(person);
        }
        
        await db.insert(
          'photo_persons',
          {
            'photo_id': photo.id,
            'person_id': personId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

  /// Διαγραφή φωτογραφίας
  Future<void> deletePhoto(int photoId) async {
    final db = await database;
    await db.delete(
      'photos',
      where: 'id = ?',
      whereArgs: [photoId],
    );
  }

  /// Ανάκτηση albums (ομαδοποίηση φωτογραφιών ανά κατηγορία και tags)
  Future<List<Map<String, dynamic>>> getAlbums() async {
    final allPhotos = await getPhotos();
    final Map<String, Map<String, dynamic>> albumsMap = {};

    for (final photo in allPhotos) {
      final catName = photo.category.toString().split('.').last;
      final catKey = 'category_$catName';
      if (!albumsMap.containsKey(catKey)) {
        albumsMap[catKey] = {
          'id': catKey,
          'name': _getCategoryDisplayName(catName),
          'count': 0,
          'thumbnail': null,
          'date': null,
          'type': 'category',
          'filter': catName,
        };
      }
      albumsMap[catKey]!['count'] = (albumsMap[catKey]!['count'] as int) + 1;
      if (albumsMap[catKey]!['thumbnail'] == null && photo.filePath.isNotEmpty) {
        albumsMap[catKey]!['thumbnail'] = photo.filePath;
      }
      final d = photo.dateTaken;
      albumsMap[catKey]!['date'] = '${d.year}-${d.month.toString().padLeft(2, '0')}';
    }

    for (final photo in allPhotos) {
      for (final tag in photo.tags) {
        if (tag.isEmpty) continue;
        final tagKey = 'tag_$tag';
        if (!albumsMap.containsKey(tagKey)) {
          albumsMap[tagKey] = {
            'id': tagKey,
            'name': '#$tag',
            'count': 0,
            'thumbnail': null,
            'date': null,
            'type': 'tag',
            'filter': tag,
          };
        }
        albumsMap[tagKey]!['count'] = (albumsMap[tagKey]!['count'] as int) + 1;
        if (albumsMap[tagKey]!['thumbnail'] == null && photo.filePath.isNotEmpty) {
          albumsMap[tagKey]!['thumbnail'] = photo.filePath;
        }
      }
    }

    return albumsMap.values.toList();
  }

  /// Φόρτωση φωτογραφιών για album (κατηγορία ή tag)
  Future<List<Photo>> getPhotosForAlbum(String albumId) async {
    if (albumId.startsWith('category_')) {
      final cat = albumId.replaceFirst('category_', '');
      return getPhotos(category: _parseCategory(cat));
    }
    if (albumId.startsWith('tag_')) {
      final tag = albumId.replaceFirst('tag_', '');
      final all = await getPhotos();
      return all.where((p) => p.tags.any((t) => t.toLowerCase() == tag.toLowerCase())).toList();
    }
    return getPhotos();
  }

  String _getCategoryDisplayName(String cat) {
    switch (cat) {
      case 'portrait': return 'Προσωπογραφίες';
      case 'landscape': return 'Τοπία';
      case 'group': return 'Ομαδικές';
      default: return cat;
    }
  }

  /// Ανάκτηση όλων των μοναδικών tags από τις φωτογραφίες
  Future<List<String>> getAllTags() async {
    final photos = await getPhotos();
    final Set<String> tagSet = {};
    for (final photo in photos) {
      for (final tag in photo.tags) {
        if (tag.trim().isNotEmpty) {
          tagSet.add(tag.trim());
        }
      }
    }
    return tagSet.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  /// Ανάκτηση ή δημιουργία προεπιλεγμένου χρήστη
  Future<User> getOrCreateDefaultUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    final defaultUser = User(
      username: 'Χρήστης Smart Gallery',
      email: null,
      autoCategorizeEnabled: true,
      categoryPreferences: {'portrait': true, 'landscape': true, 'group': true},
    );
    final userMap = defaultUser.toMap();
    userMap.remove('id');
    final id = await db.insert('users', userMap);
    return User(
      id: id,
      username: defaultUser.username,
      email: defaultUser.email,
      profileImageUrl: defaultUser.profileImageUrl,
      favoritePhotoIds: defaultUser.favoritePhotoIds,
      recentPhotoIds: defaultUser.recentPhotoIds,
      categoryPreferences: defaultUser.categoryPreferences,
      autoCategorizeEnabled: defaultUser.autoCategorizeEnabled,
    );
  }

  /// Ανάκτηση φωτογραφιών ανά κατηγορία
  Future<Map<PhotoCategory, List<Photo>>> getPhotosByCategory() async {
    final allPhotos = await getPhotos();
    final Map<PhotoCategory, List<Photo>> result = {};
    
    for (var photo in allPhotos) {
      if (!result.containsKey(photo.category)) {
        result[photo.category] = [];
      }
      result[photo.category]!.add(photo);
    }
    
    return result;
  }


  // Μέθοδοι για τα πρόσωπα
  
  /// Ανάκτηση όλων των αναγνωρισμένων προσώπων
  Future<List<Person>> getAllPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('persons');
    return maps.map((map) => Person.fromMap(map)).toList();
  }

  /// Ανάκτηση φωτογραφιών ενός προσώπου
  Future<List<Photo>> getPhotosByPerson(int personId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM photos p
      INNER JOIN photo_persons pp ON p.id = pp.photo_id
      WHERE pp.person_id = ?
      ORDER BY p.date_taken DESC
    ''', [personId]);
    
    return List.generate(maps.length, (i) {
      return Photo(
        id: maps[i]['id'],
        filePath: maps[i]['file_path'],
        thumbnailPath: maps[i]['thumbnail_path'],
        dateTaken: DateTime.fromMillisecondsSinceEpoch(maps[i]['date_taken']),
        category: _parseCategory(maps[i]['category']),
        isFavorite: maps[i]['is_favorite'] == 1,
      );
    });
  }

  /// Προσθήκη/Ενημέρωση προσώπου
  Future<int> upsertPerson(Person person) async {
    final db = await database;
    final personMap = person.toMap();
    
    if (person.id != null) {
      personMap.remove('id'); // Αφαίρεση id για update
      await db.update(
        'persons',
        personMap,
        where: 'id = ?',
        whereArgs: [person.id],
      );
      return person.id!;
    } else {
      return await db.insert(
        'persons',
        personMap,
      );
    }
  }

  /// Διαγραφή προσώπου
  Future<void> deletePerson(int personId) async {
    final db = await database;
    await db.delete(
      'persons',
      where: 'id = ?',
      whereArgs: [personId],
    );
  }


  // Μέθοδοι για τις τοποθεσίες
  
  /// Ανάκτηση όλων των τοποθεσιών
  Future<List<Location>> getAllLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return maps.map((map) => Location.fromMap(map)).toList();
  }

  /// Ανάκτηση φωτογραφιών μιας τοποθεσίας
  Future<List<Photo>> getPhotosByLocation(int locationId) async {
    return await getPhotos(locationId: locationId);
  }

  /// Προσθήκη/Ενημέρωση τοποθεσίας
  Future<int> upsertLocation(Location location) async {
    final db = await database;
    final locationMap = location.toMap();
    
    if (location.id != null) {
      locationMap.remove('id'); // Αφαίρεση id για update
      await db.update(
        'locations',
        locationMap,
        where: 'id = ?',
        whereArgs: [location.id],
      );
      return location.id!;
    } else {
      return await db.insert(
        'locations',
        locationMap,
      );
    }
  }

  // Μέθοδοι για τους χρήστες
  
  /// Ανάκτηση προφίλ χρήστη
  Future<User?> getUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    
    return User.fromMap(maps.first);
  }

  /// Ενημέρωση προφίλ χρήστη
  Future<void> updateUser(User user) async {
    if (user.id == null) {
      throw Exception("Δεν μπορεί να γίνει update χρήστη χωρίς id");
    }
    final db = await database;
    final userMap = user.toMap();
    userMap.remove('id'); // Αφαίρεση id για update
    
    await db.update(
      'users',
      userMap,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }


  // Βοηθητικές μέθοδοι
  PhotoCategory _parseCategory(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'portrait':
        return PhotoCategory.portrait;
      case 'landscape':
        return PhotoCategory.landscape;
      case 'object':
        return PhotoCategory.object;
      case 'group':
        return PhotoCategory.group;
      case 'selfie':
        return PhotoCategory.selfie;
      case 'food':
        return PhotoCategory.food;
      case 'animal':
        return PhotoCategory.animal;
      default:
        return PhotoCategory.other;
    }
  }

  /// Αρχικοποίηση της βάσης δεδομένων
  Future<void> initializeDatabase() async {
    await database; // Αυτό θα δημιουργήσει τη βάση αν δεν υπάρχει
    log.config("Η βάση δεδομένων αρχικοποιήθηκε επιτυχώς");
  }
}
