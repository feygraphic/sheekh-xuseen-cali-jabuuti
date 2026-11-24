import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/player_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/adhkar_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/quran_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/ramadan_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/audio_category.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/adkhar_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/surah_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/ramadan_lecture.dart';

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

  Widget buildPlayerScreen({
    required StorageService storage,
    required SettingsProvider settings,
    required AudioPlayerProvider audio,
    required FavoritesProvider fav,
    AudioCategory? initialCategory,
    AdkharModel? adhkar,
    SurahModel? surah,
    RamadanLecture? ramadanLecture,
    RamadanScholar? ramadanScholar,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerProvider>.value(value: audio),
        ChangeNotifierProvider<FavoritesProvider>.value(value: fav),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider(create: (_) => AdhkarProvider(storage)),
        ChangeNotifierProvider(create: (_) => TasbeehProvider(storage)),
      ],
      child: MaterialApp(
        home: PlayerScreen(
          initialCategory: initialCategory,
          adhkar: adhkar,
          surah: surah,
          ramadanLecture: ramadanLecture,
          ramadanScholar: ramadanScholar,
        ),
      ),
    );
  }

  group('Audio Category Metadata & Player Integration Tests', () {
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

    testWidgets('Adhkar Audio: displays Adhkar metadata and artwork, NOT Sheikh Xuseen lecture metadata', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final sampleAdhkar = AdhkarData.allAdhkar.first; // Aayatal Kursi

      // Build Player Screen with Adhkar category
      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
        initialCategory: AudioCategory.adhkar,
        adhkar: sampleAdhkar,
      ));
      await tester.pumpAndSettle();

      // Verify Adhkar Metadata is rendered
      expect(find.text('ADKAAR & DUCOOYIN'), findsOneWidget);
      expect(find.text(sampleAdhkar.title), findsOneWidget);
      expect(find.text('Adkaar Saxiix ah'), findsOneWidget);
      expect(find.text('Liiska Adkaarta'), findsOneWidget);

      // Verify Sheikh Xuseen lecture metadata is NOT displayed
      expect(find.text('Sheekh Xuseen Cali Jabuuti'), findsNothing);
      expect(find.text('Silsiladda Caqiidada'), findsNothing);
      expect(find.text('Ahmiyadda Towxiidka iyo Caqiidada Saxda ah'), findsNothing);
      expect(find.text('Sheekha Rasmiga ah'), findsNothing);
    });

    testWidgets('Lecture Audio: displays Sheikh Xuseen lecture metadata, artwork, and series title', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      // Lecture is loaded by default
      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // Verify Lecture Metadata
      expect(find.text('MUXAADARADA'), findsOneWidget);
      expect(find.textContaining('Sheekh Xuseen Cali Jabuuti'), findsOneWidget);
      expect(find.text('Sheekha Rasmiga ah'), findsOneWidget);
      expect(find.text('Muxaadarooyinka'), findsOneWidget);

      // Verify Adhkar or Quran badges are not shown
      expect(find.text('ADKAAR & DUCOOYIN'), findsNothing);
      expect(find.text('QUR\'AANKA KARIIMKA'), findsNothing);
    });

    testWidgets('Quran Audio: displays Surah name and Quran badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final surah = QuranData.allSurahs.first; // Al-Faatiha

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
        initialCategory: AudioCategory.quran,
        surah: surah,
      ));
      await tester.pumpAndSettle();

      expect(find.text('QUR\'AANKA KARIIMKA'), findsOneWidget);
      expect(find.text('Qiraa\'o Toos ah'), findsOneWidget);
      expect(find.text('Qur\'aanka Kariimka'), findsOneWidget);
      expect(find.text('Sheekha Rasmiga ah'), findsNothing);
    });

    testWidgets('Ramadan Audio: displays Ramadan lecture title, scholar name, and Ramadan badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final scholar = RamadanData.scholars.first;
      final lectures = RamadanData.getLecturesByScholar(scholar.id);
      expect(lectures, isNotEmpty);
      final lecture = lectures.first;

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
        initialCategory: AudioCategory.ramadan,
        ramadanLecture: lecture,
        ramadanScholar: scholar,
      ));
      await tester.pumpAndSettle();

      expect(find.text('RAMADAAN MUXAADARO'), findsOneWidget);
      expect(find.text(lecture.displayTitle), findsOneWidget);
      expect(find.text('Sheekh: ${scholar.name}'), findsOneWidget);
      expect(find.text('Muxaadarooyinka Ramadaanka'), findsOneWidget);
      expect(find.text('Sheekha Rasmiga ah'), findsNothing);
    });

    testWidgets('Adhkar Bookmarking in PlayerScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final sampleAdhkar = AdhkarData.allAdhkar.first;

      expect(fav.isAdhkarBookmarked(sampleAdhkar.id), isFalse);

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
        initialCategory: AudioCategory.adhkar,
        adhkar: sampleAdhkar,
      ));
      await tester.pumpAndSettle();

      // Find the favorite button and tap it
      final favButtonFinder = find.byTooltip('Kaydi');
      expect(favButtonFinder, findsOneWidget);

      await tester.tap(favButtonFinder);
      await tester.pumpAndSettle();

      // Verify Adhkar bookmark is now toggled true
      expect(fav.isAdhkarBookmarked(sampleAdhkar.id), isTrue);
      expect(fav.isLectureBookmarked(sampleAdhkar.id), isFalse);
    });

    testWidgets('Queue Sheet for Adhkar displays adhkar playlist and allows selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final sampleAdhkar = AdhkarData.allAdhkar.first;

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
        initialCategory: AudioCategory.adhkar,
        adhkar: sampleAdhkar,
      ));
      await tester.pumpAndSettle();

      // Tap Queue button
      final queueButton = find.byTooltip('Liiska Adkaarta');
      expect(queueButton, findsOneWidget);
      await tester.tap(queueButton);
      await tester.pumpAndSettle();

      // Verify Queue bottom sheet is displayed with Adhkar list
      expect(find.text('Liiska Adkaarta (${AdhkarData.allAdhkar.length})'), findsOneWidget);
      expect(find.text('Xuska Alle iyo Ducooyinka Saxiixa ah'), findsOneWidget);
    });
  });
}
