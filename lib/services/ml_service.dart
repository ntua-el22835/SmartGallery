import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/models/person.dart';
import 'package:logging/logging.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';

/// Service για Machine Learning λειτουργικότητα
/// 
/// Χρησιμοποιείται για:
/// 1. Κατηγοριοποίηση φωτογραφιών (portraits, landscapes, objects, etc.)
/// 2. Αναγνώριση προσώπων σε φωτογραφίες (Face Recognition)
/// 3. Αυτόματη ομαδοποίηση φωτογραφιών
class MLService {
  final log = Logger('MLServiceLogger');
  
  // Στιγμιότυπο ανιχνευτή προσώπων (Face Detector)
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: false,
      minFaceSize: 0.1,
    ),
  );
  

  /// Κατηγοριοποίηση φωτογραφίας (3 κατηγορίες: portrait, landscape, group)
  /// 
  /// - portrait: 1 πρόσωπο (single person)
  /// - landscape: 0 πρόσωπα (χωρίς άτομα)
  /// - group: 2+ πρόσωπα (πολλά άτομα)
  Future<PhotoCategory> categorizePhoto(String imagePath) async {
    // Εναλλακτική για desktop - το ML Kit δεν υποστηρίζεται
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      log.info("Η κατηγοριοποίηση εικόνων δεν υποστηρίζεται σε desktop, επιστροφή 'landscape'");
      return PhotoCategory.landscape;
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        log.warning("Το αρχείο εικόνας δεν βρέθηκε: $imagePath");
        return PhotoCategory.landscape;
      }

      // Χρήση fromFilePath για σωστό διάβασμα JPEG/PNG αρχείων
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        if (faces.length == 1) {
          log.config("Ανιχνεύτηκε 1 πρόσωπο, κατηγοριοποίηση ως portrait");
          return PhotoCategory.portrait;
        } else {
          log.config("Detected ${faces.length} faces, categorizing as group");
          return PhotoCategory.group;
        }
      }

      // 0 πρόσωπα → landscape (χωρίς άτομα)
      log.info("Δεν ανιχνεύτηκαν πρόσωπα, κατηγοριοποίηση ως landscape");
      return PhotoCategory.landscape;
    } catch (e) {
      log.severe("Σφάλμα κατηγοριοποίησης φωτογραφίας: $e");
      return PhotoCategory.landscape;
    }
  }

  /// Αναγνώριση προσώπων σε φωτογραφία
  /// 
  /// Χρησιμοποιεί AI face recognition για να βρει πρόσωπα
  /// στην εικόνα. Ο χρήστης θα πρέπει να δώσει όνομα σε κάθε πρόσωπο.
  Future<List<Person>> recognizeFaces(String imagePath, int photoId) async {
    // Εναλλακτική για desktop - το ML Kit δεν υποστηρίζεται
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      log.info("Η αναγνώριση προσώπων δεν υποστηρίζεται σε desktop, επιστροφή κενής λίστας");
      return [];
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        log.warning("Το αρχείο εικόνας δεν βρέθηκε: $imagePath");
        return [];
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        log.info("Δεν ανιχνεύτηκαν πρόσωπα στην εικόνα");
        return [];
      }

      log.config("Detected ${faces.length} face(s) in image");

      // Μετατροπή Face objects σε Person objects
      final List<Person> persons = [];
      
      for (int i = 0; i < faces.length; i++) {
        final face = faces[i];
        
        // Εξαγωγή coordinates
        final boundingBox = face.boundingBox;
        final faceCoordinates = {
          'x': boundingBox.left.toDouble(),
          'y': boundingBox.top.toDouble(),
          'width': boundingBox.width.toDouble(),
          'height': boundingBox.height.toDouble(),
        };

        // Δημιουργία αντικειμένου Person
        // Το όνομα θα δοθεί από τον χρήστη αργότερα
        persons.add(Person(
          name: 'Άγνωστο ${i + 1}', // Προσωρινό όνομα
          photoId: photoId,
          confidence: face.trackingId != null ? 1.0 : null,
          faceCoordinates: faceCoordinates,
        ));
      }

      return persons;
    } catch (e) {
      log.severe("Σφάλμα αναγνώρισης προσώπων: $e");
      return [];
    }
  }

  /// Αυτόματη ομαδοποίηση φωτογραφιών
  /// 
  /// Ομαδοποιεί φωτογραφίες βάσει:
  /// - Κατηγορίας
  /// - Πρόσωπων
  /// - Τοποθεσίας
  /// - Ημερομηνίας
  Future<Map<String, List<Photo>>> groupPhotos(List<Photo> photos) async {
    try {
      final Map<String, List<Photo>> grouped = {};

      for (final photo in photos) {
        // Ομαδοποίηση βάσει κατηγορίας
        final categoryKey = 'category_${photo.category.toString().split('.').last}';
        grouped.putIfAbsent(categoryKey, () => []).add(photo);

        // Ομαδοποίηση βάσει τοποθεσίας (αν υπάρχει)
        if (photo.location != null) {
          final locationKey = 'location_${photo.location!.city ?? photo.location!.country ?? 'unknown'}';
          grouped.putIfAbsent(locationKey, () => []).add(photo);
        }

        // Ομαδοποίηση βάσει ημερομηνίας (μήνας/έτος)
        final dateKey = 'date_${photo.dateTaken.year}_${photo.dateTaken.month}';
        grouped.putIfAbsent(dateKey, () => []).add(photo);

        // Ομαδοποίηση βάσει προσώπων (αν υπάρχουν)
        if (photo.recognizedPersons.isNotEmpty) {
          for (final person in photo.recognizedPersons) {
            final personKey = 'person_${person.name}';
            grouped.putIfAbsent(personKey, () => []).add(photo);
          }
        }
      }

      log.config("Grouped ${photos.length} photos into ${grouped.length} groups");
      return grouped;
    } catch (e) {
      log.severe("Σφάλμα ομαδοποίησης φωτογραφιών: $e");
      return {};
    }
  }

  /// Batch processing φωτογραφιών
  /// 
  /// Κατηγοριοποιεί και αναγνωρίζει πρόσωπα σε πολλές φωτογραφίες
  Future<void> processPhotosBatch(List<String> imagePaths) async {
    try {
      log.info("Έναρξη batch επεξεργασίας για ${imagePaths.length} φωτογραφίες");

      for (int i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
        
        try {
          // Κατηγοριοποίηση
          final category = await categorizePhoto(imagePath);
          log.config("Photo $i/${imagePaths.length}: Category = ${category.toString().split('.').last}");

          // Ανίχνευση προσώπων (με προσωρινό photoId)
          final faces = await recognizeFaces(imagePath, i);
          if (faces.isNotEmpty) {
            log.config("Photo $i/${imagePaths.length}: Detected ${faces.length} face(s)");
          }
        } catch (e) {
          log.warning("Σφάλμα επεξεργασίας φωτογραφίας $i: $e");
          // Συνεχίζουμε με την επόμενη φωτογραφία
        }
      }

      log.info("Η batch επεξεργασία ολοκληρώθηκε");
    } catch (e) {
      log.severe("Σφάλμα batch processing: $e");
    }
  }

  /// Καθαρισμός πόρων
  void dispose() {
    _faceDetector.close();
    log.config("Οι πόροι του ML Service απελευθερώθηκαν");
  }
}
