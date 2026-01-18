import 'package:flutter/material.dart';

/// Dummy Camera Screen (for navigation)
class CameraScreen extends StatelessWidget {
  final bool showSaveButton;
  // Show the save button by default (per request)
  const CameraScreen({super.key, this.showSaveButton = true});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekday = weekdays[now.weekday - 1];
    final dateStr = '$weekday ${now.day}/${now.month}/${now.year}';
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
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
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt, size: 80, color: Colors.white70),
                      SizedBox(height: 16),
                      Text('Camera Screen', style: TextStyle(color: Colors.white70, fontSize: 20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showSaveButton)
            Positioned(
              top: 70,
              right: 24,
              child: GestureDetector(
                onTap: () {},
                child: Image.asset(
                  'assets/icons/Save Icon.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
