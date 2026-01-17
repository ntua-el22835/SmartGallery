import 'package:flutter/material.dart';
import 'package:smartgallery/screens/home_screen.dart';
import 'package:smartgallery/screens/albums_screen.dart';
import 'package:smartgallery/screens/camera_screen.dart';

/// Main Navigation Screen με Bottom Navigation Bar
/// 
/// Βασισμένο στα Figma designs:
/// - Home (house icon)
/// - Albums (picture frame icon)
/// - Explore (grid icon)
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CameraScreen(),
    const HomeScreen(),
    const AlbumsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Icon_camera.png',
              color: _currentIndex == 0 ? Colors.white : Colors.white38,
              width: 28,
              height: 28,
            ),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Home.png',
              color: _currentIndex == 1 ? Colors.white : Colors.white38,
              width: 28,
              height: 28,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Image.png',
              color: _currentIndex == 2 ? Colors.white : Colors.white38,
              width: 28,
              height: 28,
            ),
            label: 'Albums',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        showUnselectedLabels: true,
      ),
    );
  }
}

