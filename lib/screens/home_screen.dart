
import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/screens/photo_detail_screen.dart';
import 'package:smartgallery/screens/search_screen.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/services/camera_service.dart';
import 'package:smartgallery/theme/app_theme.dart';

// Placeholder για το glass navigation bar ώστε να μην υπάρχει undefined error
Widget _buildGlassNavigationBar() {
  return BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
    currentIndex: 0,
    onTap: (index) {},
  );
}

/// Αρχική οθόνη - Home Screen (Gallery View)
/// 
/// Βασισμένο στα Figma designs:
/// - Custom header με date
/// - Gallery grid με φωτογραφίες
/// - Filter και sort options
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      body: CustomScrollView(
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
      bottomNavigationBar: _buildGlassNavigationBar(),
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
      actions: [
        if (_isMenuExpanded) ...[
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterMenu,
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortMenu,
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ],
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
