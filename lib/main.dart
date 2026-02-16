import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:smartgallery/screens/main_navigation.dart';
import 'package:smartgallery/services/database_service.dart';
import 'package:smartgallery/theme/app_theme.dart';

/// Κύριο σημείο εισόδου για την εφαρμογή Smart Gallery
/// 
/// Smart Gallery: Ένα ταξίδι στη μνήμη
/// Κατηγορία: Φωτογραφία
/// 
/// Η εφαρμογή απλοποιεί την ταξινόμηση και αναζήτηση φωτογραφιών
/// χρησιμοποιώντας ML για κατηγοριοποίηση και face recognition.
final log = Logger('SmartGalleryLogger'); // Λογαριθμός για την εφαρμογή

void main() async {
  // Απαραίτητο για async initialization πριν το runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Ρύθμιση logging για debugging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '${record.loggerName} --> ${record.level.name}: ${record.time}: ${record.message}');
  });

  // Αρχικοποίηση της βάσης δεδομένων
  final databaseService = DatabaseService(); 
  await databaseService.initializeDatabase();

  runApp(const MyApp()); // Εκκίνηση της εφαρμογής
}

/// Κύριο widget της εφαρμογής
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
