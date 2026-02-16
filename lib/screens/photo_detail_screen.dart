import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/models/person.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/services/ml_service.dart';

/// Οθόνη λεπτομερειών φωτογραφίας
///
/// Περιέχει: Πλήρης εικόνα, ετικέτες, πρόσωπα (με ανίχνευση ML),
/// διαγραφή, κοινοποίηση, αποθήκευση, επεξεργασία ονομάτων προσώπων.
class PhotoDetailScreen extends StatefulWidget {
  final Photo photo;

  const PhotoDetailScreen({
    super.key,
    required this.photo,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  bool _isMenuExpanded = false;
  final List<String> _tags = [];
  List<Person> _persons = [];
  bool _isLoadingFaces = false;
  final _databaseService = DatabaseService();
  final _mlService = MLService();

  @override
  void initState() {
    super.initState();
    _tags.addAll(widget.photo.tags);
    _persons.addAll(widget.photo.recognizedPersons);
    if (_persons.isEmpty) _detectFaces();
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  /// Ανίχνευση προσώπων με ML όταν η φωτογραφία δεν έχει ήδη πρόσωπα
  Future<void> _detectFaces() async {
    if (widget.photo.id == null || widget.photo.filePath.isEmpty) return;
    setState(() => _isLoadingFaces = true);
    try {
      final faces = await _mlService.recognizeFaces(widget.photo.filePath, widget.photo.id!);
      if (mounted) {
        setState(() {
          _persons = faces;
          _isLoadingFaces = false;
        });
        if (faces.isNotEmpty) await _savePersonsToDatabase();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFaces = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Πλήρης εικόνα φωτογραφίας
          CustomScrollView(
            slivers: [
              _buildCustomHeader(),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: _buildPhotoImage(),
                  ),
                ),
              ),
            ],
          ),
          // Ενέργειες επικάλυψης (πάνω δεξιά)
          Positioned(
            top: 60,
            right: 16,
            child: _isMenuExpanded
                ? Column(
                    children: [
                      _buildActionButton(Icons.edit, 'Επεξεργασία', _editPhoto),
                      const SizedBox(height: 8),
                      _buildActionButton(Icons.delete, 'Διαγραφή', _deletePhoto),
                      const SizedBox(height: 8),
                      _buildActionButton(Icons.download, 'Κοινοποίηση', _downloadPhoto),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          // Ενότητα ετικετών (κάτω)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_persons.isNotEmpty) _buildPersonsSection(),
                if (_persons.isNotEmpty) const SizedBox(height: 8),
                _buildTagsSection(),
              ],
            ),
          ),
          // Κουμπί αποθήκευσης (πάνω δεξιά όταν το μενού είναι κλειστό)
          if (!_isMenuExpanded)
            Positioned(
              top: 60,
              right: 16,
              child: ElevatedButton(
                onPressed: _savePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Αποθήκευση', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  /// Εμφάνιση εικόνας - asset ή file path
  Widget _buildPhotoImage() {
    final path = widget.photo.filePath;
    if (path.isEmpty) return const Icon(Icons.image, color: Colors.white, size: 64);
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white, size: 64));
    }
    final file = File(path);
    if (!file.existsSync()) return const Icon(Icons.image, color: Colors.white, size: 64);
    return Image.file(file, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white, size: 64));
  }

  Widget _buildCustomHeader() {
    final dateStr = _formatDate(widget.photo.dateTaken);
    
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Smart Gallery',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isMenuExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMenuExpanded = !_isMenuExpanded;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Πρόσωπα',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              if (_isLoadingFaces) ...[
                const SizedBox(width: 8),
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _persons.map((person) {
              return Chip(
                label: Text(person.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                deleteIcon: const Icon(Icons.edit, size: 16, color: Colors.white),
                onDeleted: () => _editPersonName(person),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _editPersonName(Person person) {
    final controller = TextEditingController(text: person.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Επεξεργασία ονόματος'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Εισάγετε όνομα'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ακύρωση')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  final idx = _persons.indexWhere((p) => p.id == person.id || (p.name == person.name && p.photoId == person.photoId));
                  if (idx >= 0) {
                    _persons[idx] = Person(
                      id: person.id,
                      name: name,
                      faceId: person.faceId,
                      photoId: person.photoId,
                      confidence: person.confidence,
                      faceCoordinates: person.faceCoordinates,
                    );
                  }
                });
                Navigator.pop(context);
                _savePersonsToDatabase();
              }
            },
            child: const Text('Αποθήκευση'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePersonsToDatabase() async {
    if (widget.photo.id == null) return;
    try {
      final updatedPhoto = Photo(
        id: widget.photo.id,
        filePath: widget.photo.filePath,
        thumbnailPath: widget.photo.thumbnailPath,
        dateTaken: widget.photo.dateTaken,
        category: widget.photo.category,
        isFavorite: widget.photo.isFavorite,
        tags: _tags,
        location: widget.photo.location,
        recognizedPersons: _persons,
        metadata: widget.photo.metadata,
      );
      await _databaseService.updatePhoto(updatedPhoto);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e')));
    }
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ετικέτες',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(
                  tag.startsWith('#') ? tag : '#$tag',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                onDeleted: () {
                  setState(() => _tags.remove(tag));
                  _saveTagsToDatabase(); // Αποθήκευση αλλαγών στη βάση
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addTag,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text('Προσθήκη ετικέτας', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }

  void _editPhoto() {
    setState(() => _isMenuExpanded = false);
    _addTag(); // Άνοιγμα διαλόγου προσθήκης/επεξεργασίας ετικετών
  }

  void _deletePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Διαγραφή φωτογραφίας'),
        content: const Text('Είστε σίγουροι ότι θέλετε να διαγράψετε αυτή τη φωτογραφία;'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ακύρωση')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (widget.photo.id == null) {
                Navigator.pop(context);
                return;
              }
              try {
                await _databaseService.deletePhoto(widget.photo.id!);
                final file = File(widget.photo.filePath);
                if (file.existsSync()) file.deleteSync();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Φωτογραφία διαγράφηκε')));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e')));
              }
            },
            child: const Text('Διαγραφή', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _downloadPhoto() async {
    setState(() => _isMenuExpanded = false);
    final file = File(widget.photo.filePath);
    if (file.existsSync()) {
      await Share.shareXFiles([XFile(widget.photo.filePath)]);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Το αρχείο δεν βρέθηκε')));
    }
  }

  void _savePhoto() async {
    await _saveTagsToDatabase();
    await _savePersonsToDatabase();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Αποθηκεύτηκε')));
      Navigator.pop(context);
    }
  }

  /// Αποθήκευση tags στη βάση δεδομένων
  Future<void> _saveTagsToDatabase() async {
    if (widget.photo.id == null) return;
    try {
      final updatedPhoto = Photo(
        id: widget.photo.id,
        filePath: widget.photo.filePath,
        thumbnailPath: widget.photo.thumbnailPath,
        dateTaken: widget.photo.dateTaken,
        category: widget.photo.category,
        isFavorite: widget.photo.isFavorite,
        tags: _tags,
        location: widget.photo.location,
        recognizedPersons: _persons,
        metadata: widget.photo.metadata,
      );
      await _databaseService.updatePhoto(updatedPhoto);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα αποθήκευσης: $e')));
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Προσθήκη ετικέτας'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Εισάγετε ετικέτα (π.χ. Καλοκαίρι, Διακοπές)',
              prefixText: '#',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ακύρωση')),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => _tags.add(controller.text.trim()));
                  Navigator.pop(context);
                  _saveTagsToDatabase();
                }
              },
              child: const Text('Προσθήκη'),
            ),
          ],
        );
      },
    );
  }
}
