import 'package:flutter/material.dart';

/// Θέμα εφαρμογής Smart Gallery
///
/// Περιέχει χρώματα, typography και styles από το Figma design.
/// Χρησιμοποιείται για dark theme με μαύρο background και λευκά στοιχεία.
class AppTheme {
  // Χρώματα από Figma FinalUI Design
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFFFFFFFF);
  static const Color glass3 = Color(0xFFFFFFFF);
  static const Color glass2 = Color(0xFFFFFFFF);
  static const Color glass1 = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFF000000); // Μαύρο background
  static const Color surfaceColor = Color(0xFF1A1A1A); // Σκούρο surface
  static const Color photoPlaceholderColor = Color(0xFFD9D9D9); // Γκρι placeholder για φωτογραφίες
  static const Color primaryColor = Color(0xFFFFFFFF); // Λευκό για κύριες ενέργειες
  static const Color textColor = Colors.white;
  static const Color iconColor = Colors.white;
  static const Color glassColor = Color(0x0DFFFFFF); // Glass effect
  static const double globalHeight = 24.0;

  // Παράδειγμα glass effect ως BoxDecoration
  static BoxDecoration glassEffect1 = BoxDecoration(
    color: glass1.withOpacity(0.2),
    backgroundBlendMode: BlendMode.overlay,
    boxShadow: [
      BoxShadow(
        color: Color(0x66FFFFFF),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x33000000),
        offset: Offset(0, -2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
  );

  /// Dark theme για την εφαρμογή
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontSize: 15, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontSize: 14),
        bodySmall: TextStyle(color: Colors.white70, fontFamily: 'SF Pro', fontSize: 12),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Βοηθητική μέθοδος για neumorphic shadow effect
  static List<BoxShadow> getNeumorphicShadow(bool isPressed) {
    // Αν το κουμπί είναι πατημένο
    if (isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];
    } else {
      // Αν το κουμπί δεν είναι πατημένο
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];
    }
  }
}

