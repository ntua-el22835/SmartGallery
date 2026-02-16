import 'package:flutter/material.dart';
import 'package:smartgallery/screens/home_screen.dart';
import 'package:smartgallery/screens/albums_screen.dart';
import 'package:smartgallery/screens/camera_screen.dart';
import 'package:smartgallery/screens/discover_screen.dart';
import 'package:smartgallery/screens/profile_screen.dart';

/// Κύριο navigation με Bottom Navigation Bar
/// 
/// Τα tabs: Camera, Home, Discover, Albums, Profile
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}


class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // Τρέχον tab
  int _homeRefreshKey = 0; // Κλειδί ανανέωσης για HomeScreen όταν αποθηκεύεται φωτογραφία

  /// Λίστα οθονών για κάθε tab
  List<Widget> get _screens => [
    CameraScreen(onPhotoSaved: () {
      setState(() {
        _homeRefreshKey++;
        _currentIndex = 1;
      });
    }),
    HomeScreen(key: ValueKey(_homeRefreshKey), onEditTags: () => setState(() => _currentIndex = 0)),
    const DiscoverScreen(),
    const AlbumsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Κύριο layout με IndexedStack για διατήρηση state των tabs
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Κάτω γραμμή πλοήγησης με 5 tabs
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
            icon: Icon(Icons.explore, color: _currentIndex == 2 ? Colors.white : Colors.white38, size: 28),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Image.png',
              color: _currentIndex == 3 ? Colors.white : Colors.white38,
              width: 28,
              height: 28,
            ),
            label: 'Albums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _currentIndex == 4 ? Colors.white : Colors.white38, size: 28),
            label: 'Profile',
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

