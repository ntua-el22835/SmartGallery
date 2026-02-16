import 'package:smartgallery/models/location.dart' as models; // Model για Location objects - χρήση prefix για αποφυγή conflict
import 'package:geolocator/geolocator.dart'; // GPS location services - ανάκτηση GPS coordinates
import 'package:geocoding/geocoding.dart'; // Reverse geocoding - μετατροπή coordinates σε addresses
import 'package:logging/logging.dart'; // Logging για debugging
import 'dart:async'; // Async utilities (Future, async, await)

/// Service για GPS location
/// Χρησιμοποιείται για:
/// - Ανάκτηση τοποθεσίας κατά τη λήψη φωτογραφίας
/// - Reverse geocoding (coordinates → address)
/// - Ομαδοποίηση φωτογραφιών βάσει τοποθεσίας
class GPSService {
  final log = Logger('GPSServiceLogger');

  /// Ανάκτηση τρέχουσας τοποθεσίας
  /// Επιστρέφει GPS coordinates (latitude, longitude)
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      // Έλεγχος αν το location service είναι ενεργό
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log.warning("Οι υπηρεσίες τοποθεσίας είναι απενεργοποιημένες");
        return null;
      }

      // Έλεγχος permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log.warning("Location permissions denied");
          return null;
        }
      }

      // Έλεγχος αν οι permissions είναι απενεργοποιημένες για πάντα
      if (permission == LocationPermission.deniedForever) {
        log.severe("Τα δικαιώματα τοποθεσίας αρνήθηκαν μόνιμα");
        return null;
      }

      // Ανάκτηση τρέχουσας τοποθεσίας
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Επιστροφή coordinates ως Map
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      log.severe("Σφάλμα ανάκτησης τοποθεσίας: $e");
      return null;
    }
  }

  /// Μετατροπή coordinates σε Location object
  /// Κάνει reverse geocoding για να πάρει address
  /// από GPS coordinates
  Future<models.Location?> getLocationFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Reverse geocoding - μετατροπή coordinates σε address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      // Έλεγχος αν υπάρχουν placemarks
      if (placemarks.isEmpty) {
        log.warning("Δεν βρέθηκαν τοποθεσίες για τις συντεταγμένες");
        return null;
      }

      // Επιστροφή του πρώτου placemark
      final placemark = placemarks.first;

      // Δημιουργία Location object
      return models.Location(
        latitude: latitude,
        longitude: longitude,
        address: placemark.street,
        city: placemark.locality,
        country: placemark.country,
        placeName: placemark.name,
      );
    } catch (e) {
      log.severe("Σφάλμα reverse geocoding: $e");
      return null;
    }
  }

  /// Ανάκτηση τοποθεσίας φωτογραφίας
  /// 
  /// Αν η φωτογραφία έχει EXIF GPS data, το χρησιμοποιεί
  /// Σημείωση: Χρειάζεται exif package για πλήρη υλοποίηση
  Future<models.Location?> getPhotoLocation(String imagePath) async {
    try {
      // Έλεγχος αν η φωτογραφία έχει EXIF GPS data
      log.warning("Η ανάγνωση EXIF GPS δεν έχει υλοποιηθεί ακόμα");
      return null;
    } catch (e) {
      log.severe("Σφάλμα ανάγνωσης EXIF GPS: $e"); // Επιστροφή null αν υπάρχει σφάλμα
      return null;
    }
  } 

  /// Ομαδοποιεί φωτογραφίες που τραβήχτηκαν στην ίδια τοποθεσία
  Future<Map<models.Location, List<String>>> groupPhotosByLocation(
    List<String> photoPaths,
  ) async {
    try {
      // Ανάκτηση τοποθεσίας για κάθε φωτογραφία
      final List<models.Location?> locations = await Future.wait(
        photoPaths.map((path) => getPhotoLocation(path)),
      );

      // Ομαδοποίηση φωτογραφιών βάσει τοποθεσίας
      final Map<models.Location, List<String>> grouped = {};

      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        if (location != null) {
          // Χρήση location ως key (θα χρειαστεί hashCode/== override)
          // Προσωρινά: χρήση latitude/longitude για grouping
          final key = grouped.keys.firstWhere(
            (loc) => 
              (loc.latitude - location.latitude).abs() < 0.0001 && 
              (loc.longitude - location.longitude).abs() < 0.0001,
            orElse: () => location,
          );

          if (key == location) {
            grouped[location] = [photoPaths[i]];
          } else {
            grouped[key]!.add(photoPaths[i]);
          }
        }
      }

      return grouped;
    } catch (e) {
      log.severe("Σφάλμα ομαδοποίησης φωτογραφιών: $e");
      return {};
    }
  }
}
