import 'package:flutter/material.dart';
import 'package:smartgallery/models/photo.dart';

/// Οθόνη λεπτομερειών φωτογραφίας
/// 
/// Βασισμένο στα Figma designs:
/// - Full-size photo
/// - Custom header με date
/// - Overlay actions (Edit, Delete, Share/Download)
/// - Tags/hashtags display
/// - Save button
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
  final List<String> _tags = []; // Tags from photo

  @override
  void initState() {
    super.initState();
    _tags.addAll(widget.photo.tags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-size photo
          CustomScrollView(
            slivers: [
              _buildCustomHeader(),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: widget.photo.filePath.isNotEmpty
                        ? Image.asset(
                            widget.photo.filePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, color: Colors.white, size: 64);
                            },
                          )
                        : const Icon(Icons.image, color: Colors.white, size: 64),
                  ),
                ),
              ),
            ],
          ),
          // Overlay actions (top-right)
          Positioned(
            top: 60,
            right: 16,
            child: _isMenuExpanded
                ? Column(
                    children: [
                      _buildActionButton(Icons.edit, 'Edit', _editPhoto),
                      const SizedBox(height: 8),
                      _buildActionButton(Icons.delete, 'Delete', _deletePhoto),
                      const SizedBox(height: 8),
                      _buildActionButton(Icons.download, 'Download', _downloadPhoto),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          // Tags section (bottom)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: _buildTagsSection(),
          ),
          // Save button (top-right when menu collapsed)
          if (!_isMenuExpanded)
            Positioned(
              top: 60,
              right: 16,
              child: ElevatedButton(
                onPressed: _savePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
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

  Widget _buildTagsSection() {
    if (_tags.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'Tags',
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
                  setState(() {
                    _tags.remove(tag);
                  });
                  // TODO: Update tags in database
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addTag,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text('Add Tag', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}/${date.month}/${date.year}';
  }

  void _editPhoto() {
    // TODO: Open photo editor
    setState(() {
      _isMenuExpanded = false;
    });
  }

  void _deletePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Delete photo from database and file system
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _downloadPhoto() {
    // TODO: Download/share photo
    setState(() {
      _isMenuExpanded = false;
    });
  }

  void _savePhoto() {
    // TODO: Save photo changes (tags, favorite status, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo saved')),
    );
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter tag (e.g., Nice, Summer)',
              prefixText: '#',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _tags.add(controller.text.trim());
                  });
                  // TODO: Save tag to database
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
