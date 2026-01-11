import 'package:flutter/material.dart';
import 'package:smartgallery/screens/home_screen.dart';
import 'package:smartgallery/screens/albums_screen.dart';
import 'package:smartgallery/screens/explore_screen.dart';

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
    const HomeScreen(),
    const AlbumsScreen(),
    const ExploreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Albums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Explore',
          ),
        ],
      ),
    );
  }
}

