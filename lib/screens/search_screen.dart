import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/models/person.dart';
import 'package:smartgallery/models/location.dart';

/// Οθόνη αναζήτησης φωτογραφιών
/// 
/// Βασισμένο στα Figma designs:
/// - Custom header με date
/// - Overlay filter menu
/// - Search results grid
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Photo> _searchResults = [];
  
  // Filter states
  PhotoCategory? _selectedCategory;
  Person? _selectedPerson;
  Location? _selectedLocation;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _favoritesOnly = false;
  bool _showFilterMenu = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
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
                      if (index >= _searchResults.length) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.white30),
                          ),
                        );
                      }
                      return _buildPhotoThumbnail(_searchResults[index]);
                    },
                    childCount: _searchResults.isEmpty ? 12 : _searchResults.length,
                  ),
                ),
              ),
            ],
          ),
          // Filter overlay menu
          if (_showFilterMenu) _buildFilterOverlay(),
        ],
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
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showFilterMenu = !_showFilterMenu;
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

  Widget _buildFilterOverlay() {
    return Positioned(
      top: 60,
      left: 16,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 8,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterMenuItem('Date', Icons.calendar_today, _selectedCategory == null && _selectedLocation == null && _selectedPerson == null && !_favoritesOnly),
              _buildFilterMenuItem('Location', Icons.location_on, _selectedLocation != null),
              _buildFilterMenuItem('People', Icons.person, _selectedPerson != null),
              _buildFilterMenuItem('Favorites', Icons.star, _favoritesOnly),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterMenuItem(String label, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          if (label == 'Date') {
            _showDatePicker();
          } else if (label == 'Location') {
            _showLocationPicker();
          } else if (label == 'People') {
            _showPeoplePicker();
          } else if (label == 'Favorites') {
            _favoritesOnly = !_favoritesOnly;
          }
          _showFilterMenu = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(Photo photo) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to photo detail
      },
      child: Container(
        color: Colors.grey[800],
        child: photo.thumbnailPath != null
            ? Image.asset(
                photo.thumbnailPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, color: Colors.white30);
                },
              )
            : const Icon(Icons.image, color: Colors.white30),
      ),
    );
  }

  void _showDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((dates) {
      if (dates != null) {
        setState(() {
          _startDate = dates.start;
          _endDate = dates.end;
        });
        _performSearch();
      }
    });
  }

  void _showLocationPicker() {
    // TODO: Show location picker dialog
    _performSearch();
  }

  void _showPeoplePicker() {
    // TODO: Show people picker dialog
    _performSearch();
  }

  Future<void> _performSearch() async {
    // TODO: Search photos from database
    // TODO: Apply filters (category, person, location, date range, favorites)
    // TODO: Update _searchResults
    setState(() {
      // _searchResults = results;
    });
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
}
