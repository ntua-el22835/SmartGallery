import 'package:smartgallery/models/person.dart';
import 'package:smartgallery/models/location.dart';

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

  // TODO: Προσθήκη methods για serialization/deserialization
  // Map<String, dynamic> toMap() { ... }
  // Photo.fromMap(Map<String, dynamic> map) { ... }
}

/// Enum για τις κατηγορίες φωτογραφιών
/// Προσδιορίζεται από ML algorithm ή gyroscope
enum PhotoCategory {
  portrait,    // Προσωπογραφία
  landscape,   // Τοπίο
  object,      // Αντικείμενο
  group,       // Ομαδική φωτογραφία
  selfie,      // Selfie
  food,        // Φαγητό
  animal,      // Ζώο
  other,       // Άλλο
}

