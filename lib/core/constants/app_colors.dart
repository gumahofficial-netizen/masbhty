import 'package:flutter/material.dart';

class AppColors {
  // Primary Islamic Emerald Palette
  static const Color emeraldPrimary = Color(0xFF0D5C3A);
  static const Color emeraldLight = Color(0xFF1B8A5A);
  static const Color emeraldDark = Color(0xFF073823);
  static const Color emeraldBackgroundDark = Color(0xFF051D14);

  // Luxury Gold Accents
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3C649);
  static const Color goldDark = Color(0xFFA08020);

  // Surface & Neutral Colors
  static const Color surfaceLight = Color(0xFFF8FAF8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0C2B1E);
  static const Color cardDark = Color(0xFF123B2A);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF11221B);
  static const Color textSecondaryLight = Color(0xFF52685E);
  static const Color textPrimaryDark = Color(0xFFF0F7F4);
  static const Color textSecondaryDark = Color(0xFFA0BBAE);

  // Counter Skin Color Palettes
  static const Color woodBead = Color(0xFF8B5A2B);
  static const Color amberBead = Color(0xFFFFBF00);
  static const Color crystalBead = Color(0xFF88D4E4);
  static const Color silverBead = Color(0xFFC0C0C0);
  static const Color ringBody = Color(0xFF1A1A1A);

  // Gradients
  static const LinearGradient emeraldGoldGradient = LinearGradient(
    colors: [emeraldPrimary, emeraldDark],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, goldPrimary, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [cardDark, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
