import 'package:flutter/material.dart';
bool _sortMenuOpen = false;
String _sortType = 'date'; // 'date' or 'name'

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
    Widget _buildFilterSortBar() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.filter_alt, color: _filterOpen ? Colors.white : Colors.white38),
              onPressed: () {
                setState(() {
                  _filterOpen = !_filterOpen;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.sort, color: _sortMenuOpen ? Colors.white : Colors.white38),
              onPressed: () {
                setState(() {
                  _sortMenuOpen = !_sortMenuOpen;
                });
              },
            ),
          ],
        ),
      );
    }

    // ...κρατάμε μόνο μία έκδοση της _buildFilterMenu παρακάτω...

    // ...κρατάμε μόνο μία έκδοση της _buildTagsBar παρακάτω...
  final List<Map<String, dynamic>> _albums = [];
  bool _filterOpen = false;
  // αφαιρέθηκε, χρησιμοποιούμε _sortMenuOpen και _sortType
  List<String> _selectedTags = [];
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
          SliverToBoxAdapter(child: _buildFilterSortBar()),
          if (_sortMenuOpen) SliverToBoxAdapter(child: _buildSortMenu()),
          if (_filterOpen) SliverToBoxAdapter(child: _buildFilterMenu()),
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
  // ...η μέθοδος _buildSortMenu πρέπει να είναι μέλος της κλάσης, όχι μέσα στη build ή σε λάθος σημείο...
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

  // αφαιρέθηκε η διπλή έκδοση, κρατάμε μόνο το SliverAppBar

  // ...κρατάω μόνο μία έκδοση της _buildFilterMenu παρακάτω...

  // κρατάμε μόνο την έκδοση με _sortMenuOpen
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.filter_alt, color: _filterOpen ? Colors.white : Colors.white38),
            onPressed: () {
              setState(() {
                _filterOpen = !_filterOpen;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.sort, color: _sortMenuOpen ? Colors.white : Colors.white38),
            onPressed: () {
              setState(() {
                _sortMenuOpen = !_sortMenuOpen;
              });
            },
          ),
        ],
      ),
    );
  }
  Widget _buildSortMenu() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort albums by:', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text('Date'),
                selected: _sortType == 'date',
                onSelected: (val) {
                  setState(() {
                    _sortType = 'date';
                    _sortMenuOpen = false;
                  });
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.grey[800],
                labelStyle: TextStyle(color: _sortType == 'date' ? Colors.black : Colors.white),
              ),
              ChoiceChip(
                label: Text('Name'),
                selected: _sortType == 'name',
                onSelected: (val) {
                  setState(() {
                    _sortType = 'name';
                    _sortMenuOpen = false;
                  });
                },
                selectedColor: Colors.white,
                backgroundColor: Colors.grey[800],
                labelStyle: TextStyle(color: _sortType == 'name' ? Colors.black : Colors.white),
              ),
            ],
          ),
        ],
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

