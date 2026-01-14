import 'package:smartgallery/models/person.dart';
import 'package:smartgallery/models/location.dart';
import 'dart:convert';

/// Model class για τις φωτογραφίες
/// 
/// Περιέχει όλες τις πληροφορίες μιας φωτογραφίας:
/// - File path και metadata
/// - Κατηγορία (portrait, landscape, object, etc.)
/// - Αναγνωρισμένα πρόσωπα
/// - Τοποθεσία
/// - Ημερομηνία/ώρα λήψης
class Photo {
  final int? id;
  final String filePath;
  final String? thumbnailPath;
  final DateTime dateTaken;
  final PhotoCategory category; // Portrait, Landscape, Object, etc.
  final List<Person> recognizedPersons; // Αναγνωρισμένα πρόσωπα
  final Location? location; // Τοποθεσία λήψης
  final bool isFavorite;
  final List<String> tags; // Hashtags/Tags (π.χ. #Nice, #Summer, #Chania)
  final Map<String, dynamic>? metadata; // Επιπλέον metadata (EXIF, etc.)

  Photo({
    this.id,
    required this.filePath,
    this.thumbnailPath,
    required this.dateTaken,
    required this.category,
    List<Person>? recognizedPersons,
    this.location,
    this.isFavorite = false,
    List<String>? tags,
    this.metadata,
  }) : recognizedPersons = recognizedPersons ?? [],
       tags = tags ?? [];

  /// Μετατρέπει Photo object σε Map για αποθήκευση στη βάση
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'date_taken': dateTaken.millisecondsSinceEpoch,
      'category': category.toString().split('.').last,
      'location_id': location?.id,
      'is_favorite': isFavorite ? 1 : 0, // bool → int
      'tags': tags.join(','), // List<String> → comma-separated string
      'metadata': metadata != null ? jsonEncode(metadata) : null, // Map → JSON string
    };
  }

  /// Δημιουργεί Photo object από Map (από τη βάση)
  /// 
  /// Σημείωση: recognizedPersons και location θα φορτωθούν από related tables
  Photo.fromMap(Map<String, dynamic> map)
    : id = map['id'] as int?,
      filePath = map['file_path'] as String,
      thumbnailPath = map['thumbnail_path'] as String?,
      dateTaken = DateTime.fromMillisecondsSinceEpoch(map['date_taken'] as int),
      category = PhotoCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'] as String,
        orElse: () => PhotoCategory.other,
      ),
      location = null, // Θα φορτωθεί από related table
      isFavorite = (map['is_favorite'] as int? ?? 0) == 1, // int → bool
      tags = (map['tags'] as String?)?.split(',') ?? [], // comma-separated → List
      metadata = map['metadata'] != null 
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null, // JSON string → Map
      recognizedPersons = []; // Θα φορτωθεί από related table
}

/// Enum για τις κατηγορίες φωτογραφιών
/// Προσδιορίζεται από ML algorithm ή gyroscope
enum PhotoCategory {
  portrait,    // Προσωπογραφία
  landscape, // Τοπίο
  object,  // Αντικείμενο
  group, // Ομαδική φωτογραφία
  selfie, // Selfie
  food, // Φαγητό
  animal, // Ζώο
  other, // Άλλο
}

