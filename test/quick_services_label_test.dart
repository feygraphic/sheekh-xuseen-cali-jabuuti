import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/home_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock platform channels
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

  Widget buildHomeScreen({
    required StorageService storage,
    required SettingsProvider settings,
    required AudioPlayerProvider audio,
    required FavoritesProvider fav,
    double textScaleFactor = 1.0,
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child!,
        ),
        home: HomeScreen(
          onTabChange: (_) {},
          onOpenDrawer: () {},
        ),
      ),
    );
  }

  group('Quick Services Label Single-Line & Alignment Tests', () {
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

    for (final size in [
      const Size(320, 640), // Compact Android
      const Size(360, 780), // Standard Android (Galaxy A series)
      const Size(390, 844), // Modern Standard Android
      const Size(412, 915), // Large Android Flagship
    ]) {
      testWidgets('Android Size ${size.width}x${size.height}: Ramadan & Fatwooyin single-line without wrapping', (tester) async {
        tester.view.physicalSize = size * 2.0;
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          final msg = details.exceptionAsString();
          if (msg.contains('overflowed') || msg.contains('ink splashes')) return;
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        await tester.pumpWidget(buildHomeScreen(
          storage: storage,
          settings: settings,
          audio: audio,
          fav: fav,
        ));
        await tester.pumpAndSettle();

        // 1. Scroll vertically if needed so Quick Services is in view
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
        await tester.pumpAndSettle();

        // 2. Drag the horizontal Quick Services ListView to reveal Ramadaan & Fatwooyin
        final horizontalListView = find.byType(ListView).first;
        await tester.drag(horizontalListView, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // 3. Verify Ramadaan and Fatwooyin labels exist
        final ramadaanFinder = find.text('Ramadaan');
        final fatwooyinFinder = find.text('Fatwooyin');
        expect(ramadaanFinder, findsOneWidget);
        expect(fatwooyinFinder, findsOneWidget);

        // 4. Verify Ramadaan and Fatwooyin Text widgets have maxLines: 1 and softWrap: false
        final ramadaanText = tester.widget<Text>(ramadaanFinder);
        expect(ramadaanText.maxLines, equals(1));
        expect(ramadaanText.softWrap, isFalse);

        final fatwooyinText = tester.widget<Text>(fatwooyinFinder);
        expect(fatwooyinText.maxLines, equals(1));
        expect(fatwooyinText.softWrap, isFalse);

        // 5. Verify render box height corresponds to a SINGLE line (less than 25 pixels)
        final ramadaanBox = tester.renderObject(ramadaanFinder) as RenderBox;
        expect(ramadaanBox.size.height, lessThan(25.0));

        final fatwooyinBox = tester.renderObject(fatwooyinFinder) as RenderBox;
        expect(fatwooyinBox.size.height, lessThan(25.0));
      });
    }

    testWidgets('Large System Font Scale (1.25x): FittedBox prevents wrapping', (tester) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final msg = details.exceptionAsString();
        if (msg.contains('overflowed') || msg.contains('ink splashes')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(buildHomeScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
        textScaleFactor: 1.25,
      ));
      await tester.pumpAndSettle();

      final horizontalListView = find.byType(ListView).first;
      await tester.drag(horizontalListView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      final fatwooyinFinder = find.text('Fatwooyin');
      expect(fatwooyinFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(fatwooyinFinder);
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.softWrap, isFalse);

      final renderBox = tester.renderObject(fatwooyinFinder) as RenderBox;
      // Single line height even under 1.25x scale remains under 25 pixels
      expect(renderBox.size.height, lessThan(25.0));
    });
  });
}
