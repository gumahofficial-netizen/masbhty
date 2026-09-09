import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masbhty/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.emeraldPrimary,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.emeraldPrimary,
        secondary: AppColors.goldPrimary,
        surface: AppColors.cardLight,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.emeraldPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.emeraldLight,
      scaffoldBackgroundColor: AppColors.emeraldBackgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emeraldLight,
        secondary: AppColors.goldPrimary,
        surface: AppColors.surfaceDark,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.goldLight,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
