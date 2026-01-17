
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
    String _formatDate(DateTime date) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final weekday = weekdays[date.weekday - 1];
      return '$weekday ${date.day}/${date.month}/${date.year}';
    }

    @override
    Widget build(BuildContext context) {
      final now = DateTime.now();
      final dateStr = _formatDate(now);
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _isLoading
                  ? SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPhotoThumbnail(_filteredPhotos[index]),
                        childCount: _filteredPhotos.length,
                      ),
                    ),
            ),
          ],
        ),
      );
    }
  late List<Photo> _allPhotos = [];
  late List<Photo> _filteredPhotos = [];
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
      setState(() {
        _isLoading = false;
      });
    }
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

}


