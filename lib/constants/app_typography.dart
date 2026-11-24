import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Common Arabic fallback families for robust cross-platform rendering
  static const List<String> arabicFontFallbacks = [
    'Amiri',
    'Noto Naskh Arabic',
    'Noto Sans Arabic',
    'Traditional Arabic',
    'Geeza Pro',
    'Arial',
    'sans-serif',
  ];

  static const List<String> sansFontFallbacks = [
    'PlusJakartaSans',
    'Amiri',
    'Noto Sans Arabic',
    'Noto Sans',
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  static const List<String> serifFontFallbacks = [
    'NotoSerif',
    'Amiri',
    'Noto Naskh Arabic',
    'Noto Sans Arabic',
    'Noto Serif',
    'Georgia',
    'serif',
  ];

  // Arabic Typography (Amiri with robust Arabic fallbacks)
  static TextStyle arabic({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.onSurface,
    double lineHeight = 1.7,
  }) {
    return TextStyle(
      fontFamily: 'Amiri',
      fontFamilyFallback: arabicFontFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight,
    );
  }

  // Latin Sans Typography (Plus Jakarta Sans / Noto Sans)
  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.onSurface,
    double? letterSpacing,
    double? lineHeight,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontFamilyFallback: sansFontFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: lineHeight,
      fontStyle: fontStyle,
    );
  }

  // Latin Serif Typography (Noto Serif)
  static TextStyle serif({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.onSurface,
    double? lineHeight,
  }) {
    return TextStyle(
      fontFamily: 'NotoSerif',
      fontFamilyFallback: serifFontFallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight,
    );
  }

  // Predefined Styles from Design System
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'NotoSerif',
    fontFamilyFallback: serifFontFallbacks,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
    height: 1.25,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: 'NotoSerif',
    fontFamilyFallback: serifFontFallbacks,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.3,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: 'NotoSerif',
    fontFamilyFallback: serifFontFallbacks,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.35,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'NotoSerif',
    fontFamilyFallback: serifFontFallbacks,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
    height: 1.45,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
    height: 1.4,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontFamilyFallback: sansFontFallbacks,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.2,
  );
}
