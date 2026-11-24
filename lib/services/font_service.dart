import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// FontService ensures all required Arabic, Somali, and Latin typography
/// assets are loaded and initialized before displaying the first frame of the app.
///
/// This eliminates any temporary font substitution, FOUT, or square-box (tofu: □)
/// artifacts during app startup.
class FontService {
  static bool _isReady = false;
  static bool get isReady => _isReady;

  /// Preload and register all essential fonts used across the application.
  static Future<void> initialize() async {
    if (_isReady) return;

    try {
      // 1. Explicitly register local font files with Flutter's FontLoader
      // for the standard font family names defined in pubspec.yaml.
      final fontLoaders = <FontLoader>[
        FontLoader('Amiri')
          ..addFont(rootBundle.load('assets/fonts/Amiri-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Amiri-Bold.ttf')),
        FontLoader('PlusJakartaSans')
          ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Medium.ttf'))
          ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-SemiBold.ttf'))
          ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf')),
        FontLoader('NotoSerif')
          ..addFont(rootBundle.load('assets/fonts/NotoSerif-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/NotoSerif-SemiBold.ttf'))
          ..addFont(rootBundle.load('assets/fonts/NotoSerif-Bold.ttf')),
      ];

      await Future.wait(fontLoaders.map((loader) => loader.load()));
    } catch (e) {
      debugPrint('FontService local asset registration: $e');
    }

    try {
      // 2. Prime GoogleFonts runtime cache so that GoogleFonts.amiri(),
      // GoogleFonts.plusJakartaSans(), and GoogleFonts.notoSerif() resolve
      // immediately without any network roundtrip or asynchronous swap.
      await GoogleFonts.pendingFonts([
        // Arabic primary & bold (HomeScreen header, cards, list items)
        GoogleFonts.amiri(fontWeight: FontWeight.w400),
        GoogleFonts.amiri(fontWeight: FontWeight.w600),
        GoogleFonts.amiri(fontWeight: FontWeight.w700),

        // Latin Sans (Somali & English UI text)
        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w400),
        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),

        // Serif (Titles & Lecture Headings)
        GoogleFonts.notoSerif(fontWeight: FontWeight.w400),
        GoogleFonts.notoSerif(fontWeight: FontWeight.w600),
        GoogleFonts.notoSerif(fontWeight: FontWeight.w700),
      ]);
    } catch (e) {
      debugPrint('FontService GoogleFonts pending fonts: $e');
    }

    _isReady = true;
  }
}
