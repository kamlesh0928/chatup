import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // Define the primary brand and accent color
  static const primaryColor = Color(0xFF272626);
  static const appBackground = Color(0xFFF0F2F5); // Overall Scaffold background
  static const cardSurfaceColor = Colors.white; // For AppBar, cards, list items
  static const primaryTextColor = Color(0xFF1E272E); // Dark Grey for main text
  static const secondaryTextColor = Color(0xFF8E8E93); // Medium Grey for secondary text
  static const errorColor = Color(0xFFEA5455); // Red for Logout/Error

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
  );
}