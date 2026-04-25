import 'package:flutter/material.dart';

class AppColors {
  static const Color primary50 = Color(0xFFECFDF5);
  static const Color primary100 = Color(0xFFD1FAE5);
  static const Color primary200 = Color(0xFFA7F3D0);
  static const Color primary300 = Color(0xFF6EE7B7);
  static const Color primary400 = Color(0xFF34D399);
  static const Color primary500 = Color(0xFF10B981);
  static const Color primary600 = Color(0xFF059669);
  static const Color primary700 = Color(0xFF047857);
  static const Color primary800 = Color(0xFF065F46);
  static const Color primary900 = Color(0xFF064E3B);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textInverse = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.primary400,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textInverse,
        onSecondary: AppColors.textInverse,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.25,
        ), // 40/32
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.33,
        ), // 32/24
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ), // 24/16
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.33,
        ), // 16/12
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.textInverse,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 1, // Approximation of shadow token
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }
}
