import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/screens/photo_detail_screen.dart';
import 'package:smartgallery/services/database_service.dart';

/// Οθόνη Discover - μία φωτογραφία ανά οθόνη με σάρωση ("Επόμενη φωτογραφία")
///
/// Περιέχει: PageView με μία φωτογραφία ανά οθόνη, swipe για επόμενη.
/// Βασισμένο στο Figma wireframe.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<Photo> _photos = []; // Λίστα φωτογραφιών για εμφάνιση
  int _currentIndex = 0; // Τρέχον index στο PageView
  bool _isLoading = true; // Κατάσταση φόρτωσης
  final _databaseService = DatabaseService();
  final _pageController = PageController(); // Controller για PageView

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Αποδέσμευση PageController
    super.dispose();
  }

  /// Φόρτωση φωτογραφιών από τη βάση με ταξινόμηση (νεότερες πρώτα)
  Future<void> _loadPhotos() async {
    try {
      final photos = await _databaseService.getPhotos();
      final sorted = List<Photo>.from(photos)..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
      if (mounted) {
        setState(() {
          _photos.clear();
          _photos.addAll(sorted);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Εμφάνιση loading indicator κατά τη φόρτωση
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white70)),
      );
    }

    // Μήνυμα όταν δεν υπάρχουν φωτογραφίες
    if (_photos.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, size: 80, color: Colors.white38),
              const SizedBox(height: 16),
              const Text('Δεν υπάρχουν φωτογραφίες', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    // Κύριο layout: PageView με φωτογραφίες και επικάλυψη πληροφοριών
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView για σάρωση φωτογραφιών
          PageView.builder(
            controller: _pageController,
            itemCount: _photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => PhotoDetailScreen(photo: photo),
                    ),
                  );
                  _loadPhotos();
                },
                child: Center(
                  child: _buildPhotoImage(photo.filePath, photo.thumbnailPath),
                ),
              );
            },
          ),
          // Επικάλυψη: logo, αριθμός φωτογραφίας, οδηγίες
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/icons/smart gallery logo.png', height: 28),
                      Text(
                        '${_currentIndex + 1} / ${_photos.length}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Σάρωση για επόμενη φωτογραφία',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Εμφάνιση εικόνας φωτογραφίας - asset path ή file path
  Widget _buildPhotoImage(String filePath, String? thumbnailPath) {
    final path = thumbnailPath ?? filePath;
    if (path.isEmpty) return const Icon(Icons.image, color: Colors.white38, size: 64);
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white38, size: 64));
    }
    final file = File(path);
    if (!file.existsSync()) return const Icon(Icons.image, color: Colors.white38, size: 64);
    return Image.file(file, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white38, size: 64));
  }
}
