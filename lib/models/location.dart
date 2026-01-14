/// Model class για τοποθεσίες
/// 
/// Χρησιμοποιείται για την αποθήκευση GPS coordinates
/// και addresses για ομαδοποίηση φωτογραφιών
/// βάσει τοποθεσίας.
class Location {
  final int? id;
  final double latitude;
  final double longitude;
  final String? address; // Reverse geocoded address
  final String? city;
  final String? country;
  final String? placeName; // Custom name (e.g., "Home", "Vacation Spot")

  Location({
    this.id,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.placeName,
  });

  // TODO: Προσθήκη methods για serialization/deserialization
  // Map<String, dynamic> toMap() { ... }
  // Location.fromMap(Map<String, dynamic> map) { ... }
}

