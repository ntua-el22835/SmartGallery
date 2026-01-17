import 'package:flutter/material.dart';

/// Albums Screen
/// 
/// Εμφανίζει albums/collections φωτογραφιών
/// Βασισμένο στα Figma designs
class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  // State variables
  final List<Map<String, dynamic>> _albums = [];
  bool _filterMenuOpen = false;
  bool _sortOptionsOpen = false;
  String _sortType = 'date'; // 'date' or 'name'
  List<String> _selectedTags = [];
  bool _showTagsMenu = false;
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    // TODO: Load albums from database
  }

  @override
  Widget build(BuildContext context) {
    // Ταξινόμηση albums σύμφωνα με _sortType
    List<Map<String, dynamic>> sortedAlbums = List.from(_albums);
    if (_sortType == 'date') {
      sortedAlbums.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    } else {
      sortedAlbums.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildCustomHeader(),
          SliverToBoxAdapter(child: _buildAlbumFilterMenu()),
          // if (_sortOptionsOpen) SliverToBoxAdapter(child: _buildSortMenu()),
          if (_filterMenuOpen && _showTagsMenu) SliverToBoxAdapter(child: _buildFilterMenu()),
          if (_selectedTags.isNotEmpty) SliverToBoxAdapter(child: _buildTagsBar()),
          _isEmpty
              ? SliverFillRemaining(
                  child: Center(child: Text('No albums found', style: TextStyle(color: Colors.white70)),),
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
    );
  }

  Widget _buildCustomHeader() {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
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
    );
  }

  // αφαιρέθηκε η διπλή έκδοση, κρατάμε μόνο το SliverAppBar

  // ...κρατάω μόνο μία έκδοση της _buildFilterMenu παρακάτω...

  // (Διορθώθηκε: δεν υπάρχει widget tree εκτός μεθόδου)
    Widget _buildSortMenu() {
    // (Removed lower 'Sort albums by:' section as requested)
  Widget _buildAlbumFilterMenu() {
    // Αρχικά μόνο το filter button
    if (!_filterMenuOpen) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
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
    // Όταν ανοίξει, δείχνει τα 4 κουμπιά κάθετα
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
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
            // Sort by (up-down arrow)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_sortOptionsOpen)
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Date'),
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
                        label: const Text('Name'),
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
            // Shuffle (shuffle icon)
            FloatingActionButton(
              heroTag: 'shuffle',
              mini: true,
              backgroundColor: Colors.white12,
                    shape: const CircleBorder(),
                    child: Image.asset('assets/icons/Shuffle.png', width: 24, height: 24, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFilterMenu() {
    // Dummy filter menu for demonstration
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter by tags:', style: TextStyle(color: Colors.white)),
          Wrap(
            spacing: 8,
            children: ['Family', 'Vacation', 'Work', 'Friends'].map((tag) {
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
  }

  Widget _buildAlbumCard(Map<String, dynamic> album) {
    return Card(
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
                  ? Image.asset(
                      album['thumbnail'],
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.photo_library, size: 48, color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album['name'] ?? 'Album',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${album['count'] ?? 0} photos',
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
    );
  }

  Widget _buildEmptyAlbumCard() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[800],
        ),
        child: const Center(
          child: Icon(Icons.add_photo_alternate, size: 48, color: Colors.white70),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }
// αφαιρέθηκε το περιττό κλείσιμο '}'

