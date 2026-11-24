import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Quran Color Theme & Visual Identity Tokens.
///
/// Supports both dynamic theme switching (Global Light/Dark Mode) and
/// static constants for backwards compatibility.
class QuranTheme {
  // --- Dynamic Color Resolvers based on isDark ---
  static Color bg(bool isDark) => AppTheme.bg(isDark);
  static Color cardBg(bool isDark) => AppTheme.card(isDark);
  static Color cardMuted(bool isDark) => isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerLow;
  static Color surfaceContainer(bool isDark) => isDark ? AppTheme.darkSecondary : AppColors.surfaceContainer;
  static Color text(bool isDark) => AppTheme.text(isDark);
  static Color muted(bool isDark) => AppTheme.textSub(isDark);
  static Color subtle(bool isDark) => isDark ? const Color(0xFF8E8E9F) : AppColors.outline;
  static Color border(bool isDark) => AppTheme.border(isDark);
  static Color div(bool isDark) => AppTheme.divider(isDark);
  static Color badgeBg(bool isDark) => AppTheme.badgeBg(isDark);
  static Color badgeTxt(bool isDark) => AppTheme.badgeText(isDark);
  static Color ic(bool isDark) => isDark ? const Color(0xFFBDBDBD) : AppColors.onSurfaceVariant;
  static Color icActive(bool isDark) => isDark ? AppTheme.primaryLight : AppColors.primary;
  static Color arabicTitle(bool isDark) => isDark ? const Color(0xFFC4B5FD) : AppColors.primary;

  // --- Static Defaults for Light Mode ---
  static const Color background = AppColors.background; // 0xFFFDF7FF
  static const Color cardBackground = Colors.white;
  static const Color cardBackgroundMuted = AppColors.surfaceContainerLow;
  static const Color surfaceContainerLight = AppColors.surfaceContainer;
  static const Color surfaceContainerHigh = AppColors.surfaceContainerHigh;

  // --- Primary Theme Palette (Purple / Blue) ---
  static const Color primary = AppColors.primary; // 0xFF623EDC
  static const Color primaryDark = AppColors.primaryDark; // 0xFF4A1BC4
  static const Color primaryContainer = AppColors.primaryContainer; // 0xFF7B5BF6
  static const Color primaryFixed = AppColors.primaryFixed; // 0xFFE6DEFF
  static const Color primaryFixedDim = AppColors.primaryFixedDim; // 0xFFCBBEFF

  // --- Secondary Accents ---
  static const Color secondary = AppColors.secondary;
  static const Color secondaryContainer = AppColors.secondaryContainer;
  static const Color onSecondaryContainer = AppColors.onSecondaryContainer;

  // --- Text & Typography Colors (Light) ---
  static const Color textDark = AppColors.onSurface;
  static const Color textMuted = AppColors.onSurfaceVariant;
  static const Color textSubtle = AppColors.outline;

  // --- Quran Arabic Calligraphy Title Accent ---
  static const Color arabicCalligraphy = AppColors.primary;

  // --- Borders, Dividers & Outlines ---
  static const Color cardBorder = Color(0x40CAC4D7);
  static const Color activeBorder = AppColors.primary;
  static const Color divider = Color(0x35CAC4D7);

  // --- Badges & Number Pills ---
  static const Color badgeBackground = AppColors.primaryFixed;
  static const Color badgeText = AppColors.primary;
  static const Color badgeBorder = Color(0x33623EDC);

  // --- Actions & Navigation Icons ---
  static const Color iconColor = AppColors.onSurfaceVariant;
  static const Color iconActive = AppColors.primary;
  static const Color iconDisabled = Color(0xFFCAC4D7);

  // --- Layout Decorations ---
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static final BorderRadius cardRadius = BorderRadius.circular(16);
  static final BorderRadius pillRadius = BorderRadius.circular(99);
  static final BorderRadius buttonRadius = BorderRadius.circular(12);
}

/// Reading Palette for Quran Reading Screen (Page 2).
class QuranReaderPalette {
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color arabicText;
  final Color somaliText;
  final Color accent;
  final Color badgeBackground;
  final Color badgeText;
  final Color badgeBorder;
  final Color divider;
  final Color iconColor;
  final Color actionIconColor;

  const QuranReaderPalette({
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.arabicText,
    required this.somaliText,
    required this.accent,
    required this.badgeBackground,
    required this.badgeText,
    required this.badgeBorder,
    required this.divider,
    required this.iconColor,
    required this.actionIconColor,
  });

  /// Unified Dark Mode Palette for Quran Reading Screen
  static const QuranReaderPalette dark = QuranReaderPalette(
    background: AppTheme.darkBackground, // #121212
    surface: AppTheme.darkSecondary, // #252538
    cardBackground: AppTheme.darkCard, // #1E1E2E
    arabicText: AppTheme.darkTextPrimary, // #FFFFFF
    somaliText: AppTheme.darkTextSecondary, // #BDBDBD
    accent: Color(0xFF9D84F7),
    badgeBackground: AppTheme.darkBadgeBg,
    badgeText: AppTheme.darkBadgeText,
    badgeBorder: Color(0xFF3F3560),
    divider: AppTheme.darkDivider,
    iconColor: AppTheme.primaryLight,
    actionIconColor: Color(0xFFBDBDBD),
  );

  /// Unified Light Mode Palette for Quran Reading Screen
  static const QuranReaderPalette light = QuranReaderPalette(
    background: QuranTheme.background,
    surface: QuranTheme.cardBackgroundMuted,
    cardBackground: QuranTheme.cardBackground,
    arabicText: QuranTheme.textDark,
    somaliText: QuranTheme.textMuted,
    accent: QuranTheme.primary,
    badgeBackground: QuranTheme.badgeBackground,
    badgeText: QuranTheme.badgeText,
    badgeBorder: QuranTheme.badgeBorder,
    divider: QuranTheme.divider,
    iconColor: QuranTheme.iconActive,
    actionIconColor: QuranTheme.iconColor,
  );

  /// Helper returning palette according to global isDark flag
  static QuranReaderPalette forMode(bool isDark) => isDark ? dark : light;

  /// Backwards compatibility aliases
  static const QuranReaderPalette serene = light;
  static const QuranReaderPalette night = dark;
}
