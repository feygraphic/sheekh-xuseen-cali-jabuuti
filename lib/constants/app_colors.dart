import 'package:flutter/material.dart';
export 'quran_theme.dart';
export 'app_theme.dart';

class AppColors {
  // Serene Illumination (Primary Theme)
  static const Color primary = Color(0xFF623EDC);
  static const Color primaryDark = Color(0xFF4A1BC4);
  static const Color primaryContainer = Color(0xFF7B5BF6);
  static const Color primaryFixed = Color(0xFFE6DEFF);
  static const Color primaryFixedDim = Color(0xFFCBBEFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryFixed = Color(0xFF1D0061);

  static const Color secondary = Color(0xFF615499);
  static const Color secondaryContainer = Color(0xFFC3B4FF);
  static const Color secondaryFixed = Color(0xFFE6DEFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryFixed = Color(0xFF1D0C52);
  static const Color onSecondaryContainer = Color(0xFF4E4184);

  static const Color tertiary = Color(0xFF812803);
  static const Color tertiaryContainer = Color(0xFFA13F1A);
  static const Color tertiaryFixed = Color(0xFFFFDBD0);
  static const Color tertiaryFixedDim = Color(0xFFFFB59D);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryFixed = Color(0xFF390C00);
  static const Color onTertiaryContainer = Color(0xFFFFCDBD);

  static const Color background = Color(0xFFFDF7FF);
  static const Color surface = Color(0xFFFDF7FF);
  static const Color surfaceBright = Color(0xFFFDF8FF);
  static const Color surfaceDim = Color(0xFFDDD8E5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F1FF);
  static const Color surfaceContainer = Color(0xFFF1EBFF);
  static const Color surfaceContainerHigh = Color(0xFFEBE5F9);
  static const Color surfaceContainerHighest = Color(0xFFE6E0EE);

  static const Color onSurface = Color(0xFF1C1A24);
  static const Color onSurfaceVariant = Color(0xFF484555);
  static const Color outline = Color(0xFF797586);
  static const Color outlineVariant = Color(0xFFCAC4D7);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Noor Media System (Sky Blue Accent / Theme)
  static const Color noorPrimary = Color(0xFF006096);
  static const Color noorPrimaryContainer = Color(0xFF007ABC);
  static const Color noorPrimaryFixed = Color(0xFFCEE5FF);
  static const Color noorSecondary = Color(0xFF4B6078);
  static const Color noorSecondaryContainer = Color(0xFFCBE2FE);
  static const Color noorTertiary = Color(0xFF8D4B00);
  static const Color noorBackground = Color(0xFFF7F9FB);
  static const Color noorSurface = Color(0xFFF7F9FB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A1BC4),
      Color(0xFF623EDC),
      Color(0xFF7B5BF6),
    ],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A1BC4),
      Color(0xFF623EDC),
      Color(0xFF615499),
    ],
  );

  static const LinearGradient noorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF006096),
      Color(0xFF007ABC),
      Color(0xFF014F7C),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD97706),
      Color(0xFFB45309),
    ],
  );
}
