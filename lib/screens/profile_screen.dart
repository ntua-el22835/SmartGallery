import 'package:flutter/material.dart';
import 'package:smartgallery/models/user.dart';

/// Οθόνη προφίλ χρήστη
/// 
/// Εμφανίζει:
/// - User info
/// - Category preferences (ποιες κατηγορίες να εμφανίζονται)
/// - Favorite photos count
/// - Settings (auto-categorization, etc.)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    // TODO: Load user profile from database
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          CircleAvatar(
            radius: 50,
            backgroundImage: _user!.profileImageUrl != null
                ? NetworkImage(_user!.profileImageUrl!)
                : null,
            child: _user!.profileImageUrl == null
                ? Text(_user!.username[0].toUpperCase())
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _user!.username,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (_user!.email != null) ...[
            const SizedBox(height: 8),
            Text(
              _user!.email!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          // Statistics
          _buildStatistics(),
          const SizedBox(height: 24),
          // Category preferences
          const Text(
            'Category Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildCategoryPreferences(),
          const SizedBox(height: 24),
          // Settings
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSettings(),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_user!.favoritePhotoIds.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Favorites'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_user!.recentPhotoIds.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Recent'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPreferences() {
    // TODO: Build category preferences toggles
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: _user!.categoryPreferences.entries.map((entry) {
          return SwitchListTile(
            title: Text(entry.key),
            value: entry.value,
            onChanged: (value) {
              // TODO: Update category preference
              setState(() {
                _user!.categoryPreferences[entry.key] = value;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Auto-categorization'),
            subtitle: const Text('Automatically categorize new photos'),
            value: _user!.autoCategorizeEnabled,
            onChanged: (value) {
              // TODO: Update setting in database
              setState(() {
                _user = User(
                  id: _user!.id,
                  username: _user!.username,
                  email: _user!.email,
                  profileImageUrl: _user!.profileImageUrl,
                  favoritePhotoIds: _user!.favoritePhotoIds,
                  recentPhotoIds: _user!.recentPhotoIds,
                  categoryPreferences: _user!.categoryPreferences,
                  autoCategorizeEnabled: value,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}

