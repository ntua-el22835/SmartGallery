import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:smartgallery/screens/main_navigation.dart';
import 'package:smartgallery/theme/app_theme.dart';

/// Main entry point για την εφαρμογή Smart Gallery
/// 
/// Smart Gallery: A trip down the memory lane
/// Κατηγορία: Photography
/// 
/// Η εφαρμογή απλοποιεί την ταξινόμηση και αναζήτηση φωτογραφιών
/// χρησιμοποιώντας ML για κατηγοριοποίηση και face recognition.
final log = Logger('SmartGalleryLogger');

void main() {
  // Avoid errors caused by flutter upgrade
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging (όπως στο todotoday example)
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
        '${record.loggerName} --> ${record.level.name}: ${record.time}: ${record.message}');
  });

  // TODO: Initialize database service
  // final databaseService = DatabaseService();
  // databaseService.initializeDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Gallery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}
