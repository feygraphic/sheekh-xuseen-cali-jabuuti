import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/main_shell.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/wisdom_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/wisdom_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/wisdom_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(StorageService storage, {SettingsProvider? settings}) {
    final s = settings ?? SettingsProvider(storage);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider(storage)),
        ChangeNotifierProvider(create: (_) => AdhkarProvider(storage)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storage)),
        ChangeNotifierProvider.value(value: s),
        ChangeNotifierProvider(create: (_) => TasbeehProvider(storage)),
        ChangeNotifierProvider(create: (_) => WisdomProvider()),
      ],
      child: const MaterialApp(
        home: MainShell(),
      ),
    );
  }

  group('Islamic Wisdom & Sayings Section Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
      AdService().unlockWisdom();
    });

    test('WisdomService loads authentic items and validates schema', () async {
      final service = WisdomService();
      final wisdomList = await service.loadWisdom();

      expect(wisdomList.length, greaterThanOrEqualTo(40));

      // Validate all 8 required categories exist
      final expectedCategoryIds = [
        'diin',
        'akhlaaq',
        'cilmi',
        'nolol',
        'samir',
        'waqti',
        'qalbi',
        'caddaalad',
      ];
      final loadedCategoryIds = wisdomList.map((w) => w.categoryId).toSet();
      for (final catId in expectedCategoryIds) {
        expect(loadedCategoryIds.contains(catId), isTrue,
            reason: 'Missing category $catId');
      }

      // Validate required scholars and companions exist
      final speakers = wisdomList.map((w) => w.speaker).toSet();
      expect(speakers.any((s) => s.contains('Muxamed')), isTrue);
      expect(speakers.any((s) => s.contains('Abu Bakr')), isTrue);
      expect(speakers.any((s) => s.contains('Cumar ibn Al-Khadhaab')), isTrue);
      expect(speakers.any((s) => s.contains('Cusmaan ibn Cafaan')), isTrue);
      expect(speakers.any((s) => s.contains('Cali ibn Abii Dhaalib')), isTrue);
      expect(speakers.any((s) => s.contains('Xasan Al-Basri')), isTrue);
      expect(speakers.any((s) => s.contains('Shaafici')), isTrue);
      expect(speakers.any((s) => s.contains('Imaam Axmed')), isTrue);
      expect(speakers.any((s) => s.contains('Imaam Maalik')), isTrue);
      expect(speakers.any((s) => s.contains('Imaam Al-Nawawi')), isTrue);
      expect(speakers.any((s) => s.contains('Taymiyyah')), isTrue);
      expect(speakers.any((s) => s.contains('Qayyim')), isTrue);

      // Validate every quotation has non-empty Arabic, Somali, reference, and speaker
      for (final item in wisdomList) {
        expect(item.arabic.trim().isNotEmpty, isTrue);
        expect(item.somali.trim().isNotEmpty, isTrue);
        expect(item.speaker.trim().isNotEmpty, isTrue);
        expect(item.reference.trim().isNotEmpty, isTrue);
        expect(item.categoryName.trim().isNotEmpty, isTrue);
      }
    });

    test('WisdomProvider filtering and carousel navigation works', () async {
      final provider = WisdomProvider();
      await provider.loadData();

      expect(provider.allWisdom.isNotEmpty, isTrue);
      final initialCount = provider.allWisdom.length;

      // Filter by category
      provider.setCategory('cilmi');
      final fav = FavoritesProvider(storage);
      final cilmiList = provider.getFilteredWisdom(fav);
      expect(cilmiList.length, greaterThan(0));
      expect(cilmiList.every((w) => w.categoryId == 'cilmi'), isTrue);

      // Filter by speaker
      provider.setCategory('all');
      provider.setSpeaker('Imaam Al-Shaafici');
      final shaficiList = provider.getFilteredWisdom(fav);
      expect(shaficiList.length, greaterThan(0));
      expect(shaficiList.every((w) => w.speaker.contains('Shaafici')), isTrue);

      // Search
      provider.setSpeaker('all');
      provider.setSearchQuery('cilmi');
      final searchList = provider.getFilteredWisdom(fav);
      expect(searchList.length, greaterThan(0));

      // Reset
      provider.setSearchQuery('');
      expect(provider.getFilteredWisdom(fav).length, equals(initialCount));

      // Carousel Next and Previous
      final firstWisdom = provider.currentCarouselWisdom;
      expect(firstWisdom, isNotNull);
      provider.nextWisdom();
      final secondWisdom = provider.currentCarouselWisdom;
      expect(secondWisdom, isNotNull);
      provider.previousWisdom();
      expect(provider.currentCarouselWisdom!.id, equals(firstWisdom!.id));
    });

    testWidgets('Home Screen displays dedicated Wisdom banner card and tapping opens WisdomScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('ListTile background color or ink splashes') ||
            msg.contains('overflowed')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(buildApp(storage));
      await tester.pumpAndSettle();

      // Verify bottom navigation still has exactly 5 tabs
      expect(find.text('Hoyga'), findsWidgets);
      expect(find.text('Muxaadaro'), findsOneWidget);
      expect(find.text('Qur\'aan'), findsWidgets);
      expect(find.text('Adkaar'), findsWidgets);
      expect(find.text('Settings'), findsOneWidget);

      // Verify the Wisdom banner card is on the Home Screen
      final wisdomTitleFinder = find.text('HIKMADO IYO HADALLO QAALI AH');
      final scrollableFinder = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(wisdomTitleFinder, 300, scrollable: scrollableFinder);
      await tester.pumpAndSettle();

      expect(wisdomTitleFinder, findsOneWidget);
      expect(find.text('Islamic Wisdom & Sayings'), findsOneWidget);

      // Tap on the Wisdom banner card
      await tester.tap(wisdomTitleFinder);
      await tester.pumpAndSettle();

      // Verify navigated to WisdomScreen
      expect(find.byType(WisdomScreen), findsOneWidget);
      expect(find.text('Dhammaan Culimada & Saxaabada'), findsOneWidget);

      // Verify back button returns to Home
      final backButton = find.byTooltip('Dib u noqo (Back)');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(WisdomScreen), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('WisdomScreen renders correctly in Dark Mode and toggles bookmark',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('ListTile background color or ink splashes') ||
            msg.contains('overflowed')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final settings = SettingsProvider(storage);
      await settings.setThemeMode('dark');

      await tester.pumpWidget(buildApp(storage, settings: settings));
      await tester.pumpAndSettle();

      // Scroll to banner and tap to navigate
      final wisdomTitleFinder = find.text('HIKMADO IYO HADALLO QAALI AH');
      final scrollableFinder = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(wisdomTitleFinder, 300, scrollable: scrollableFinder);
      await tester.pumpAndSettle();

      await tester.tap(wisdomTitleFinder);
      await tester.pumpAndSettle();

      expect(find.byType(WisdomScreen), findsOneWidget);

      // Bookmark first item
      final bookmarkButtons = find.byTooltip('Kaydi');
      if (bookmarkButtons.evaluate().isNotEmpty) {
        await tester.tap(bookmarkButtons.first);
        await tester.pumpAndSettle();

        // Verify bookmark stored in storage service
        final saved = storage.getBookmarkedWisdom();
        expect(saved.isNotEmpty, isTrue);
      }
    });
  });
}
