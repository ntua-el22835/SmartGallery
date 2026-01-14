import 'package:smartgallery/models/photo.dart'; // Model για Photo objects
import 'package:smartgallery/models/person.dart'; // Model για Person objects
import 'package:logging/logging.dart'; // Logging για debugging
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'; // Google ML Kit Face Detection - αναγνώριση προσώπων
import 'package:google_mlkit_commons/google_mlkit_commons.dart'; // Google ML Kit Commons - InputImage για ML processing
import 'package:flutter/material.dart'; // Flutter UI - Size class
import 'dart:io'; 
// Platform detection - για desktop fallback
import 'dart:async'; // Async utilities (Future, async, await)

/// Service για Machine Learning λειτουργικότητα
/// 
/// Χρησιμοποιείται για:
/// 1. Κατηγοριοποίηση φωτογραφιών (portraits, landscapes, objects, etc.)
/// 2. Αναγνώριση προσώπων σε φωτογραφίες (Face Recognition)
/// 3. Αυτόματη ομαδοποίηση φωτογραφιών
class MLService {
  final log = Logger('MLServiceLogger');
  
  // Face detector instance
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: false,
      minFaceSize: 0.1,
    ),
  );
  

  /// Κατηγοριοποίηση φωτογραφίας
  /// 
  /// Αναλύει την εικόνα και προσδιορίζει την κατηγορία της:
  /// - Portrait, Landscape, Object, Group, Selfie, Food, Animal, Other
  Future<PhotoCategory> categorizePhoto(String imagePath) async {
    // Desktop fallback - δεν υποστηρίζεται ML Kit
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      log.info("Image categorization not supported on desktop, returning 'other'");
      return PhotoCategory.other;
    }

    try {
      // Διάβασμα εικόνας από file
      final file = File(imagePath);
      if (!await file.exists()) {
        log.warning("Image file not found: $imagePath");
        return PhotoCategory.other;
      }

      final bytes = await file.readAsBytes();
      
      // Δημιουργία InputImage με metadata
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(0, 0), // Θα προσδιοριστεί αυτόματα
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 0,
        ),
      );

      // Χρήση Face Detection για να προσδιορίσουμε αν έχει πρόσωπα
      // (αυτό είναι fallback μέθοδος - το Image Labeling δεν είναι διαθέσιμο)
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        // Αν έχει πρόσωπα, προσδιορίζουμε την κατηγορία
        if (faces.length == 1) {
          // Ένα πρόσωπο - πιθανώς portrait ή selfie
          // Δεν μπορούμε να ξεχωρίσουμε με ακρίβεια, οπότε επιστρέφουμε portrait
          log.config("Detected 1 face, categorizing as portrait");
          return PhotoCategory.portrait;
        } else {
          // Πολλά πρόσωπα - group
          log.config("Detected ${faces.length} faces, categorizing as group");
          return PhotoCategory.group;
        }
      }

      // Αν δεν έχει πρόσωπα, επιστρέφουμε 'other'
      // Στο μέλλον μπορεί να προστεθεί Image Labeling για καλύτερη κατηγοριοποίηση
      log.info("No faces detected, returning 'other' category");
      return PhotoCategory.other;
    } catch (e) {
      log.severe("Σφάλμα κατηγοριοποίησης φωτογραφίας: $e");
      return PhotoCategory.other;
    }
  }

  /// Αναγνώριση προσώπων σε φωτογραφία
  /// 
  /// Χρησιμοποιεί AI face recognition για να βρει πρόσωπα
  /// στην εικόνα. Ο χρήστης θα πρέπει να δώσει όνομα σε κάθε πρόσωπο.
  Future<List<Person>> recognizeFaces(String imagePath, int photoId) async {
    // Desktop fallback - δεν υποστηρίζεται ML Kit
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      log.info("Face recognition not supported on desktop, returning empty list");
      return [];
    }

    try {
      // Διάβασμα εικόνας από file
      final file = File(imagePath);
      if (!await file.exists()) {
        log.warning("Image file not found: $imagePath");
        return [];
      }

      final bytes = await file.readAsBytes();
      
      // Δημιουργία InputImage με metadata
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(0, 0), // Θα προσδιοριστεί αυτόματα
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 0,
        ),
      );

      // Ανίχνευση προσώπων
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        log.info("No faces detected in image");
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

        // Δημιουργία Person object
        // Το όνομα θα δοθεί από τον χρήστη αργότερα
        persons.add(Person(
          name: 'Unknown ${i + 1}', // Προσωρινό όνομα
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
      log.info("Starting batch processing for ${imagePaths.length} photos");

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
          log.warning("Error processing photo $i: $e");
          // Συνεχίζουμε με την επόμενη φωτογραφία
        }
      }

      log.info("Batch processing completed");
    } catch (e) {
      log.severe("Σφάλμα batch processing: $e");
    }
  }

  /// Καθαρισμός resources
  void dispose() {
    _faceDetector.close();
    log.config("ML Service resources disposed");
  }
}
