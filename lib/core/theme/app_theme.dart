import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color _lightPrimary = Color(0xFF37A4F4); // آبی روشن
  static const Color _lightBackground = Color.fromARGB(
    255,
    249,
    254,
    255,
  ); // آبی پاستلی روشن
  static const Color _lightSurface = Colors.white;

  static const Color _darkPrimary = Color(0xFF206DA5); // آبی تیره
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(
    0xFF206DA5,
  ); // می‌تونیم روی کارت‌ها یا AppBar استفاده کنیم

  static final TextTheme _textTheme = GoogleFonts.interTextTheme();

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'appfont',
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        surface: _lightSurface,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
      cardColor: _lightSurface,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'appfont',

      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        surface: _darkSurface,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _textTheme.apply(
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
      ),
      cardColor: _darkSurface,
    );
  }
}
