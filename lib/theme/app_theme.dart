import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundDark = Color(0xFF0F0F13);
  static const Color surfaceDark = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF);
  static const Color accentColor = Color(0xFF1DB954); // Spotify-like accent

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accentColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        surface: backgroundDark,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto', // Ideally San Francisco or similar, defaulting to standard
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
