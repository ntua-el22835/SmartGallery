import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/screens/photo_detail_screen.dart';
import 'package:smartgallery/screens/search_screen.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/theme/app_theme.dart';

/// Αρχική οθόνη - Gallery με φωτογραφίες
///
/// Περιέχει: Grid φωτογραφιών, φίλτρα (ημερομηνία, τοποθεσία, άτομα),
/// ταξινόμηση, αναζήτηση, floating menu για ενέργειες.

typedef EditTagsCallback = void Function();
class HomeScreen extends StatefulWidget {
  final EditTagsCallback? onEditTags;
  const HomeScreen({super.key, this.onEditTags});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Photo> _allPhotos = [];
  late List<Photo> _filteredPhotos = [];
  String? _selectedFilter;
  bool _fabMenuOpen = false;
  final Set<int> _selectedPhotoIds = {};
  bool _isLoading = true;
  final _databaseService = DatabaseService();
  // Παράμετροι φίλτρου και ταξινόμησης
  PhotoCategory? _selectedCategory;
  int? _locationId;
  int? _personId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _favoritesOnly = false;
  String _sortBy = 'Νεότερα πρώτα';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  /// Φόρτωση φωτογραφιών από τη βάση με εφαρμογή φίλτρων
  Future<void> _loadPhotos() async {
    try {
      var photos = await _databaseService.getPhotos(
        category: _selectedCategory,
        locationId: _locationId,
        personId: _personId,
        startDate: _startDate,
        endDate: _endDate,
        favoritesOnly: _favoritesOnly,
      );
      // Εφαρμογή ταξινόμησης
      photos = _applySort(photos);
      setState(() {
        _allPhotos = photos;
        _filteredPhotos = photos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα φόρτωσης: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  /// Ταξινόμηση λίστας φωτογραφιών
  List<Photo> _applySort(List<Photo> photos) {
    final sorted = List<Photo>.from(photos);
    switch (_sortBy) {
      case 'Παλαιότερα πρώτα':
        sorted.sort((a, b) => a.dateTaken.compareTo(b.dateTaken));
        break;
      case 'Όνομα (Α-Ω)':
        sorted.sort((a, b) => a.filePath.split('/').last.compareTo(b.filePath.split('/').last));
        break;
      case 'Όνομα (Ω-Α)':
        sorted.sort((a, b) => b.filePath.split('/').last.compareTo(a.filePath.split('/').last));
        break;
      default: // Νεότερα πρώτα
        sorted.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildCustomHeader(),
                if (_filteredPhotos.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 64, color: Colors.white30),
                          const SizedBox(height: 16),
                          const Text('Δεν υπάρχουν ακόμα φωτογραφίες', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPhotoThumbnail(_filteredPhotos[index], _fabMenuOpen),
                        childCount: _filteredPhotos.length,
                      ),
                    ),
                  ),
                SliverPadding(padding: const EdgeInsets.only(bottom: 100)),
              ],
            ),
            // Προσαρμοσμένο floating menu δεξιά
            Positioned(
              right: 24,
              top: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_fabMenuOpen) ...[
                    FloatingActionButton(
                      heroTag: 'fab_collapse',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: Image.asset('assets/icons/arrow up Icon.png', width: 24, height: 24, color: Colors.white),
                      onPressed: () => setState(() {
                        _fabMenuOpen = false;
                        _selectedPhotoIds.clear();
                      }),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'fab_edit',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: Image.asset('assets/icons/Edit Icon.png', width: 24, height: 24, color: Colors.white),
                      onPressed: () => _onEditSelected(),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'fab_share',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: Image.asset('assets/icons/Share Icon.png', width: 24, height: 24, color: Colors.white),
                      onPressed: () => _onShareSelected(),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'fab_delete',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: Image.asset('assets/icons/Trash Icon.png', width: 24, height: 24, color: Colors.white),
                      onPressed: () => _onDeleteSelected(),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    FloatingActionButton(
                      heroTag: 'fab_expand',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      onPressed: () => setState(() => _fabMenuOpen = true),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    );
  }

  void _onEditSelected() async {
    if (_selectedPhotoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Επιλέξτε φωτογραφία για επεξεργασία ετικετών')));
      return;
    }
    final photo = _filteredPhotos.firstWhere((p) => p.id != null && _selectedPhotoIds.contains(p.id));
    await Navigator.push(context, MaterialPageRoute(builder: (c) => PhotoDetailScreen(photo: photo)));
    setState(() {
      _fabMenuOpen = false;
      _selectedPhotoIds.clear();
    });
    _loadPhotos();
  }

  void _onShareSelected() async {
    if (_selectedPhotoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Επιλέξτε φωτογραφίες για κοινοποίηση')));
      return;
    }
    final toShare = _filteredPhotos.where((p) => p.id != null && _selectedPhotoIds.contains(p.id)).toList();
    final files = toShare.map((p) => XFile(p.filePath)).where((x) => File(x.path).existsSync()).toList();
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Τα αρχεία δεν βρέθηκαν')));
      return;
    }
    await Share.shareXFiles(files);
    setState(() {
      _fabMenuOpen = false;
      _selectedPhotoIds.clear();
    });
  }

  void _onDeleteSelected() async {
    if (_selectedPhotoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Επιλέξτε φωτογραφίες για διαγραφή')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Διαγραφή φωτογραφιών'),
        content: Text('Διαγραφή ${_selectedPhotoIds.length} φωτογραφιών;'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Ακύρωση')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Διαγραφή', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final toDelete = _filteredPhotos.where((p) => p.id != null && _selectedPhotoIds.contains(p.id)).toList();
    for (final photo in toDelete) {
      await _databaseService.deletePhoto(photo.id!);
      final file = File(photo.filePath);
      if (file.existsSync()) file.deleteSync();
    }
    setState(() {
      _fabMenuOpen = false;
      _selectedPhotoIds.clear();
    });
    _loadPhotos();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Οι φωτογραφίες διαγράφηκαν')));
  }

  Widget _buildCustomHeader() {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/icons/smart gallery logo.png', height: 28),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()))),
                IconButton(icon: const Icon(Icons.filter_list, color: Colors.white70), onPressed: _showFilterMenu),
                IconButton(icon: const Icon(Icons.sort, color: Colors.white70), onPressed: _showSortMenu),
                Text(dateStr, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Μικρογραφία φωτογραφίας - σε λειτουργία επιλογής: tap για toggle, μπλε τικ κάτω δεξιά
  Widget _buildPhotoThumbnail(Photo photo, bool isSelectionMode) {
    final isSelected = photo.id != null && _selectedPhotoIds.contains(photo.id);
    return GestureDetector(
      onTap: () async {
        if (isSelectionMode) {
          if (photo.id != null) {
            setState(() {
              if (isSelected) {
                _selectedPhotoIds.remove(photo.id);
              } else {
                _selectedPhotoIds.add(photo.id!);
              }
            });
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoDetailScreen(photo: photo),
            ),
          );
          _loadPhotos();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: AppTheme.photoPlaceholderColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _buildPhotoImage(photo.filePath.isNotEmpty ? photo.filePath : null, photo.thumbnailPath, BoxFit.cover),
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  /// Εμφάνιση εικόνας - asset path ή file path
  Widget _buildPhotoImage(String? filePath, String? thumbnailPath, BoxFit fit) {
    final path = thumbnailPath ?? filePath;
    if (path == null || path.isEmpty) {
      return Container(color: AppTheme.photoPlaceholderColor, child: const Icon(Icons.image, color: Colors.white30));
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white30));
    }
    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.image, color: Colors.white30);
    }
    return Image.file(file, fit: fit, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white30));
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
            ListTile(
              leading: Icon(Icons.calendar_today, color: _selectedFilter == 'Date' ? Theme.of(context).colorScheme.primary : Colors.white),
              title: Text('Ημερομηνία', style: TextStyle(color: _selectedFilter == 'Date' ? Theme.of(context).colorScheme.primary : Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final dates = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)), end: _endDate ?? DateTime.now()),
                );
                if (dates != null) {
                  setState(() {
                    _selectedFilter = 'Date';
                    _startDate = dates.start;
                    _endDate = dates.end;
                  });
                  _loadPhotos();
                }
              },
            ),
            _buildFilterOption('Τοποθεσία', Icons.location_on, _selectedFilter == 'Location', () => _selectedFilter = 'Location'),
            _buildFilterOption('Άτομα', Icons.person, _selectedFilter == 'People', () => _selectedFilter = 'People'),
            _buildFilterOption('Αγαπημένα', Icons.star, _favoritesOnly, () {
              _favoritesOnly = !_favoritesOnly;
              _selectedFilter = _favoritesOnly ? 'Favorites' : null;
            }),
            ListTile(
              title: const Text('Καθαρισμός φίλτρων', style: TextStyle(color: Colors.white70)),
              leading: const Icon(Icons.clear, color: Colors.white70),
              onTap: () {
                _selectedFilter = null;
                _selectedCategory = null;
                _locationId = null;
                _personId = null;
                _startDate = null;
                _endDate = null;
                _favoritesOnly = false;
                Navigator.pop(context);
                _loadPhotos();
              },
            ),
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
            _buildSortOption('Νεότερα πρώτα', _sortBy == 'Νεότερα πρώτα'),
            _buildSortOption('Παλαιότερα πρώτα', _sortBy == 'Παλαιότερα πρώτα'),
            _buildSortOption('Όνομα (Α-Ω)', _sortBy == 'Όνομα (Α-Ω)'),
            _buildSortOption('Όνομα (Ω-Α)', _sortBy == 'Όνομα (Ω-Α)'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white),
      title: Text(label, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white)),
      onTap: () {
        setState(() => onTap());
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
        setState(() => _sortBy = label);
        Navigator.pop(context);
        _loadPhotos();
      },
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
}
