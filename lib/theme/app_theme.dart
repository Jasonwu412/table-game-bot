import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get cuteTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.pinkAccent,
        brightness: Brightness.light,
        surface: const Color(0xFFFFF0F5), // Lavender Blush
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF0F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Colors.pinkAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'Muli', // Using a default font for now, can be customized later
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Muli',
        ),
      ),
    );
  }
}
