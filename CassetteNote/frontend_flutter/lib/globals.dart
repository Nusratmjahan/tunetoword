import 'package:flutter/material.dart';

// Color Palette - Nostalgic Design
class AppColors {
  static const Color cream = Color(0xFFFDF6E3);
  static const Color warmWhite = Color(0xFFFEFCF7);
  static const Color brownDark = Color(0xFF3D2B1F);
  static const Color brownMid = Color(0xFF6B4226);
  static const Color sepia = Color(0xFFA0826D);
  static const Color amberDeep = Color(0xFFC8860A);
  static const Color amberLight = Color(0xFFF5C842);
}

// Text Styles
class AppTextStyles {
  static TextStyle heading1 = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.brownDark,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.brownDark,
  );

  static TextStyle body = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: AppColors.brownMid,
  );

  static TextStyle handwritten = const TextStyle(
    fontFamily: 'Caveat',
    fontSize: 20,
    color: AppColors.brownDark,
  );

  static TextStyle button = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.cream,
  );
}

// Cassette Color Themes
class CassetteThemes {
  static Map<String, Color> themes = {
    'amber-deep': AppColors.amberDeep,
    'brown-mid': AppColors.brownMid,
    'sepia': AppColors.sepia,
    'amber-light': AppColors.amberLight,
  };
}

// Emotion Tags
class EmotionTags {
  static const List<String> tags = [
    'Nostalgia',
    'Friendship',
    'Apology',
    'Love',
    'Missing Someone',
    'Celebration',
    'Gratitude',
  ];
}
