import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primaryGreen = Color(0xFF1B5E3F);
  const secondaryGreen = Color(0xFF2D8659);
  const lightGreen = Color(0xFF4CAF7F);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      secondary: secondaryGreen,
      tertiary: lightGreen,
      brightness: Brightness.light,
    ),
    primaryColor: primaryGreen,
    primaryColorDark: secondaryGreen,
    scaffoldBackgroundColor: Color(0xFFFAFCFB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryGreen,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryGreen),
      titleTextStyle: TextStyle(
        color: primaryGreen,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: Color(0xFFD0E8E0), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF8FCFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0E8E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0E8E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      floatingLabelStyle: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
      labelStyle: TextStyle(color: Colors.grey[700]),
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIconColor: primaryGreen,
      suffixIconColor: Colors.grey[600],
    ),
    iconTheme: const IconThemeData(color: primaryGreen, size: 24),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryGreen),
      displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryGreen),
      displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryGreen),
      headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
      headlineSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryGreen),
      titleLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
      titleMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
      titleSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
      bodyLarge: const TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: const TextStyle(fontSize: 14, color: Colors.black87),
      bodySmall: const TextStyle(fontSize: 12, color: Colors.grey),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black87,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
