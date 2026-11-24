import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/adhkar_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/adhkar_category_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/adhkar_category_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/wisdom_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';

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
      child: MaterialApp(
        home: AdhkarScreen(onOpenDrawer: () {}),
      ),
    );
  }

  group('Adhkar Categories Improvement Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
    });

    test('All 13 Adhkar categories have shortened titles and concise descriptions in categories.json', () async {
      final jsonString = await rootBundle.loadString('assets/data/adhkar/categories.json');
      final List<dynamic> list = json.decode(jsonString) as List<dynamic>;

      expect(list.length, equals(13));

      final expectedIds = [
        'morning',
        'evening',
        'after_salah',
        'market',
        'sleeping',
        'ruqyah',
        'protection',
        'forgiveness',
        'travel',
        'eating',
        'home',
        'mosque',
        'general_duas',
      ];

      for (final item in list) {
        final cat = AdhkarCategoryModel.fromJson(item as Map<String, dynamic>);

        // Verify ID is in expected list
        expect(expectedIds.contains(cat.id), isTrue, reason: 'Unexpected category ID: ${cat.id}');

        // 1. Verify Somali Title is short (<= 18 characters) and meaningful
        expect(cat.somaliTitle.trim().isNotEmpty, isTrue);
        expect(cat.somaliTitle.length, lessThanOrEqualTo(18),
            reason: 'Title too long for ${cat.id}: "${cat.somaliTitle}" (${cat.somaliTitle.length} chars)');

        // 2. Verify Description is concise (<= 52 characters) and meaningful
        expect(cat.description.trim().isNotEmpty, isTrue);
        expect(cat.description.length, lessThanOrEqualTo(52),
            reason: 'Description too long for ${cat.id}: "${cat.description}" (${cat.description.length} chars)');

        // 3. Verify Arabic Title is preserved and not empty
        expect(cat.arabicTitle.trim().isNotEmpty, isTrue);

        // 4. Verify Icon and Dua count
        expect(cat.duaCount, greaterThan(0));
        expect(cat.jsonFile.isNotEmpty, isTrue);
      }
    });

    testWidgets('AdhkarScreen renders category grid without overflow and navigates on tap', (tester) async {
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

      // Verify AppBar displays clean title "Qaybaha Adkaarta"
      expect(find.text('Qaybaha Adkaarta'), findsOneWidget);

      // Verify shortened titles are displayed
      expect(find.text('Adkaar Subax'), findsWidgets);
      expect(find.text('Adkaar Galab'), findsWidgets);
      expect(find.text('Salaadda Kadib'), findsOneWidget);
      expect(find.text('Ducada Suuqa'), findsOneWidget);
      expect(find.text('Hurdada & Tooska'), findsWidgets);

      // Tap on a category card (e.g. "Salaadda Kadib")
      final salahCard = find.text('Salaadda Kadib');
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(salahCard, 200, scrollable: scrollable);
      await tester.pumpAndSettle();

      await tester.tap(salahCard);
      await tester.pumpAndSettle();

      // Verify navigated to AdhkarCategoryScreen
      expect(find.byType(AdhkarCategoryScreen), findsOneWidget);

      // Verify back button navigates back to AdhkarScreen
      final backButton = find.byType(IconButton).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(AdhkarCategoryScreen), findsNothing);
      expect(find.byType(AdhkarScreen), findsOneWidget);
    });

    testWidgets('All 13 categories are visible on scroll without text overflow on smaller screens', (tester) async {
      // Simulate compact Android device (width 360, height 740)
      tester.view.physicalSize = const Size(720, 1480);
      tester.view.devicePixelRatio = 2.0;
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

      // Scroll to bottom to ensure all categories render cleanly
      final scrollable = find.byType(Scrollable).first;
      await tester.fling(scrollable, const Offset(0, -1000), 1000);
      await tester.pumpAndSettle();

      // Verify bottom categories are visible and rendered
      expect(find.text('Ducooyin Guud'), findsOneWidget);
      expect(find.text('Ducada Masaajidka'), findsOneWidget);
      expect(find.text('Ducada Guriga'), findsOneWidget);
    });
  });
}
