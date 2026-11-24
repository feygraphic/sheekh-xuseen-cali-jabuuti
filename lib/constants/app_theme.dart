import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Centralized Global Theme Manager for Sheikh Xuseen Cali Jabuuti Application.
///
/// Ensures 100% unified theme state across all screens, cards, dialogs,
/// bottom sheets, audio players, Quran, Adhkar, and settings.
class AppTheme {
  // Brand Primary Accents (Preserved Signature Purple Identity)
  static const Color primary = AppColors.primary; // 0xFF623EDC
  static const Color primaryDark = AppColors.primaryDark; // 0xFF4A1BC4
  static const Color primaryContainer = AppColors.primaryContainer; // 0xFF7B5BF6
  static const Color primaryLight = Color(0xFF9D84FF); // 0xFF9D84FF (Readable in dark)

  // 1. Consistent Dark Mode Colors (as strictly required)
  static const Color darkBackground = Color(0xFF121212); // Dark charcoal (#121212)
  static const Color darkCard = Color(0xFF1E1E2E); // (#1E1E2E)
  static const Color darkSecondary = Color(0xFF252538); // (#252538)
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // White (#FFFFFF)
  static const Color darkTextSecondary = Color(0xFFBDBDBD); // Light grey (#BDBDBD)
  static const Color darkBorder = Color(0xFF2E2E3E); // Dark grey border
  static const Color darkDivider = Color(0xFF2E2E3E); // Dark grey divider
  static const Color darkBadgeBg = Color(0xFF2D2545);
  static const Color darkBadgeText = Color(0xFFB49EFF);
  static const Color darkInputFill = Color(0xFF1A1A28);
  static const Color darkIcon = Color(0xFFBDBDBD);

  // 2. Consistent Light Mode Colors (preserving existing Light Mode design)
  static const Color lightBackground = Color(0xFFFDF7FF);
  static const Color lightCard = Colors.white;
  static const Color lightSecondary = Color(0xFFF7F1FF); // surfaceContainerLow
  static const Color lightTextPrimary = Color(0xFF1C1A24); // onSurface
  static const Color lightTextSecondary = Color(0xFF484555); // onSurfaceVariant
  static const Color lightBorder = Color(0x35CAC4D7);
  static const Color lightDivider = Color(0x35CAC4D7);
  static const Color lightBadgeBg = Color(0xFFE6DEFF); // primaryFixed
  static const Color lightBadgeText = Color(0xFF623EDC);
  static const Color lightInputFill = Color(0xFFF7F1FF);
  static const Color lightIcon = Color(0xFF484555);

  // 3. Central Dynamic Accessors based on boolean `isDark`
  static Color bg(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color surface(bool isDark) => isDark ? darkSecondary : lightSecondary;
  static Color text(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSub(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color divider(bool isDark) => isDark ? darkDivider : lightDivider;
  static Color badgeBg(bool isDark) => isDark ? darkBadgeBg : lightBadgeBg;
  static Color badgeText(bool isDark) => isDark ? darkBadgeText : lightBadgeText;
  static Color inputFill(bool isDark) => isDark ? darkInputFill : lightInputFill;
  static Color icon(bool isDark) => isDark ? darkIcon : lightIcon;
  static Color accent(bool isDark) => isDark ? primaryLight : primary;

  // 4. Convenience helper from BuildContext
  static bool isDarkMode(BuildContext context) {
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: true);
      return settings.isDarkMode;
    } catch (_) {
      return Theme.of(context).brightness == Brightness.dark;
    }
  }

  // 5. Material ThemeData definitions
  static ThemeData get lightThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'PlusJakartaSans',
      fontFamilyFallback: AppTypography.arabicFontFallbacks,
      primaryColor: primary,
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCard,
      dividerColor: lightDivider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: lightBackground,
        onSurface: lightTextPrimary,
        onSurfaceVariant: lightTextSecondary,
        brightness: Brightness.light,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: lightCard,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightCard,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCard,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        titleLarge: AppTypography.titleLg,
        titleMedium: AppTypography.titleMd,
        headlineSmall: AppTypography.headlineSm,
        headlineMedium: AppTypography.headlineMd,
        headlineLarge: AppTypography.headlineLg,
      ),
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'PlusJakartaSans',
      fontFamilyFallback: AppTypography.arabicFontFallbacks,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      dividerColor: darkDivider,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        surface: darkCard,
        surfaceContainer: darkSecondary,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        titleLarge: AppTypography.titleLg,
        titleMedium: AppTypography.titleMd,
        headlineSmall: AppTypography.headlineSm,
        headlineMedium: AppTypography.headlineMd,
        headlineLarge: AppTypography.headlineLg,
      ),
    );
  }
}
