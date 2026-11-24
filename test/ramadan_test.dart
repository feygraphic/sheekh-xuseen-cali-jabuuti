import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/ramadan_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/ramadan_home_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/ramadan_lectures_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/ramadan_player_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/home_screen.dart';

Widget _buildTestApp({
  required Widget child,
  required StorageService storage,
  required SettingsProvider settings,
  required AudioPlayerProvider audio,
  required FavoritesProvider fav,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ChangeNotifierProvider<AudioPlayerProvider>.value(value: audio),
      ChangeNotifierProvider<FavoritesProvider>.value(value: fav),
      ChangeNotifierProvider(create: (_) => AdhkarProvider(storage)),
      ChangeNotifierProvider(create: (_) => TasbeehProvider(storage)),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register mock platform channels for audioplayers and share_plus
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (MethodCall methodCall) async => null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (MethodCall methodCall) async => null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/share'),
    (MethodCall methodCall) async => null,
  );

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
  });

  group('Ramadan Data Integrity Tests', () {
    test('Total lectures count must be exactly 75', () {
      expect(RamadanData.allLectures.length, equals(75));
    });

    test('Scholar counts must match exact distribution', () {
      final xuseen = RamadanData.getLecturesByScholar('xuseen');
      final umal = RamadanData.getLecturesByScholar('umal');
      final dirir = RamadanData.getLecturesByScholar('dirir');
      final mustafa = RamadanData.getLecturesByScholar('mustafa');
      final shibli = RamadanData.getLecturesByScholar('shibli');

      expect(xuseen.length, equals(10), reason: 'Sheikh Xuseen must have 10 lectures');
      expect(umal.length, equals(20), reason: 'Sheikh Mohamed Umal must have 20 lectures');
      expect(dirir.length, equals(20), reason: 'Sheikh Mohamed Dirir must have 20 lectures');
      expect(mustafa.length, equals(10), reason: 'Sheikh Mustafa must have 10 lectures');
      expect(shibli.length, equals(15), reason: 'Sheikh Sh Shibli must have 15 lectures');

      expect(xuseen.length + umal.length + dirir.length + mustafa.length + shibli.length, equals(75));
    });

    test('All 5 scholars must be defined with metadata', () {
      expect(RamadanData.scholars.length, equals(5));
      final ids = RamadanData.scholars.map((s) => s.id).toList();
      expect(ids, containsAll(['xuseen', 'umal', 'dirir', 'mustafa', 'shibli']));

      for (final scholar in RamadanData.scholars) {
        expect(scholar.name.isNotEmpty, isTrue);
        expect(scholar.arabicTitle.isNotEmpty, isTrue);
        expect(scholar.title.isNotEmpty, isTrue);
        expect(scholar.expectedLectures, greaterThan(0));
      }
    });

    test('All lectures have valid IDs, sort orders, and extracted video IDs', () {
      for (final lecture in RamadanData.allLectures) {
        expect(lecture.id, startsWith('ramadan_'));
        expect(lecture.scholarId.isNotEmpty, isTrue);
        expect(lecture.title.isNotEmpty, isTrue);
        expect(lecture.youtubeUrl, contains('youtu'));
        expect(lecture.videoId != null && lecture.videoId!.isNotEmpty, isTrue,
            reason: 'Video ID must be parsed from ${lecture.youtubeUrl}');
        expect(lecture.thumbnailUrl, startsWith('https://img.youtube.com/vi/'));
        expect(lecture.sortOrder, greaterThan(0));
      }
    });

    test('Lectures within each scholar must be sorted by sortOrder', () {
      for (final scholar in RamadanData.scholars) {
        final lectures = RamadanData.getLecturesByScholar(scholar.id);
        for (var i = 0; i < lectures.length - 1; i++) {
          expect(lectures[i].sortOrder <= lectures[i + 1].sortOrder, isTrue);
        }
      }
    });

    test('Data validation helper detects valid 75 lectures and reports duplicate URLs', () {
      final validation = RamadanData.validateData();
      expect(validation['total_lectures'], equals(75));

      final duplicates = validation['duplicate_urls'] as Map<String, List<String>>;
      expect(duplicates.length, equals(1));
      expect(duplicates.keys.first, contains('AyvT1hqRpEo'));
    });
  });

  group('Ramadan UI & Navigation Tests', () {
    testWidgets('RamadanHomeScreen renders header, banner, and all 5 scholar cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(
        child: const RamadanHomeScreen(),
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('Bisha Ramadaan'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Hero banner
      expect(find.text('KUSOO DHOWOW RAMADAAN'), findsOneWidget);

      // Scholar cards
      expect(find.text('Sheikh Xuseen Cali Jabuuti'), findsOneWidget);
      expect(find.text('Sheikh Mohamed Umal'), findsOneWidget);
      expect(find.text('Sheikh Mohamed Dirir'), findsOneWidget);
      expect(find.text('Sheikh Mustafa'), findsOneWidget);
      expect(find.text('Sheikh Sh Shibli'), findsOneWidget);

      // Lecture counts
      expect(find.text('10 Muxaadaro'), findsNWidgets(2)); // xuseen + mustafa
      expect(find.text('20 Muxaadaro'), findsNWidgets(2)); // umal + dirir
      expect(find.text('15 Muxaadaro'), findsOneWidget); // shibli
    });

    testWidgets('Tapping scholar card navigates to RamadanLecturesScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(
        child: const RamadanHomeScreen(),
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // Tap Sheikh Xuseen Cali Jabuuti card
      await tester.tap(find.text('Sheikh Xuseen Cali Jabuuti'));
      await tester.pumpAndSettle();

      // Should be on RamadanLecturesScreen
      expect(find.text('Sheikh Xuseen Cali Jabuuti'), findsWidgets);
      expect(find.text('10 Muxaadaro oo Ramadaan ah'), findsOneWidget);

      // First lecture title from CSV
      expect(find.text('Faidada Bisha Ramadan'), findsOneWidget);

      // Search bar
      expect(find.byType(TextField), findsOneWidget);

      // Back navigation to HomeScreen
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Mashaa\'iikhda Ramadaanka'), findsOneWidget);
    });

    testWidgets('RamadanLecturesScreen search filter works', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final scholar = RamadanData.scholars.firstWhere((s) => s.id == 'xuseen');
      await tester.pumpWidget(_buildTestApp(
        child: RamadanLecturesScreen(scholar: scholar),
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // Initially shows all 10
      expect(find.text('Faidada Bisha Ramadan'), findsOneWidget);

      // Type "10ka"
      await tester.enterText(find.byType(TextField), '10ka');
      await tester.pumpAndSettle();

      expect(find.text('10ka Daanbe Ramadan'), findsOneWidget);
      expect(find.text('Faidada Bisha Ramadan'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Faidada Bisha Ramadan'), findsOneWidget);
    });

    testWidgets('Tapping lecture opens RamadanPlayerScreen with lecture title and video', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final scholar = RamadanData.scholars.firstWhere((s) => s.id == 'xuseen');
      final lecture = RamadanData.getLecturesByScholar('xuseen').first;

      await tester.pumpWidget(_buildTestApp(
        child: RamadanPlayerScreen(lecture: lecture, scholar: scholar),
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // Top bar title
      expect(find.text('Daawo Muxaadarada'), findsOneWidget);

      // Lecture title
      expect(find.text(lecture.displayTitle), findsWidgets);

      // Scholar name
      expect(find.text(scholar.name), findsWidgets);

      // Back button
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Next / Previous buttons
      expect(find.text('Ka Xiga'), findsOneWidget);
      expect(find.text('Kii Hore'), findsOneWidget);

      // Open Playlist sheet
      await tester.tap(find.byIcon(Icons.playlist_play_rounded));
      await tester.pumpAndSettle();
      expect(find.textContaining('10 Muuqaal'), findsWidgets);
    });

    testWidgets('Quick Services on HomeScreen navigates to RamadanHomeScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(
        child: HomeScreen(onTabChange: (_) {}, onOpenDrawer: () {}),
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // Find Ramadaan quick service button and tap it
      final ramadanBtn = find.text('Ramadaan');
      expect(ramadanBtn, findsOneWidget);

      await tester.tap(ramadanBtn);
      await tester.pumpAndSettle();

      // Should be on RamadanHomeScreen
      expect(find.text('Bisha Ramadaan'), findsOneWidget);
      expect(find.text('Mashaa\'iikhda Ramadaanka'), findsOneWidget);

      // Back to Home
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Adeegyada Degdegga ah'), findsOneWidget);
    });

    testWidgets('Supports Dark Mode properly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await settings.setThemeMode('dark');

      await tester.pumpWidget(_buildTestApp(
        child: const RamadanHomeScreen(),
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bisha Ramadaan'), findsOneWidget);
      expect(find.text('Sheikh Xuseen Cali Jabuuti'), findsOneWidget);
    });
  });
}
