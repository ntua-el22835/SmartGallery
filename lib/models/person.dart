/// Model class για αναγνωρισμένα πρόσωπα
/// 
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

  Person({
    this.id,
    required this.name,
    this.faceId,
    required this.photoId,
    this.confidence,
    this.faceCoordinates,
  });

  // TODO: Προσθήκη methods για serialization/deserialization
  // Map<String, dynamic> toMap() { ... }
  // Person.fromMap(Map<String, dynamic> map) { ... }
}

