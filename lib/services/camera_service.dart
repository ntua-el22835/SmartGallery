import 'package:camera/camera.dart'; // Πρόσβαση στην κάμερα
import 'package:path_provider/path_provider.dart'; // Λειτουργίες file paths
import 'package:path/path.dart' as path; // Λειτουργίες path operations
import 'package:sensors_plus/sensors_plus.dart'; // Πρόσβαση σε gyroscope sensor
import 'package:logging/logging.dart'; // Logging για debugging
import 'dart:io'; // Platform detection & file operations - ανίχνευση platform και file operations
import 'dart:async'; // Async utilities (Completer, Future) - βοηθητικές async συναρτήσεις

// Προαιρετικό: Permissions handling (αν χρειαστεί)
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

  /// Καθαρισμός resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
    log.config("Camera resources καθαρίστηκαν");
  }
}

