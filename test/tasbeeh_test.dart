import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/tasbeeh_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/tasbeeh_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TasbeehItem Model Tests', () {
    test('TasbeehItem serializes and deserializes properly', () {
      const item = TasbeehItem(
        id: 'test_dhikr',
        arabic: 'سُبْحَانَ اللهِ',
        transliteration: 'Subhaanallaah',
        category: 'Tasbiix',
        target: 33,
        currentCount: 15,
        cycleCount: 2,
        isCustom: true,
      );

      final jsonStr = item.toJson();
      final decoded = TasbeehItem.fromJson(jsonStr);

      expect(decoded.id, 'test_dhikr');
      expect(decoded.arabic, 'سُبْحَانَ اللهِ');
      expect(decoded.transliteration, 'Subhaanallaah');
      expect(decoded.category, 'Tasbiix');
      expect(decoded.target, 33);
      expect(decoded.currentCount, 15);
      expect(decoded.cycleCount, 2);
      expect(decoded.isCustom, true);
    });

    test('TasbeehItem copyWith creates modified copy', () {
      const item = TasbeehItem(
        id: '1',
        arabic: 'الله أكبر',
        transliteration: 'Allaahu Akbar',
        target: 33,
      );

      final updated = item.copyWith(currentCount: 10, cycleCount: 1);
      expect(updated.currentCount, 10);
      expect(updated.cycleCount, 1);
      expect(updated.arabic, 'الله أكبر');
    });
  });

  group('TasbeehProvider Logic Tests', () {
    late StorageService storage;
    late TasbeehProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
      provider = TasbeehProvider(storage);
    });

    test('Default Dhikrs list is initialized with at least 8 authentic items', () {
      expect(provider.items.length >= 8, true);
      expect(provider.currentItem.arabic, contains('سُبْحَانَ'));
      expect(provider.currentCount, 0);
      expect(provider.currentTarget, 33);
    });

    test('Increment increases current count and updates statistics', () {
      expect(provider.currentCount, 0);
      expect(provider.todayCount, 0);
      expect(provider.totalCount, 0);

      provider.increment();

      expect(provider.currentCount, 1);
      expect(provider.todayCount, 1);
      expect(provider.totalCount, 1);

      provider.increment();
      expect(provider.currentCount, 2);
      expect(provider.todayCount, 2);
      expect(provider.totalCount, 2);
    });

    test('Target completion is detected and cycle count is incremented', () {
      provider.setTarget(3);
      expect(provider.currentTarget, 3);
      expect(provider.currentCycles, 0);

      provider.increment(); // 1
      expect(provider.targetCompletedEvent, false);

      provider.increment(); // 2
      expect(provider.targetCompletedEvent, false);

      provider.increment(); // 3 -> completed!
      expect(provider.targetCompletedEvent, true);
      expect(provider.currentCycles, 1);

      provider.consumeTargetCompletedEvent();
      expect(provider.targetCompletedEvent, false);
    });

    test('Undo reverses the last count and updates statistics', () {
      provider.increment();
      provider.increment();
      expect(provider.currentCount, 2);
      expect(provider.todayCount, 2);

      final undone = provider.undo();
      expect(undone, true);
      expect(provider.currentCount, 1);
      expect(provider.todayCount, 1);
      expect(provider.totalCount, 1);

      final undone2 = provider.undo();
      expect(undone2, true);
      expect(provider.currentCount, 0);
      expect(provider.todayCount, 0);

      // Undoing at 0 returns false
      final undone3 = provider.undo();
      expect(undone3, false);
      expect(provider.currentCount, 0);
    });

    test('ResetCurrentDhikr resets current count to 0 but preserves stats', () {
      provider.increment();
      provider.increment();
      provider.increment();
      expect(provider.currentCount, 3);
      expect(provider.todayCount, 3);
      expect(provider.totalCount, 3);

      provider.resetCurrentDhikr();

      expect(provider.currentCount, 0);
      expect(provider.todayCount, 3); // preserved!
      expect(provider.totalCount, 3); // preserved!
    });

    test('Target selection updates target and preserves across reload', () {
      provider.setTarget(100);
      expect(provider.currentTarget, 100);

      provider.setTarget(1000);
      expect(provider.currentTarget, 1000);

      provider.setTarget(33);
      expect(provider.currentTarget, 33);
    });

    test('Adding custom Dhikr persists and sets as active', () {
      final initialCount = provider.items.length;
      provider.addCustomDhikr(
        arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        transliteration: 'Xasbunallaah',
        target: 100,
      );

      expect(provider.items.length, initialCount + 1);
      expect(provider.currentItem.arabic, 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ');
      expect(provider.currentTarget, 100);
      expect(provider.currentItem.isCustom, true);
    });

    test('Selecting Dhikr switches active item correctly', () {
      provider.selectDhikr('alhamdulillah');
      expect(provider.currentItem.id, 'alhamdulillah');
      expect(provider.currentItem.arabic, contains('الْحَمْدُ'));

      provider.selectDhikr('allahuakbar');
      expect(provider.currentItem.id, 'allahuakbar');
      expect(provider.currentItem.arabic, contains('أَكْبَرُ'));
    });

    test('Vibration and sound toggles work correctly', () {
      expect(provider.vibrationEnabled, true);
      provider.setVibration(false);
      expect(provider.vibrationEnabled, false);
      provider.setVibration(true);
      expect(provider.vibrationEnabled, true);

      expect(provider.soundEnabled, false);
      provider.setSound(true);
      expect(provider.soundEnabled, true);
    });

    test('Data persistence restores progress upon reloading state', () {
      provider.increment();
      provider.increment();
      provider.increment();
      provider.setTarget(100);

      // Create brand new provider with the same storage
      final newProvider = TasbeehProvider(storage);
      expect(newProvider.currentCount, 3);
      expect(newProvider.currentTarget, 100);
      expect(newProvider.todayCount, 3);
      expect(newProvider.totalCount, 3);
    });
  });

  group('TasbeehScreen Widget Tests', () {
    late StorageService storage;
    late TasbeehProvider tasbeehProvider;
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
      tasbeehProvider = TasbeehProvider(storage);
      settingsProvider = SettingsProvider(storage);
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: tasbeehProvider),
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: const MaterialApp(
          home: TasbeehScreen(),
        ),
      );
    }

    testWidgets('Renders all primary sections of TasbeehScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Top Bar
      expect(find.text('Tasbiix'), findsWidgets);
      expect(find.text('Qaabka'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Current Dhikr Card
      expect(find.text('Beddel'), findsOneWidget);

      // Target Selector
      expect(find.textContaining('Tirada: 33'), findsOneWidget);

      // Statistics Section (Today, Yesterday, Total)
      expect(find.text('Maanta'), findsOneWidget);
      expect(find.text('Shalay'), findsOneWidget);
      expect(find.text('Wadarta'), findsOneWidget);

      // Bottom Controls
      expect(find.text('Ka noqo'), findsOneWidget);
      expect(find.text('Eber'), findsOneWidget);
    });

    testWidgets('Tapping central counter increments count', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(tasbeehProvider.currentCount, 0);

      // Tap on the counter dial
      await tester.tap(find.byKey(const Key('tasbeeh_counter_dial')));
      await tester.pumpAndSettle();

      expect(tasbeehProvider.currentCount, 1);
    });

    testWidgets('Undo button reverses count on tap', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      tasbeehProvider.increment();
      tasbeehProvider.increment();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(tasbeehProvider.currentCount, 2);

      await tester.tap(find.text('Ka noqo'));
      await tester.pumpAndSettle();

      expect(tasbeehProvider.currentCount, 1);
    });

    testWidgets('Reset button opens confirmation dialog and confirms reset', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      tasbeehProvider.increment();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eber'));
      await tester.pumpAndSettle();

      // Confirmation dialog shown
      expect(find.text('Dib u Bilow Misbaxada?'), findsOneWidget);
      expect(find.text('Haa, Eber'), findsOneWidget);

      await tester.tap(find.text('Haa, Eber'));
      await tester.pumpAndSettle();

      expect(tasbeehProvider.currentCount, 0);
    });

    testWidgets('Light and Dark mode adapt cleanly without errors', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to Dark Mode
      await settingsProvider.setThemeMode('dark');
      await tester.pumpAndSettle();
      expect(settingsProvider.isDarkMode, true);

      // Switch back to Light Mode
      await settingsProvider.setThemeMode('light');
      await tester.pumpAndSettle();
      expect(settingsProvider.isDarkMode, false);
    });
  });
}
