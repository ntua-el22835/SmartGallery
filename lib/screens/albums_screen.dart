import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/screens/photo_detail_screen.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/theme/app_theme.dart';

/// Οθόνη Albums - εμφάνιση συλλογών φωτογραφιών ανά κατηγορία
///
/// Περιέχει: Grid albums ανά κατηγορία και tag, φόρτωση από βάση,
/// tap για άνοιγμα grid φωτογραφιών. Βασισμένο στα Figma designs.
class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final List<Map<String, dynamic>> _albums = [];
  List<String> _availableTags = [];
  bool _filterMenuOpen = false;
  bool _sortOptionsOpen = false;
  String _sortType = 'date';
  final List<String> _selectedTags = [];
  bool _showTagsMenu = false;
  bool _isLoading = true;
  final _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  /// Φόρτωση albums και tags από τη βάση δεδομένων
  Future<void> _loadAlbums() async {
    try {
      final albums = await _databaseService.getAlbums();
      final tags = await _databaseService.getAllTags();
      if (mounted) {
        setState(() {
          _albums.clear();
          _albums.addAll(albums);
          _availableTags = tags;
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Φιλτράρισμα albums ανά επιλεγμένα tags
    List<Map<String, dynamic>> filteredAlbums = List.from(_albums);
    if (_selectedTags.isNotEmpty) {
      final tagSet = _selectedTags.map((t) => t.toLowerCase()).toSet();
      filteredAlbums = filteredAlbums.where((a) {
        final type = a['type'] as String?;
        final filter = (a['filter'] as String?)?.toLowerCase() ?? '';
        return type == 'tag' && tagSet.contains(filter);
      }).toList();
    }
    // Ταξινόμηση albums σύμφωνα με _sortType
    List<Map<String, dynamic>> sortedAlbums = List.from(filteredAlbums);
    if (_sortType == 'date') {
      sortedAlbums.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    } else if (_sortType == 'shuffle') {
      sortedAlbums.shuffle(Random());
    } else {
      sortedAlbums.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    }
        final now = DateTime.now();
        final dateStr = _formatDate(now);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Μενού φίλτρου albums (filter, sort, hashtags, shuffle)
          SliverToBoxAdapter(child: _buildAlbumFilterMenu()),
          // Εμφάνιση μενού φίλτρου όταν ανοιχτό
          if (_filterMenuOpen && _showTagsMenu) SliverToBoxAdapter(child: _buildFilterMenu()),
          if (_selectedTags.isNotEmpty) SliverToBoxAdapter(child: _buildTagsBar()),
          sortedAlbums.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      _selectedTags.isNotEmpty ? 'Δεν βρέθηκαν albums με τις επιλεγμένες ετικέτες' : 'Δεν βρέθηκαν albums',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAlbumCard(sortedAlbums[index]),
                      childCount: sortedAlbums.length,
                    ),
                  ),
                ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  // αφαιρέθηκε η διπλή έκδοση, κρατάμε μόνο το SliverAppBar

  // ...κρατάω μόνο μία έκδοση της _buildFilterMenu παρακάτω...

  // (Διορθώθηκε: δεν υπάρχει widget tree εκτός μεθόδου)
  Widget _buildAlbumFilterMenu() {
    // Αρχικά μόνο το filter button
    if (!_filterMenuOpen) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 24),
          child: FloatingActionButton(
            heroTag: 'filter',
            mini: true,
            backgroundColor: Colors.white12,
                shape: const CircleBorder(),
                child: Image.asset('assets/icons/Filter.png', width: 24, height: 24, color: Colors.white),
            onPressed: () {
              setState(() {
                _filterMenuOpen = true;
                _showTagsMenu = false;
              });
            },
          ),
        ),
      );
    }
    // Αναπτυγμένη κατάσταση: τα 4 κουμπιά κάθετα (collapse, sort, hashtags, shuffle)
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Κουμπί collapse (down arrow)
            FloatingActionButton(
              heroTag: 'collapse',
              mini: true,
              backgroundColor: Colors.white12,
                    shape: const CircleBorder(),
                    child: Image.asset('assets/icons/Down arrow.png', width: 24, height: 24, color: Colors.white),
              onPressed: () {
                setState(() {
                  _filterMenuOpen = false;
                  _sortOptionsOpen = false;
                  _showTagsMenu = false;
                });
              },
            ),
            const SizedBox(height: 8),
            // Ταξινόμηση (βέλος πάνω-κάτω)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_sortOptionsOpen)
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Ημερομηνία'),
                        selected: _sortType == 'date',
                        shape: const StadiumBorder(),
                        onSelected: (val) {
                          setState(() {
                            _sortType = 'date';
                            _sortOptionsOpen = false;
                          });
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(color: _sortType == 'date' ? Colors.black : Colors.white),
                      ),
                      ChoiceChip(
                        label: const Text('Όνομα'),
                        selected: _sortType == 'name',
                        shape: const StadiumBorder(),
                        onSelected: (val) {
                          setState(() {
                            _sortType = 'name';
                            _sortOptionsOpen = false;
                          });
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(color: _sortType == 'name' ? Colors.black : Colors.white),
                      ),
                      ChoiceChip(
                        label: const Text('Τυχαία'),
                        selected: _sortType == 'shuffle',
                        shape: const StadiumBorder(),
                        onSelected: (val) {
                          setState(() {
                            _sortType = 'shuffle';
                            _sortOptionsOpen = false;
                          });
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(color: _sortType == 'shuffle' ? Colors.black : Colors.white),
                      ),
                    ],
                  ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  heroTag: 'sort',
                  mini: true,
                  backgroundColor: Colors.white12,
                  shape: const CircleBorder(),
                  child: Image.asset('assets/icons/sort by (up and down arrow).png', width: 24, height: 24, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _sortOptionsOpen = !_sortOptionsOpen;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Hashtags (τριλίζα)
            FloatingActionButton(
              heroTag: 'hashtags',
              mini: true,
              backgroundColor: Colors.white12,
                    shape: const CircleBorder(),
                    child: Image.asset('assets/icons/Hash.png', width: 24, height: 24, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showTagsMenu = !_showTagsMenu;
                });
              },
            ),
            const SizedBox(height: 8),
            // Τυχαία σειρά (εικονίδιο shuffle)
            FloatingActionButton(
              heroTag: 'shuffle',
              mini: true,
              backgroundColor: Colors.white12,
                    shape: const CircleBorder(),
                    child: Image.asset('assets/icons/Shuffle.png', width: 24, height: 24, color: Colors.white),
              onPressed: () {
                setState(() {
                  _sortType = 'shuffle';
                  _sortOptionsOpen = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }


  /// Κατασκευή μενού φίλτρου ανά ετικέτα (tags από τη βάση δεδομένων)
  Widget _buildFilterMenu() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Φίλτρο ανά ετικέτα:', style: TextStyle(color: Colors.white)),
          if (_availableTags.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Δεν υπάρχουν ετικέτες. Προσθέστε ετικέτες στις φωτογραφίες σας.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
              final selected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: selected,
                shape: const StadiumBorder(),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.grey[800],
                labelStyle: TextStyle(color: selected ? Colors.black : Colors.white),
              );
            }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTagsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: _selectedTags.map((tag) => Chip(
          label: Text(tag),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: Colors.black),
          onDeleted: () {
            setState(() {
              _selectedTags.remove(tag);
            });
          },
        )).toList(),
      ),
    );
  }

  Widget _buildAlbumCard(Map<String, dynamic> album) {
    return GestureDetector(
      onTap: () => _openAlbum(album),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[800],
                ),
                child: album['thumbnail'] != null
                    ? _buildAlbumThumbnail(album['thumbnail'])
                    : const Icon(Icons.photo_library, size: 48, color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album['name'] ?? 'Άλμπουμ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${album['count'] ?? 0} φωτογραφίες',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAlbum(Map<String, dynamic> album) async {
    final albumId = album['id'] as String?;
    if (albumId == null) return;
    final photos = await _databaseService.getPhotosForAlbum(albumId);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AlbumPhotosScreen(
          title: album['name'] ?? 'Άλμπουμ',
          photos: photos,
        ),
      ),
    );
  }

  Widget _buildAlbumThumbnail(dynamic path) {
    if (path == null || path.toString().isEmpty) return const Icon(Icons.photo_library, size: 48, color: Colors.white70);
    final p = path.toString();
    if (p.startsWith('assets/')) {
      return Image.asset(p, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.photo_library, size: 48, color: Colors.white70));
    }
    final file = File(p);
    if (!file.existsSync()) return const Icon(Icons.photo_library, size: 48, color: Colors.white70);
    return Image.file(file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.photo_library, size: 48, color: Colors.white70));
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
}

/// Οθόνη φωτογραφιών ενός album
class _AlbumPhotosScreen extends StatelessWidget {
  final String title;
  final List<Photo> photos;

  const _AlbumPhotosScreen({required this.title, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: photos.isEmpty
          ? const Center(child: Text('Δεν υπάρχουν φωτογραφίες', style: TextStyle(color: Colors.white70)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => PhotoDetailScreen(photo: photo),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.photoPlaceholderColor,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildPhotoImage(photo.filePath, photo.thumbnailPath),
                    ),
                  ),
                );
              },
            ),
    );
  }

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
}

