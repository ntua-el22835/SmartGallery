import 'package:flutter/material.dart';
import 'package:smartgallery/models/user.dart';
import 'package:smartgallery/services/database_service.dart';

/// Οθόνη προφίλ χρήστη
///
/// Περιέχει: Στοιχεία χρήστη, προτιμήσεις κατηγοριών, αριθμό φωτογραφιών,
/// αγαπημένων, ρυθμίσεις (αυτόματη κατηγοριοποίηση κλπ).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  int _photoCount = 0;
  final _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Φόρτωση προφίλ χρήστη και στατιστικών από τη βάση
  Future<void> _loadProfile() async {
    try {
      final user = await _databaseService.getOrCreateDefaultUser();
      final photos = await _databaseService.getPhotos();
      if (mounted) {
        setState(() {
          _user = user;
          _photoCount = photos.length;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Σφάλμα: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white70)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Προφίλ'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Κεφαλίδα προφίλ με avatar
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
          // Στατιστικά χρήστη
          _buildStatistics(),
          const SizedBox(height: 24),
          const Text(
            'Προτιμήσεις κατηγοριών',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          _buildCategoryPreferences(),
          const SizedBox(height: 24),
          const Text(
            'Ρυθμίσεις',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          _buildSettings(),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
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
                      '$_photoCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text('Φωτογραφίες', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_user!.favoritePhotoIds.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text('Αγαπημένα', style: TextStyle(color: Colors.white70)),
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
    final prefs = _user!.categoryPreferences;
    if (prefs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Δεν υπάρχουν προτιμήσεις', style: TextStyle(color: Colors.white70)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: prefs.entries.map((entry) {
          final label = entry.key == 'portrait' ? 'Προσωπογραφίες' : entry.key == 'landscape' ? 'Τοπία' : entry.key == 'group' ? 'Ομαδικές' : entry.key;
          return SwitchListTile(
            title: Text(label, style: const TextStyle(color: Colors.white)),
            value: entry.value,
            activeTrackColor: Colors.white54,
            inactiveTrackColor: Colors.white24,
            thumbColor: WidgetStateProperty.all(Colors.black),
            onChanged: (value) {
              setState(() {
                _user = User(
                  id: _user!.id,
                  username: _user!.username,
                  email: _user!.email,
                  profileImageUrl: _user!.profileImageUrl,
                  favoritePhotoIds: _user!.favoritePhotoIds,
                  recentPhotoIds: _user!.recentPhotoIds,
                  categoryPreferences: {..._user!.categoryPreferences, entry.key: value},
                  autoCategorizeEnabled: _user!.autoCategorizeEnabled,
                );
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Αυτόματη κατηγοριοποίηση', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Κατηγοριοποίηση νέων φωτογραφιών με ML', style: TextStyle(color: Colors.white70)),
            value: _user!.autoCategorizeEnabled,
            activeTrackColor: Colors.white54,
            inactiveTrackColor: Colors.white24,
            thumbColor: WidgetStateProperty.all(Colors.black),
            onChanged: (value) async {
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
              try {
                await _databaseService.updateUser(_user!);
              } catch (_) {}
            },
          ),
        ],
      ),
    );
  }
}

