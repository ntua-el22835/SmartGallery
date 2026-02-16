import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/screens/photo_detail_screen.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/theme/app_theme.dart';

/// Οθόνη Εξερεύνησης - εμφάνιση όλων των φωτογραφιών
///
/// Περιέχει: Grid όλων των φωτογραφιών με φίλτρα και ταξινόμηση.
/// Βασισμένο στα Figma designs.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Photo> _allPhotos = []; // Λίστα φωτογραφιών για εμφάνιση
  String? _selectedFilter; // Επιλεγμένο φίλτρο (ημερομηνία, τοποθεσία, κλπ.)
  String? _selectedSort; // Επιλεγμένη ταξινόμηση
  bool _isLoading = true; // Κατάσταση φόρτωσης
  final _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  /// Φόρτωση φωτογραφιών από τη βάση με φίλτρα
  Future<void> _loadPhotos() async {
    try {
      var photos = await _databaseService.getPhotos(favoritesOnly: _selectedFilter == 'Favorites' ? true : null);
      if (_selectedSort == 'Παλαιότερα πρώτα') {
        photos = List.from(photos)..sort((a, b) => a.dateTaken.compareTo(b.dateTaken));
      } else if (_selectedSort == 'Όνομα (Α-Ω)') {
        photos = List.from(photos)..sort((a, b) => a.filePath.split('/').last.compareTo(b.filePath.split('/').last));
      } else if (_selectedSort == 'Όνομα (Ω-Α)') {
        photos = List.from(photos)..sort((a, b) => b.filePath.split('/').last.compareTo(a.filePath.split('/').last));
      } else {
        photos = List.from(photos)..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
      }
      setState(() {
        _allPhotos.clear();
        _allPhotos.addAll(photos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e')));
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
    // Κύριο layout: CustomScrollView με header και grid φωτογραφιών
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildCustomHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (_allPhotos.isEmpty) {
                    return const Center(child: Text('Δεν υπάρχουν φωτογραφίες', style: TextStyle(color: Colors.white70)));
                  }
                  if (index >= _allPhotos.length) return const SizedBox.shrink();
                  return _buildPhotoThumbnail(_allPhotos[index]);
                },
                childCount: _allPhotos.isEmpty ? 1 : _allPhotos.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Κεφαλίδα οθόνης με τίτλο, ημερομηνία και κουμπιά φίλτρου/ταξινόμησης
  Widget _buildCustomHeader() {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Smart Gallery',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterMenu,
                ),
                IconButton(
                  icon: const Icon(Icons.sort, color: Colors.white),
                  onPressed: _showSortMenu,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(Photo photo) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoDetailScreen(photo: photo)));
        _loadPhotos();
      },
      child: Container(
        color: AppTheme.photoPlaceholderColor,
        child: _buildPhotoImage(photo.filePath, photo.thumbnailPath),
      ),
    );
  }

  /// Εμφάνιση εικόνας φωτογραφίας - asset path ή file path
  Widget _buildPhotoImage(String filePath, String? thumbnailPath) {
    final path = thumbnailPath ?? filePath;
    if (path.isEmpty) return const Icon(Icons.image, color: Colors.white30);
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white30));
    }
    final file = File(path);
    if (!file.existsSync()) return const Icon(Icons.image, color: Colors.white30);
    return Image.file(file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white30));
  }

  /// Μενού φίλτρου - ημερομηνία, τοποθεσία, άτομα, αγαπημένα
  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Ημερομηνία', Icons.calendar_today, _selectedFilter == 'Date'),
            _buildFilterOption('Τοποθεσία', Icons.location_on, _selectedFilter == 'Location'),
            _buildFilterOption('Άτομα', Icons.person, _selectedFilter == 'People'),
            _buildFilterOption('Αγαπημένα', Icons.star, _selectedFilter == 'Favorites'),
          ],
        ),
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Νεότερα πρώτα', _selectedSort == 'Νεότερα πρώτα'),
            _buildSortOption('Παλαιότερα πρώτα', _selectedSort == 'Παλαιότερα πρώτα'),
            _buildSortOption('Όνομα (Α-Ω)', _selectedSort == 'Όνομα (Α-Ω)'),
            _buildSortOption('Όνομα (Ω-Α)', _selectedSort == 'Όνομα (Ω-Α)'),
          ],
        ),
      ),
    );
  }

  /// Επιλογή φίλτρου στο bottom sheet
  Widget _buildFilterOption(String label, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white),
      title: Text(label, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white)),
      onTap: () {
        setState(() => _selectedFilter = isSelected ? null : label);
        Navigator.pop(context);
        _loadPhotos();
      },
    );
  }

  Widget _buildSortOption(String label, bool isSelected) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _selectedSort = label);
        Navigator.pop(context);
        _loadPhotos();
      },
    );
  }

  /// Μορφοποίηση ημερομηνίας σε ελληνικό format (π.χ. Δευτέρα 29/1/2025)
  String _formatDate(DateTime date) {
    final weekdays = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
}

