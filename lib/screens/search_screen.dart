import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';
import 'package:smartgallery/models/person.dart';
import 'package:smartgallery/models/location.dart';
import 'package:smartgallery/screens/photo_detail_screen.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/theme/app_theme.dart';

/// Οθόνη αναζήτησης φωτογραφιών
///
/// Περιέχει: Αναζήτηση κατά filename και tags, φίλτρα (ημερομηνία,
/// τοποθεσία, άτομα, αγαπημένα), grid αποτελεσμάτων.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Photo> _searchResults = [];
  final _databaseService = DatabaseService();
  
  // Κατάσταση φίλτρων
  PhotoCategory? _selectedCategory;
  Person? _selectedPerson;
  Location? _selectedLocation;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _favoritesOnly = false;
  bool _showFilterMenu = false;

  @override
  void initState() {
    super.initState();
    _performSearch(); // Αρχική φόρτωση όλων των φωτογραφιών
  }

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
              if (_searchResults.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text('Δεν βρέθηκαν αποτελέσματα', style: TextStyle(color: Colors.white70))),
                )
              else
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
                      if (_searchResults.isEmpty) {
                        return const Center(child: Text('Δεν βρέθηκαν αποτελέσματα', style: TextStyle(color: Colors.white70)));
                      }
                      if (index >= _searchResults.length) return const SizedBox.shrink();
                      return _buildPhotoThumbnail(_searchResults[index]);
                    },
                    childCount: _searchResults.length,
                  ),
                ),
              ),
            ],
          ),
          // Επικάλυψη μενού φίλτρων
          if (_showFilterMenu) _buildFilterOverlay(),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Κεφαλίδα με γραμμή αναζήτησης
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Αναζήτηση...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.search, color: Colors.white70), onPressed: _performSearch),
                Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white70),
                  onPressed: () => setState(() => _showFilterMenu = !_showFilterMenu),
                ),
              ],
            ),
          ),
        ],
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoDetailScreen(photo: photo))),
      child: Container(
        color: AppTheme.photoPlaceholderColor,
        child: _buildPhotoImage(photo.filePath, photo.thumbnailPath),
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

  void _showLocationPicker() async {
    final locations = await _databaseService.getAllLocations();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Επιλογή τοποθεσίας', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.white70),
              title: const Text('Καθαρισμός φίλτρου', style: TextStyle(color: Colors.white70)),
              onTap: () {
                setState(() {
                  _selectedLocation = null;
                  _showFilterMenu = false;
                });
                Navigator.pop(context);
                _performSearch();
              },
            ),
            if (locations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Δεν υπάρχουν τοποθεσίες', style: TextStyle(color: Colors.white70)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locations.length,
                  itemBuilder: (context, i) {
                    final loc = locations[i];
                    final label = loc.placeName ?? loc.city ?? loc.country ?? '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}';
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.white70),
                      title: Text(label, style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() {
                          _selectedLocation = loc;
                          _showFilterMenu = false;
                        });
                        Navigator.pop(context);
                        _performSearch();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPeoplePicker() async {
    final persons = await _databaseService.getAllPersons();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Επιλογή προσώπου', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.white70),
              title: const Text('Καθαρισμός φίλτρου', style: TextStyle(color: Colors.white70)),
              onTap: () {
                setState(() {
                  _selectedPerson = null;
                  _showFilterMenu = false;
                });
                Navigator.pop(context);
                _performSearch();
              },
            ),
            if (persons.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Δεν υπάρχουν αναγνωρισμένα πρόσωπα', style: TextStyle(color: Colors.white70)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: persons.length,
                  itemBuilder: (context, i) {
                    final person = persons[i];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.white70),
                      title: Text(person.name, style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() {
                          _selectedPerson = person;
                          _showFilterMenu = false;
                        });
                        Navigator.pop(context);
                        _performSearch();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Αναζήτηση φωτογραφιών στη βάση με φίλτρα
  Future<void> _performSearch() async {
    try {
      final photos = await _databaseService.getPhotos(
        category: _selectedCategory,
        locationId: _selectedLocation?.id,
        personId: _selectedPerson?.id,
        startDate: _startDate,
        endDate: _endDate,
        favoritesOnly: _favoritesOnly,
      );
      // Φιλτράρισμα κατά κείμενο αναζήτησης (filename, tags)
      var results = photos;
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        results = photos.where((p) {
          final pathMatch = p.filePath.toLowerCase().contains(query);
          final tagMatch = p.tags.any((t) => t.toLowerCase().contains(query));
          return pathMatch || tagMatch;
        }).toList();
      }
      setState(() {
        _searchResults.clear();
        _searchResults.addAll(results);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e')));
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
}
