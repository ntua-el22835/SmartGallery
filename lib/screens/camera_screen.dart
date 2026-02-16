import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/services/camera_service.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/services/ml_service.dart';

/// Οθόνη κάμερας - προεπισκόπηση και λήψη φωτογραφιών
///
/// Σε κινητά: πραγματική κάμερα με CameraPreview
/// Σε desktop: file picker για επιλογή εικόνας
class CameraScreen extends StatefulWidget {
  /// Callback όταν αποθηκεύεται νέα φωτογραφία - για ανανέωση της gallery
  final VoidCallback? onPhotoSaved;

  const CameraScreen({super.key, this.onPhotoSaved});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _cameraService = CameraService();
  final _databaseService = DatabaseService();
  final _mlService = MLService();
  bool _isInitializing = true;
  bool _isSwitchingCamera = false;
  String? _error;
  bool _isCapturing = false;
  bool _buttonShowsFace = false;
  String? _buttonAvatarPath;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadButtonPreference();
  }

  Future<void> _loadButtonPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _buttonShowsFace = prefs.getBool('camera_button_show_face') ?? false;
          _buttonAvatarPath = prefs.getString('camera_button_avatar_path');
        });
      }
    } catch (_) {}
  }

  /// Αποθήκευση προτιμήσεων κουμπιού λήψης στο SharedPreferences
  Future<void> _saveButtonPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('camera_button_show_face', _buttonShowsFace);
      await prefs.setString('camera_button_avatar_path', _buttonAvatarPath ?? '');
    } catch (_) {}
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    super.dispose();
  }

  /// Εναλλαγή κάμερας (πίσω ↔ μπροστινή/selfie)
  Future<void> _switchCamera() async {
    if (_isSwitchingCamera || _error != null) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    setState(() => _isSwitchingCamera = true);
    try {
      final success = await _cameraService.switchCamera();
      if (mounted) {
        setState(() {
          _isSwitchingCamera = false;
          // Εμφάνιση μηνύματος ανάλογα με το αποτέλεσμα
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Εναλλαγή κάμερας επιτυχής')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Δεν υπάρχει άλλη κάμερα')),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSwitchingCamera = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα εναλλαγής: $e')),
        );
      }
    }
  }

  /// Αρχικοποίηση κάμερας ή fallback σε file picker (desktop)
  Future<void> _initCamera() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await _cameraService.initializeCamera();
        if (mounted) {
          setState(() {
          _isInitializing = false;
          _error = null;
        });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
          _isInitializing = false;
          _error = 'Σφάλμα κάμερας: $e';
        });
        }
      }
    } else {
      // Desktop: δεν απαιτείται αρχικοποίηση - θα χρησιμοποιηθεί file picker
      setState(() {
        _isInitializing = false;
        _error = null;
      });
    }
  }

  /// Λήψη φωτογραφίας ή επιλογή από αρχείο (desktop)
  Future<void> _captureOrPickPhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    String? filePath;
    if ((Platform.isAndroid || Platform.isIOS) && _error == null) {
      try {
        filePath = await _cameraService.takePicture();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Σφάλμα λήψης: $e')),
          );
        }
      }
    } else {
      // Desktop ή σφάλμα: χρήση image picker
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        filePath = xFile.path;
      }
    }

    if (filePath != null && mounted) {
      await _savePhotoToDatabase(filePath);
    }
    if (mounted) setState(() => _isCapturing = false);
  }

  /// Αποθήκευση φωτογραφίας στη βάση δεδομένων
  /// 
  /// 1. ML κατηγοριοποίηση (portrait/landscape/group)
  /// 2. Μετακίνηση σε φάκελο κατηγορίας (photos/portrait/, κλπ.)
  /// 3. Αποθήκευση στη βάση με το νέο path
  Future<void> _savePhotoToDatabase(String filePath) async {
    try {
      // Κατηγοριοποίηση με ML (3 κατηγορίες: portrait, landscape, group)
      final category = await _mlService.categorizePhoto(filePath);

      // Μετακίνηση σε φάκελο κατηγορίας
      final categoryName = category.toString().split('.').last;
      final finalPath = await _cameraService.moveToCategoryFolder(filePath, categoryName);

      final photo = Photo(
        filePath: finalPath,
        dateTaken: DateTime.now(),
        category: category,
      );
      await _databaseService.insertPhoto(photo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Φωτογραφία αποθηκεύτηκε ($categoryName)')),
        );
        widget.onPhotoSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα αποθήκευσης: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
    final dateStr = '${weekdays[now.weekday - 1]} ${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Κεφαλίδα οθόνης
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/icons/smart gallery logo.png', height: 28),
                    Text(dateStr, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          // Προεπισκόπηση κάμερας ή placeholder
          Center(
            child: _buildCameraContent(dateStr),
          ),
          // Κουμπί εναλλαγής κάμερας (πίσω/μπροστά) - μόνο σε κινητά με λειτουργική κάμερα
          if ((Platform.isAndroid || Platform.isIOS) && _error == null && !_isInitializing)
            Positioned(
              bottom: 50,
              right: 24,
              child: IconButton(
                icon: _isSwitchingCamera
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cameraswitch, color: Colors.white, size: 32),
                onPressed: _isSwitchingCamera ? null : _switchCamera,
              ),
            ),
          // Κουμπί λήψης/επιλογής (εναλλασσόμενο: κάμερα ή πρόσωπο)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : _captureOrPickPhoto,
                onLongPress: _isCapturing ? null : _showButtonStyleOptions,
                child: _buildCaptureButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraContent(String dateStr) {
    if (_isInitializing) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white70),
          SizedBox(height: 16),
          Text('Φόρτωση κάμερας...', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      );
    }
    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 80, color: Colors.white38),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Χρησιμοποιήστε το κουμπί για επιλογή εικόνας', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      );
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return _buildCameraPreview();
    }
    // Desktop: placeholder για επιλογή αρχείου
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 80, color: Colors.white38),
        const SizedBox(height: 16),
        Text('Πατήστε το κουμπί για επιλογή φωτογραφίας', style: TextStyle(color: Colors.white70, fontSize: 16)),
      ],
    );
  }

  /// Κουμπί λήψης - εναλλασσόμενο εικονίδιο κάμερας ή πρόσωπο
  Widget _buildCaptureButton() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isCapturing ? Colors.grey : Colors.white,
        border: Border.all(color: Colors.white38, width: 4),
      ),
      child: _isCapturing
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.black54, strokeWidth: 2),
            )
          : _buttonShowsFace
              ? ClipOval(
                  child: _buildButtonFaceContent(),
                )
              : const Icon(Icons.camera_alt, size: 36, color: Colors.black87),
    );
  }

  Widget _buildButtonFaceContent() {
    if (_buttonAvatarPath != null && _buttonAvatarPath!.isNotEmpty) {
      final file = File(_buttonAvatarPath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, width: 72, height: 72);
      }
    }
    return Container(
      color: Colors.white,
      child: const Icon(Icons.person, size: 36, color: Colors.black54),
    );
  }

  void _showButtonStyleOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Εμφάνιση κουμπιού λήψης',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Εικονίδιο κάμερας', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _buttonShowsFace = false;
                    _buttonAvatarPath = null;
                  });
                  _saveButtonPreference();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Πρόσωπο (προεπιλογή)', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  setState(() {
                    _buttonShowsFace = true;
                    _buttonAvatarPath = null;
                  });
                  _saveButtonPreference();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Επιλογή φωτογραφίας για πρόσωπο', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickButtonAvatar();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickButtonAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final buttonDir = Directory(path.join(appDir.path, 'button_avatar'));
      if (!await buttonDir.exists()) await buttonDir.create(recursive: true);
      final ext = path.extension(xFile.path).isEmpty ? '.jpg' : path.extension(xFile.path);
      final destPath = path.join(buttonDir.path, 'avatar$ext');
      await File(xFile.path).copy(destPath);
      if (mounted) {
        setState(() {
          _buttonShowsFace = true;
          _buttonAvatarPath = destPath;
        });
        _saveButtonPreference();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ενημερώθηκε η εμφάνιση του κουμπιού')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e')),
        );
      }
    }
  }

  /// Προεπισκόπηση κάμερας (mobile) - χρήση CameraPreview από CameraService
  Widget _buildCameraPreview() {
    final preview = _cameraService.buildPreview();
    return SizedBox.expand(
      child: preview ?? const Icon(Icons.camera_alt, size: 80, color: Colors.white38),
    );
  }
}
