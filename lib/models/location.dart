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

  /// Constructor για το Location object
  Location({
    this.id,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.placeName,
  });


  /// Μετατρέπει Location object σε Map για αποθήκευση στη βάση
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'place_name': placeName,
    };
  }

  /// Δημιουργεί Location object από Map (από τη βάση)
  Location.fromMap(Map<String, dynamic> map)
    : id = map['id'] as int?,
      latitude = (map['latitude'] as num).toDouble(), 
      longitude = (map['longitude'] as num).toDouble(), 
      address = map['address'] as String?,
      city = map['city'] as String?,
      country = map['country'] as String?,
      placeName = map['place_name'] as String?;
}

