import 'package:flutter/material.dart';

class AppColors {
  static const navy950 = Color(0xFF071018);
  static const navy900 = Color(0xFF0B141D);
  static const navy800 = Color(0xFF101D28);
  static const navy700 = Color(0xFF172632);
  static const orange = Color(0xFFFF7A1A);
  static const orangeSoft = Color(0xFFFFA14A);
  static const white = Color(0xFFF7F8FA);
  static const muted = Color(0xFF98A6B5);
  static const border = Color(0xFF243544);
  static const red = Color(0xFFFF4D4D);
  static const green = Color(0xFF34D399);
  static const amber = Color(0xFFFBBF24);
}

class AppTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.dark,
      surface: AppColors.navy900,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.navy950,
      colorScheme: scheme.copyWith(
        primary: AppColors.orange,
        secondary: AppColors.orangeSoft,
        surface: AppColors.navy900,
        error: AppColors.red,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy950,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.navy900,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navy800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
        ),
      ),
    );
  }
}
