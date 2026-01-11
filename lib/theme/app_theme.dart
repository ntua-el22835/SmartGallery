import 'package:flutter/material.dart';

/// Theme configuration για Smart Gallery
/// 
/// Βασισμένο στα Figma designs:
/// - Dark theme (black background)
/// - Neumorphic UI elements
/// - White text/icons
class AppTheme {
  // Colors από Figma
  static const Color backgroundColor = Color(0xFF1A1A1A); // Dark gray/black
  static const Color surfaceColor = Color(0xFF2A2A2A); // Slightly lighter for cards
  static const Color primaryColor = Color(0xFF0175C2); // Blue accent
  static const Color textColor = Colors.white;
  static const Color iconColor = Colors.white;
  
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
        displayLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        displayMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        displaySmall: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        headlineLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        headlineMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        headlineSmall: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        titleLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontSize: 20),
        titleMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro', fontSize: 15),
        bodyLarge: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        bodyMedium: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
        bodySmall: TextStyle(color: Colors.white70, fontFamily: 'SF Pro'),
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

