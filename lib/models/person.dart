import 'dart:convert'; // Για jsonEncode/jsonDecode

/// Model class για αναγνωρισμένα πρόσωπα
/// Χρησιμοποιείται για την αποθήκευση πληροφοριών
/// για πρόσωπα που αναγνωρίστηκαν σε φωτογραφίες
/// μέσω AI face recognition.
/// Ο χρήστης μπορεί να δώσει όνομα στο πρόσωπο.
class Person {
  final int? id;
  final String name; // Όνομα που έδωσε ο χρήστης
  final String? faceId; // ID από face recognition algorithm
  final int photoId; // ID της φωτογραφίας που εμφανίζεται
  final double? confidence; // Confidence score από ML
  final Map<String, double>? faceCoordinates; // Coordinates στο photo (x, y, width, height)

  /// Constructor για το Person object
  Person({
    this.id,
    required this.name,
    this.faceId,
    required this.photoId,
    this.confidence,
    this.faceCoordinates,
  });

 
  /// Μετατρέπει Person object σε Map για αποθήκευση στη βάση
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'face_id': faceId,
      'photo_id': photoId,
      'confidence': confidence,
      'face_coordinates': faceCoordinates != null 
          ? jsonEncode(faceCoordinates) 
          : null, // Map → JSON string
    };
  }

  /// Δημιουργεί Person object από Map (από τη βάση)
  Person.fromMap(Map<String, dynamic> map)
    : id = map['id'] as int?,
      name = map['name'] as String,
      faceId = map['face_id'] as String?,
      photoId = map['photo_id'] as int,
      confidence = map['confidence'] != null 
          ? (map['confidence'] as num).toDouble() 
          : null,
      faceCoordinates = map['face_coordinates'] != null 
          ? Map<String, double>.from(
              jsonDecode(map['face_coordinates'] as String) as Map
            )
          : null; // JSON string → Map<String, double>
}



