import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/models/person.dart';
import 'package:smartgallery/models/location.dart';
import 'package:smartgallery/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'dart:io';

// Platform-specific imports for desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.html) 'package:sqflite_common_ffi_stub/sqflite_ffi_stub.dart';

/// Service για τη διαχείριση της βάσης δεδομένων SQLite
/// 
/// Παρόμοια δομή με το SQLService.dart από το todotoday example.
/// Διαχειρίζεται:
/// - Photos (φωτογραφίες)
/// - Persons (αναγνωρισμένα πρόσωπα)
/// - Locations (τοποθεσίες)
/// - Users (χρήστες)
class DatabaseService {
  final log = Logger('DatabaseServiceLogger');
  Database? _database;
  String dbfile = "smartgallery.db";

  Future<Database> get database async {
    if (_database != null) {
      log.config("get database called, return instance");
      return _database!;
    }
    _database = await initDB();
    log.config("get database called, return initDB");
    return _database!;
  }

  /// Αρχικοποίηση database με platform detection
  /// 
  /// Mobile (Android/iOS): Χρησιμοποιεί sqflite
  /// Desktop (Windows/Linux): Χρησιμοποιεί sqflite_common_ffi
  Future<Database> initDB() async {
    log.config("initDB called, Platform: ${Platform.operatingSystem}");
    
    if (Platform.isWindows || Platform.isLinux) {
      // Desktop: Use sqflite_common_ffi
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
      // Mobile (Android/iOS/macOS): Use regular sqflite
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, dbfile);
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
    throw Exception("Unsupported platform: ${Platform.operatingSystem}");
  }

  /// Δημιουργία tables
  Future<void> _onCreate(Database db, int version) async {
    log.config("_onCreate called, version: $version");
    
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
    
    // Persons table
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
    
    // Locations table
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
    
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT,
        profile_image_url TEXT,
        auto_categorize_enabled INTEGER DEFAULT 1
      )
    ''');
    
    // Photo-Persons junction table (many-to-many)
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

  // ========== PHOTO METHODS ==========
  
  /// Ανάκτηση φωτογραφιών από τη βάση
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
    
    // TODO: Handle person filter (requires join with photo_persons)
    // TODO: Load related persons and locations
    
    return List.generate(maps.length, (i) {
      // Parse tags from JSON string
      List<String> tags = [];
      if (maps[i]['tags'] != null && maps[i]['tags'].toString().isNotEmpty) {
        try {
          tags = List<String>.from(
            maps[i]['tags'].toString().split(',').map((t) => t.trim()).where((t) => t.isNotEmpty)
          );
        } catch (e) {
          log.warning("Error parsing tags: $e");
        }
      }
      
      return Photo(
        id: maps[i]['id'],
        filePath: maps[i]['file_path'],
        thumbnailPath: maps[i]['thumbnail_path'],
        dateTaken: DateTime.fromMillisecondsSinceEpoch(maps[i]['date_taken']),
        category: _parseCategory(maps[i]['category']),
        isFavorite: maps[i]['is_favorite'] == 1,
        tags: tags,
        // TODO: Load location and persons from related tables
      );
    });
  }

  /// Αποθήκευση φωτογραφίας
  Future<int> insertPhoto(Photo photo) async {
    final db = await database;
    return await db.insert(
      'photos',
      {
        'file_path': photo.filePath,
        'thumbnail_path': photo.thumbnailPath,
        'date_taken': photo.dateTaken.millisecondsSinceEpoch,
        'category': photo.category.toString().split('.').last,
        'location_id': photo.location?.id,
        'is_favorite': photo.isFavorite ? 1 : 0,
        'tags': photo.tags.join(','), // Store tags as comma-separated string
        'metadata': photo.metadata?.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ενημέρωση φωτογραφίας
  Future<void> updatePhoto(Photo photo) async {
    if (photo.id == null) {
      throw Exception("Cannot update photo without id");
    }
    final db = await database;
    await db.update(
      'photos',
      {
        'file_path': photo.filePath,
        'thumbnail_path': photo.thumbnailPath,
        'date_taken': photo.dateTaken.millisecondsSinceEpoch,
        'category': photo.category.toString().split('.').last,
        'location_id': photo.location?.id,
        'is_favorite': photo.isFavorite ? 1 : 0,
        'tags': photo.tags.join(','), // Store tags as comma-separated string
        'metadata': photo.metadata?.toString(),
      },
      where: 'id = ?',
      whereArgs: [photo.id],
    );
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

  // ========== PERSON METHODS ==========
  
  /// Ανάκτηση όλων των αναγνωρισμένων προσώπων
  Future<List<Person>> getAllPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('persons');
    return List.generate(maps.length, (i) {
      return Person(
        id: maps[i]['id'],
        name: maps[i]['name'],
        faceId: maps[i]['face_id'],
        photoId: maps[i]['photo_id'],
        confidence: maps[i]['confidence']?.toDouble(),
      );
    });
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
    if (person.id != null) {
      await db.update(
        'persons',
        {
          'name': person.name,
          'face_id': person.faceId,
          'confidence': person.confidence,
          'face_coordinates': person.faceCoordinates?.toString(),
        },
        where: 'id = ?',
        whereArgs: [person.id],
      );
      return person.id!;
    } else {
      return await db.insert(
        'persons',
        {
          'name': person.name,
          'face_id': person.faceId,
          'photo_id': person.photoId,
          'confidence': person.confidence,
          'face_coordinates': person.faceCoordinates?.toString(),
        },
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

  // ========== LOCATION METHODS ==========
  
  /// Ανάκτηση όλων των τοποθεσιών
  Future<List<Location>> getAllLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return List.generate(maps.length, (i) {
      return Location(
        id: maps[i]['id'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        address: maps[i]['address'],
        city: maps[i]['city'],
        country: maps[i]['country'],
        placeName: maps[i]['place_name'],
      );
    });
  }

  /// Ανάκτηση φωτογραφιών μιας τοποθεσίας
  Future<List<Photo>> getPhotosByLocation(int locationId) async {
    return await getPhotos(locationId: locationId);
  }

  /// Προσθήκη/Ενημέρωση τοποθεσίας
  Future<int> upsertLocation(Location location) async {
    final db = await database;
    if (location.id != null) {
      await db.update(
        'locations',
        {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': location.address,
          'city': location.city,
          'country': location.country,
          'place_name': location.placeName,
        },
        where: 'id = ?',
        whereArgs: [location.id],
      );
      return location.id!;
    } else {
      return await db.insert(
        'locations',
        {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': location.address,
          'city': location.city,
          'country': location.country,
          'place_name': location.placeName,
        },
      );
    }
  }

  // ========== USER METHODS ==========
  
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
    
    // TODO: Load favorite and recent photo IDs from separate tables or JSON
    return User(
      id: maps[0]['id'],
      username: maps[0]['username'],
      email: maps[0]['email'],
      profileImageUrl: maps[0]['profile_image_url'],
      autoCategorizeEnabled: maps[0]['auto_categorize_enabled'] == 1,
    );
  }

  /// Ενημέρωση προφίλ χρήστη
  Future<void> updateUser(User user) async {
    if (user.id == null) {
      throw Exception("Cannot update user without id");
    }
    final db = await database;
    await db.update(
      'users',
      {
        'username': user.username,
        'email': user.email,
        'profile_image_url': user.profileImageUrl,
        'auto_categorize_enabled': user.autoCategorizeEnabled ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ========== HELPER METHODS ==========
  
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
    await database; // This will create the database if it doesn't exist
    log.config("Database initialized successfully");
  }
}
