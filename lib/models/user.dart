import 'dart:convert'; // Για jsonEncode/jsonDecode

/// Model class για τον χρήστη
/// 
/// Περιέχει τις βασικές πληροφορίες του χρήστη
/// και preferences για την εφαρμογή Smart Gallery.
class User {
  final int? id;
  final String username;
  final String? email;
  final String? profileImageUrl;
  final List<int> favoritePhotoIds; // Αγαπημένες φωτογραφίες
  final List<int> recentPhotoIds; // Πρόσφατα προβεβλημένες φωτογραφίες
  final Map<String, bool> categoryPreferences; // Προτιμώμενες κατηγορίες εμφάνισης
  final bool autoCategorizeEnabled; // Αυτόματη κατηγοριοποίηση ενεργή/ανενεργή

  /// Constructor για το User object
  User({
    this.id,
    required this.username,
    this.email,
    this.profileImageUrl,
    List<int>? favoritePhotoIds,
    List<int>? recentPhotoIds,
    Map<String, bool>? categoryPreferences,
    this.autoCategorizeEnabled = true,
  })  : favoritePhotoIds = favoritePhotoIds ?? [],
        recentPhotoIds = recentPhotoIds ?? [],
        categoryPreferences = categoryPreferences ?? {};

  
  /// Μετατρέπει User object σε Map για αποθήκευση στη βάση
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image_url': profileImageUrl,
      'favorite_photo_ids': jsonEncode(favoritePhotoIds), // List<int> → JSON string
      'recent_photo_ids': jsonEncode(recentPhotoIds), // List<int> → JSON string
      'category_preferences': jsonEncode(categoryPreferences), // Map → JSON string
      'auto_categorize_enabled': autoCategorizeEnabled ? 1 : 0, // bool → int
    };
  }

  /// Δημιουργεί User object από Map (από τη βάση)
  User.fromMap(Map<String, dynamic> map)
    : id = map['id'] as int?,
      username = map['username'] as String,
      email = map['email'] as String?,
      profileImageUrl = map['profile_image_url'] as String?,
      favoritePhotoIds = map['favorite_photo_ids'] != null
          ? List<int>.from(jsonDecode(map['favorite_photo_ids'] as String))
          : [], // JSON string → List<int>
      recentPhotoIds = map['recent_photo_ids'] != null
          ? List<int>.from(jsonDecode(map['recent_photo_ids'] as String))
          : [], // JSON string → List<int>
      categoryPreferences = map['category_preferences'] != null
          ? Map<String, bool>.from(
              jsonDecode(map['category_preferences'] as String) as Map
            )
          : {}, // JSON string → Map<String, bool>
      autoCategorizeEnabled = (map['auto_categorize_enabled'] as int? ?? 1) == 1; // int → bool
}

