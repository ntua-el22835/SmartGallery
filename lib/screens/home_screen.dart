import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/screens/photo_detail_screen.dart';
import 'package:smartgallery/screens/search_screen.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/services/camera_service.dart';
import 'package:smartgallery/theme/app_theme.dart';
import 'package:smartgallery/screens/camera_screen.dart'; // <-- Missing import added


/// Αρχική οθόνη - Home Screen (Gallery View)
/// 
/// Βασισμένο στα Figma designs:
/// - Custom header με date
/// - Gallery grid με φωτογραφίες
/// - Filter και sort options

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
  bool _isMenuExpanded = false;
  bool _isLoading = true;
  final _databaseService = DatabaseService();
  final _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final photos = await _databaseService.getPhotos();
      setState(() {
        _allPhotos = photos;
        _filteredPhotos = photos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading photos: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ΝΕΟ: State για το custom floating menu
    bool _fabMenuOpen = false;

    return StatefulBuilder(
      builder: (context, setFabState) => Scaffold(
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
                          const Text('No photos yet', style: TextStyle(color: Colors.white70)),
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
                        (context, index) => _buildPhotoThumbnail(_filteredPhotos[index]),
                        childCount: _filteredPhotos.length,
                      ),
                    ),
                  ),
                SliverPadding(padding: const EdgeInsets.only(bottom: 100)),
              ],
            ),
            // Floating menu δεξιά, στο ύψος του volume up button
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
                      onPressed: () => setFabState(() => _fabMenuOpen = false),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'fab_edit',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: Image.asset('assets/icons/Edit Icon.png', width: 24, height: 24, color: Colors.white),
                      onPressed: () {
                        if (widget.onEditTags != null) {
                          widget.onEditTags!();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'fab_share',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: Image.asset('assets/icons/Share Icon.png', width: 24, height: 24, color: Colors.white),
                      onPressed: () {}, // TODO: share photo
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'fab_delete',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: Image.asset('assets/icons/Trash Icon.png', width: 24, height: 24, color: Colors.white),
                      onPressed: () {}, // TODO: delete photo
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    FloatingActionButton(
                      heroTag: 'fab_expand',
                      mini: true,
                      backgroundColor: Colors.white12,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      onPressed: () => setFabState(() => _fabMenuOpen = true),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            // Match Camera/Albums: show only the date at the right
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
      // Removed actions opened by the upper down-arrow (filter/sort/search)
    );
  }

  Widget _buildPhotoThumbnail(Photo photo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(photo: photo),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppTheme.photoPlaceholderColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: (photo.filePath.isNotEmpty)
              ? Image.asset(
                  photo.filePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.white30),
                )
              : Container(
                  color: AppTheme.photoPlaceholderColor,
                  child: const Icon(Icons.image, color: Colors.white30),
                ),
        ),
      ),
    );
  }


  void _showFilterMenu() {
    // TODO: Implement filter menu
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
            _buildFilterOption('Date', Icons.calendar_today, _selectedFilter == 'Date'),
            _buildFilterOption('Location', Icons.location_on, _selectedFilter == 'Location'),
            _buildFilterOption('People', Icons.person, _selectedFilter == 'People'),
            _buildFilterOption('Favorites', Icons.star, _selectedFilter == 'Favorites'),
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
            _buildSortOption('Newest First', false),
            _buildSortOption('Oldest First', false),
            _buildSortOption('Name (A-Z)', false),
            _buildSortOption('Name (Z-A)', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white),
      title: Text(label, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white)),
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? null : label;
        });
        Navigator.pop(context);
        // TODO: Apply filter
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
        Navigator.pop(context);
        // TODO: Apply sort
      },
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
}
