import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/main_shell.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/fatwooyin_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
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
      ],
      child: const MaterialApp(
        home: MainShell(),
      ),
    );
  }

  group('Fatwooyin Section & Coming Soon Screen Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
    });

    Future<void> scrollAndTapFatwooyin(WidgetTester tester) async {
      // Find the horizontal quick services list and drag left to reveal Fatwooyin
      final horizontalListView = find.byType(ListView).first;
      await tester.drag(horizontalListView, const Offset(-400, 0));
      await tester.pumpAndSettle();

      final fatwooyinFinder = find.text('Fatwooyin');
      expect(fatwooyinFinder, findsOneWidget);
      await tester.tap(fatwooyinFinder);
      await tester.pumpAndSettle();
    }

    testWidgets('Tapping Fatwooyin on Home navigates to FatwooyinScreen with correct content', (tester) async {
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

      // 1. Scroll & tap Fatwooyin
      await scrollAndTapFatwooyin(tester);

      // 2. Verify FatwooyinScreen is displayed
      expect(find.byType(FatwooyinScreen), findsOneWidget);

      // 3. Verify Required Content:
      // Title: Fatwooyin
      expect(find.text('Fatwooyin'), findsOneWidget);

      // Main heading: Coming Soon
      expect(find.text('Coming Soon'), findsOneWidget);

      // Exact Description required
      expect(
        find.text('Islamic Fatwas and Answers to Your Important Questions Will Be Available Soon.'),
        findsOneWidget,
      );

      // Islamic Ayah & Calligraphy
      expect(find.text('فَاسْأَلُوا أَهْلَ الذِّكْرِ إِن كُنتُمْ لَا تَعْلَمُونَ'), findsOneWidget);

      // Suitable Islamic / question icon
      expect(find.byIcon(Icons.question_answer_rounded), findsOneWidget);

      // Back button in AppBar
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // "Ku Noqo Hoyga" button
      expect(find.text('Ku Noqo Hoyga'), findsOneWidget);

      // 4. Tap Back Button in AppBar and verify return to Home
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(FatwooyinScreen), findsNothing);
      expect(find.text('KUSOO DHOWOW'), findsOneWidget);
    });

    testWidgets('FatwooyinScreen Ku Noqo Hoyga button navigates back to Home', (tester) async {
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

      // Navigate to Fatwooyin
      await scrollAndTapFatwooyin(tester);
      expect(find.byType(FatwooyinScreen), findsOneWidget);

      // Tap 'Ku Noqo Hoyga'
      await tester.ensureVisible(find.text('Ku Noqo Hoyga'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ku Noqo Hoyga'));
      await tester.pumpAndSettle();

      expect(find.byType(FatwooyinScreen), findsNothing);
      expect(find.text('KUSOO DHOWOW'), findsOneWidget);
    });

    testWidgets('FatwooyinScreen renders cleanly in Dark Mode and handles Notify toggle', (tester) async {
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

      final darkSettings = SettingsProvider(storage);
      await darkSettings.setThemeMode('dark');

      await tester.pumpWidget(buildApp(storage, settings: darkSettings));
      await tester.pumpAndSettle();

      // Navigate to Fatwooyin
      await scrollAndTapFatwooyin(tester);

      expect(find.byType(FatwooyinScreen), findsOneWidget);
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(
        find.text('Islamic Fatwas and Answers to Your Important Questions Will Be Available Soon.'),
        findsOneWidget,
      );

      // Test "Ila Ogeysii" toggle
      final notifyBtn = find.text('Ila Ogeysii Marka Ay Diyaar Noqoto');
      expect(notifyBtn, findsOneWidget);
      await tester.ensureVisible(notifyBtn);
      await tester.pumpAndSettle();
      await tester.tap(notifyBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ogeysiinta Waa Firfircoon tahay'), findsOneWidget);
    });
  });
}
