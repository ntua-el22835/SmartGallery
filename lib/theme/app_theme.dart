import 'package:flutter/material.dart';

/// Theme configuration για Smart Gallery
/// 
/// Βασισμένο στα Figma designs:
/// - Dark theme (black background)
/// - Neumorphic UI elements
/// - White text/icons
class AppTheme {
  // Colors από Figma FinalUI Design
  static const Color backgroundColor = Color(0xFF000000); // Pure black
  static const Color surfaceColor = Color(0xFF1A1A1A); // Dark surface
  static const Color photoPlaceholderColor = Color(0xFFD9D9D9); // Light gray for photos
  static const Color primaryColor = Color(0xFFFFFFFF); // White for primary actions
  static const Color textColor = Colors.white;
  static const Color iconColor = Colors.white;
  static const Color glassColor = Color(0x0DFFFFFF); // Glass effect rgba(255,255,255,0.02)
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
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
  
  /// Helper για neumorphic shadow effect
  static List<BoxShadow> getNeumorphicShadow(bool isPressed) {
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

