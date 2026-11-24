import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/constants/app_typography.dart';
import 'package:sheekh_xuseen_cali_jabuuti/constants/app_theme.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/font_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/home_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/app_splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock platform channels for audioplayers and share_plus
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (MethodCall methodCall) async => null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (MethodCall methodCall) async => 1,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/share'),
    (MethodCall methodCall) async => null,
  );

  group('Font Preloading & Typography Initialization Tests', () {
    test('FontService initializes and reports isReady = true', () async {
      await FontService.initialize();
      expect(FontService.isReady, isTrue);
    });

    test('AppTypography.arabic() includes Arabic font families and comprehensive fallbacks', () {
      final style = AppTypography.arabic();
      expect(style.fontFamilyFallback, isNotNull);
      expect(style.fontFamilyFallback, containsAll([
        'Amiri',
        'Noto Naskh Arabic',
        'Noto Sans Arabic',
        'Arial',
      ]));
    });

    test('AppTypography.sans() and serif() include primary families and fallbacks', () {
      final sansStyle = AppTypography.sans();
      expect(sansStyle.fontFamilyFallback, isNotNull);
      expect(sansStyle.fontFamilyFallback, contains('PlusJakartaSans'));

      final serifStyle = AppTypography.serif();
      expect(serifStyle.fontFamilyFallback, isNotNull);
      expect(serifStyle.fontFamilyFallback, contains('NotoSerif'));
    });

    test('AppTheme includes Arabic fallback fonts in light and dark themes', () {
      final lightTheme = AppTheme.lightThemeData;
      expect(lightTheme.textTheme.bodyLarge?.fontFamilyFallback, containsAll(['Amiri', 'Noto Sans Arabic']));

      final darkTheme = AppTheme.darkThemeData;
      expect(darkTheme.textTheme.bodyLarge?.fontFamilyFallback, containsAll(['Amiri', 'Noto Sans Arabic']));
    });
  });

  group('HomeScreen Initial Frame Rendering & Text Verification', () {
    late StorageService storage;
    late SettingsProvider settings;
    late AudioPlayerProvider audio;
    late FavoritesProvider fav;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
      settings = SettingsProvider(storage);
      audio = AudioPlayerProvider(storage);
      fav = FavoritesProvider(storage);
      await FontService.initialize();
    });

    testWidgets('First frame of HomeScreen renders all Arabic and Somali text without missing glyphs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioPlayerProvider>.value(value: audio),
            ChangeNotifierProvider<FavoritesProvider>.value(value: fav),
            ChangeNotifierProvider<SettingsProvider>.value(value: settings),
            ChangeNotifierProvider(create: (_) => AdhkarProvider(storage)),
            ChangeNotifierProvider(create: (_) => TasbeehProvider(storage)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightThemeData,
            darkTheme: AppTheme.darkThemeData,
            home: HomeScreen(
              onTabChange: (_) {},
              onOpenDrawer: () {},
            ),
          ),
        ),
      );

      // Verify the very first frame renders the Arabic greeting
      expect(find.text('السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكَاتُهُ'), findsOneWidget);

      // Verify Arabic lecture titles render correctly
      expect(find.text('محاضرات الشيخ حسين قسم الاول'), findsOneWidget);
      expect(find.text('محاضرات الشيخ حسين قسم الثاني'), findsOneWidget);

      // Verify Somali titles render correctly
      expect(find.text('Hoyga'), findsOneWidget);
      expect(find.text('KUSOO DHOWOW'), findsOneWidget);
      expect(find.text('Muxaadarooyinka Qaybta 1aad'), findsOneWidget);
      expect(find.text('Muxaadarooyinka Qaybta 2aad'), findsOneWidget);

      // Ensure no square box/tofu placeholder character is present in any text
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final textWidget in textWidgets) {
        final data = textWidget.data ?? '';
        expect(data.contains('□'), isFalse,
            reason: 'Text widget must not contain tofu placeholder: "$data"');
      }
    });

    testWidgets('AppSplashScreen renders with brand emblem and title while loading', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: settings),
          ],
          child: MaterialApp(
            theme: AppTheme.lightThemeData,
            home: const AppSplashScreen(),
          ),
        ),
      );

      expect(find.text('Sheekh Xuseen Cali Jabuuti'), findsOneWidget);
      expect(find.text('Maktabadda Muxaadarooyinka iyo Duruusta'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
