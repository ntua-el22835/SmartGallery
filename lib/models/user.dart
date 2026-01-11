/// Model class για τον χρήστη
/// 
/// Περιέχει τις βασικές πληροφορίες του χρήστη
/// και preferences για την εφαρμογή Smart Gallery.
class User {
  final int? id;
  final String username;
  final String? email;
  final String? profileImageUrl;
  final List<int> favoritePhotoIds; // Favorite photos
  final List<int> recentPhotoIds; // Recently viewed photos
  final Map<String, bool> categoryPreferences; // Preferred categories to show
  final bool autoCategorizeEnabled; // Auto-categorization enabled/disabled

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

  // TODO: Προσθήκη methods για serialization/deserialization
  // Map<String, dynamic> toMap() { ... }
  // User.fromMap(Map<String, dynamic> map) { ... }
}

