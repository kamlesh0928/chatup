import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF3B9FA7);
  static const appBackgroundStart = Color(0xFFECF4F4);
  static const appBackgroundEnd = Color(0xFFCEE6E8);
  static const cardSurfaceColor = Colors.white;
  static const primaryTextColor = Color(0xFF1E272E);
  static const secondaryTextColor = Color(0xFF8E8E93);
  static const errorColor = Color(0xFFEA5455);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryTextColor,
      onSecondary: primaryTextColor,
      surface: cardSurfaceColor,
      onSurface: primaryTextColor,
      error: errorColor,
      onError: Colors.white,
      tertiary: primaryColor,
      onTertiary: Colors.white,
      outline: Color(0xFFE0E0E0),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: cardSurfaceColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: primaryTextColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: primaryTextColor),
      actionsIconTheme: IconThemeData(color: primaryTextColor),
    ),

    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[600]),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[600]),
      labelMedium: TextStyle(fontSize: 12, color: Colors.grey),
    ),

    iconTheme: const IconThemeData(color: Colors.black87, size: 24),

    cardTheme: CardThemeData(
      color: primaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryColor.withValues(alpha: 0.1),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: primaryColor),
      ),
      hintStyle: TextStyle(color: Colors.grey[600]),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
