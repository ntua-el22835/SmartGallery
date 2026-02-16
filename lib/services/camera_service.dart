import 'package:camera/camera.dart'; // Πρόσβαση στην κάμερα
import 'package:flutter/material.dart'; // Widget type για buildPreview
import 'package:path_provider/path_provider.dart'; // Λειτουργίες file paths
import 'package:path/path.dart' as path; // Λειτουργίες path operations
import 'package:sensors_plus/sensors_plus.dart'; // Πρόσβαση σε gyroscope sensor
import 'package:logging/logging.dart'; // Logging για debugging
import 'dart:io'; // Platform detection & file operations - ανίχνευση platform και file operations
import 'dart:async'; // Async utilities (Completer, Future) - βοηθητικές async συναρτήσεις

// Προαιρετικό: Χειρισμός δικαιωμάτων (αν χρειαστεί)
// import 'package:permission_handler/permission_handler.dart';

/// Service για τη χρήση της κάμερας
/// Χρησιμοποιείται για:
/// - Λήψη φωτογραφιών
/// - Ανάγνωση gyroscope για portraits/landscapes
/// - Διαχείριση camera controller
class CameraService {
  final log = Logger('CameraServiceLogger');
  CameraController? _controller;

  /// Αρχικοποίηση κάμερας
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("Δεν υπάρχουν διαθέσιμες κάμερες");
      }
      
      // Αρχικοποίηση του camera controller
      _controller = CameraController(
        cameras[0], // Χρήση της πρώτης κάμερας (συνήθως η πίσω κάμερα)
        ResolutionPreset.high,
        enableAudio: false, // Απενεργοποίηση ήχου για photos
      );
      
      await _controller!.initialize();
      log.config("Η κάμερα αρχικοποιήθηκε επιτυχώς");
    } catch (e) {
      log.severe("Σφάλμα αρχικοποίησης κάμερας: $e");
      rethrow;
    }
  }

  /// Λήψη φωτογραφίας
  /// Επιστρέφει το path της αποθηκευμένης φωτογραφίας
  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception("Η κάμερα δεν έχει αρχικοποιηθεί");
    }
    
    try {
      // Λήψη της φωτογραφίας από την κάμερα
      final image = await _controller!.takePicture();
      
      // Αποθήκευση της φωτογραφίας στο device storage
      final directory = await getApplicationDocumentsDirectory();
      final photoDir = Directory(path.join(directory.path, 'photos'));
      
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'photo_$timestamp.jpg';
      final filePath = path.join(photoDir.path, filename);
      
      final file = File(image.path);
      await file.copy(filePath);
      
      log.config("Φωτογραφία αποθηκεύτηκε: $filePath");
      return filePath;
    } catch (e) {
      log.severe("Σφάλμα λήψης φωτογραφίας: $e");
      return null;
    }
  }

  /// Μετακίνηση/αντιγραφή φωτογραφίας στον φάκελο κατηγορίας
  /// 
  /// Δημιουργεί photos/{category}/ και αποθηκεύει το αρχείο εκεί.
  /// Επιστρέφει το νέο path. Κατηγορίες: portrait, landscape, group
  Future<String> moveToCategoryFolder(String sourcePath, String category) async {
    final directory = await getApplicationDocumentsDirectory();
    final categoryDir = Directory(path.join(directory.path, 'photos', category));

    if (!await categoryDir.exists()) {
      await categoryDir.create(recursive: true);
    }

    final filename = path.basename(sourcePath);
    final destPath = path.join(categoryDir.path, filename);

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception("Αρχείο προέλευσης δεν υπάρχει: $sourcePath");
    }

    // Αν το source είναι ήδη στο ίδιο path, μην κάνεις τίποτα
    if (path.absolute(sourcePath) == path.absolute(destPath)) {
      return sourcePath;
    }

    // Αν το dest υπάρχει ήδη (collision), χρησιμοποίησε timestamp
    String finalDestPath = destPath;
    if (await File(destPath).exists()) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.extension(filename);
      final baseName = path.basenameWithoutExtension(filename);
      finalDestPath = path.join(categoryDir.path, '${baseName}_$timestamp$ext');
    }

    await sourceFile.copy(finalDestPath);

    // Διαγραφή προέλευσης μόνο αν είναι μέσα στο photos/ (όχι από image picker)
    final photosBase = path.join(directory.path, 'photos');
    if (sourcePath.startsWith(photosBase) && sourcePath != finalDestPath) {
      try {
        await sourceFile.delete();
      } catch (_) {
        log.warning("Δεν ήταν δυνατή η διαγραφή προέλευσης: $sourcePath");
      }
    }

    log.config("Φωτογραφία μετακινήθηκε σε: $finalDestPath");
    return finalDestPath;
  }

  /// Ανάκτηση gyroscope data
  /// Χρησιμοποιείται για διαχωρισμό portraits/landscapes
  /// Επιστρέφει: orientation (portrait/landscape) - κατεύθυνση (κάθετη/οριζόντια)
  Future<String?> getOrientation() async {
    try {
      String? orientation;
      final completer = Completer<String?>();
      
      final subscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        final x = event.x;
        final y = event.y;
        
        // Απλός κανόνας: αν |x| > |y|, τότε landscape
        if (x.abs() > y.abs()) {
          orientation = "landscape";
        } else {
          orientation = "portrait";
        }
        
        if (!completer.isCompleted) {
          completer.complete(orientation);
        }
      });
      
      // Περίμενε για πρώτο reading (με timeout)
      final result = await completer.future.timeout(
        Duration(milliseconds: 200),
        onTimeout: () => "portrait", // Προεπιλογή
      );
      
      await subscription.cancel();
      return result;
    } catch (e) {
      log.warning("Σφάλμα ανάγνωσης gyroscope: $e");
      return "portrait"; // Προεπιλεγμένη τιμή
    }
  }

  /// Εναλλαγή κάμερας (πίσω ↔ μπροστινή/selfie)
  /// Επιστρέφει true αν η εναλλαγή πέτυχε, false αν υπάρχει μόνο μία κάμερα
  Future<bool> switchCamera() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      log.warning("Δεν μπορεί να γίνει εναλλαγή: η κάμερα δεν είναι αρχικοποιημένη");
      return false;
    }

    try {
      // Λήψη λίστας διαθέσιμων καμερών
      final cameras = await availableCameras();
      if (cameras.length < 2) {
        log.warning("Δεν υπάρχει άλλη κάμερα για εναλλαγή");
        return false;
      }

      // Καθορισμός τρέχουσας κατεύθυνσης φακού (πίσω ή μπροστά)
      final currentLens = _controller!.description.lensDirection;

      // Εύρεση της άλλης κάμερας (front ↔ back)
      final candidates = cameras.where((c) => c.lensDirection != currentLens).toList();
      if (candidates.isEmpty) {
        log.warning("Δεν βρέθηκε εναλλακτική κάμερα");
        return false;
      }
      final otherCamera = candidates.first;

      // Αποδέσμευση τρέχουσας κάμερας
      await _controller!.dispose();
      _controller = null;

      // Αρχικοποίηση νέας κάμερας
      _controller = CameraController(
        otherCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();

      log.config("Εναλλαγή κάμερας επιτυχής: ${otherCamera.lensDirection}");
      return true;
    } catch (e) {
      log.severe("Σφάλμα εναλλαγής κάμερας: $e");
      rethrow;
    }
  }

  /// Έλεγχος αν υπάρχει διαθέσιμη μπροστινή κάμερα (selfie)
  Future<bool> hasFrontCamera() async {
    final cameras = await availableCameras();
    return cameras.any((c) => c.lensDirection == CameraLensDirection.front);
  }

  /// Widget προεπισκόπησης κάμερας (για εμφάνιση στο UI)
  Widget? buildPreview() {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    return CameraPreview(_controller!);
  }

  /// Καθαρισμός resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
    log.config("Camera resources καθαρίστηκαν");
  }
}

