import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/constants/app_colors.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/player_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/adhkar_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/favorites_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/tasbeeh_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';

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

  Widget buildPlayerScreen({
    required StorageService storage,
    required SettingsProvider settings,
    required AudioPlayerProvider audio,
    required FavoritesProvider fav,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerProvider>.value(value: audio),
        ChangeNotifierProvider<FavoritesProvider>.value(value: fav),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider(create: (_) => AdhkarProvider(storage)),
        ChangeNotifierProvider(create: (_) => TasbeehProvider(storage)),
      ],
      child: const MaterialApp(
        home: PlayerScreen(),
      ),
    );
  }

  group('PlayerScreen Global Theme Integration Tests', () {
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

    testWidgets('Light Mode: PlayerScreen renders with Light Mode palette and tokens', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await settings.setThemeMode('light');
      expect(settings.isDarkMode, isFalse);

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // 1. Scaffold background must match AppTheme.bg(false)
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.bg(false)));

      // 2. Title text 'Faahfaahinta Codka' present with dark readable text color
      final titleFinder = find.text('Faahfaahinta Codka');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.color, equals(AppTheme.text(false)));

      // 3. Slider uses AppColors.primary for activeTrackColor in Light Mode
      final sliderThemeFinder = find.byType(SliderTheme);
      expect(sliderThemeFinder, findsOneWidget);
      final sliderTheme = tester.widget<SliderTheme>(sliderThemeFinder);
      expect(sliderTheme.data.activeTrackColor, equals(AppColors.primary));
      expect(sliderTheme.data.inactiveTrackColor, equals(AppColors.primaryFixed));

      // 4. Play/Pause button uses AppColors.primary with white icon
      final playIconFinder = find.byIcon(Icons.play_arrow_rounded);
      expect(playIconFinder, findsOneWidget);
      final playIcon = tester.widget<Icon>(playIconFinder);
      expect(playIcon.color, equals(Colors.white));

      // 5. Playback navigation icons have proper contrast (AppTheme.icon(false))
      final skipPrevIcon = tester.widget<Icon>(find.byIcon(Icons.skip_previous_rounded));
      expect(skipPrevIcon.color, equals(AppTheme.icon(false)));

      final replay10Icon = tester.widget<Icon>(find.byIcon(Icons.replay_10_rounded));
      expect(replay10Icon.color, equals(AppTheme.icon(false)));
    });

    testWidgets('Dark Mode: PlayerScreen renders with Dark Mode palette and tokens', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await settings.setThemeMode('dark');
      expect(settings.isDarkMode, isTrue);

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // 1. Scaffold background must match AppTheme.bg(true) (0xFF121212)
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.bg(true)));

      // 2. Title text has dark text primary color
      final titleFinder = find.text('Faahfaahinta Codka');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.color, equals(AppTheme.text(true)));

      // 3. Slider uses AppTheme.primaryLight for activeTrackColor in Dark Mode
      final sliderThemeFinder = find.byType(SliderTheme);
      expect(sliderThemeFinder, findsOneWidget);
      final sliderTheme = tester.widget<SliderTheme>(sliderThemeFinder);
      expect(sliderTheme.data.activeTrackColor, equals(AppTheme.primaryLight));

      // 4. Play/Pause icon is high contrast dark violet on lavender button
      final playIcon = tester.widget<Icon>(find.byIcon(Icons.play_arrow_rounded));
      expect(playIcon.color, equals(const Color(0xFF1D0061)));
    });

    testWidgets('Dynamic Theme Switching: updates immediately without restart', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      // Start in Light Mode
      await settings.setThemeMode('light');

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, equals(AppTheme.bg(false)));

      // Dynamically toggle to Dark Mode
      await settings.setThemeMode('dark');
      await tester.pumpAndSettle();

      expect(settings.isDarkMode, isTrue);
      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, equals(AppTheme.bg(true)));

      // Slider updated dynamically to AppTheme.primaryLight
      var sliderTheme = tester.widget<SliderTheme>(find.byType(SliderTheme));
      expect(sliderTheme.data.activeTrackColor, equals(AppTheme.primaryLight));

      // Dynamically toggle back to Light Mode
      await settings.setThemeMode('light');
      await tester.pumpAndSettle();

      expect(settings.isDarkMode, isFalse);
      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, equals(AppTheme.bg(false)));
      sliderTheme = tester.widget<SliderTheme>(find.byType(SliderTheme));
      expect(sliderTheme.data.activeTrackColor, equals(AppColors.primary));
    });

    testWidgets('Queue Sheet and Sleep Timer Dialog follow active theme', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await settings.setThemeMode('light');

      await tester.pumpWidget(buildPlayerScreen(
        storage: storage,
        settings: settings,
        audio: audio,
        fav: fav,
      ));
      await tester.pumpAndSettle();

      // Open Sleep Timer Dialog in Light Mode
      await tester.tap(find.byTooltip('Waqtiga Hurdada'));
      await tester.pumpAndSettle();

      expect(find.text('Waqtiga Hurdada (Sleep Timer)'), findsOneWidget);
      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alertDialog.backgroundColor, equals(AppTheme.card(false)));

      // Close dialog
      await tester.tap(find.text('15 Daqiiqo Kadib'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      // Cancel sleep timer so no pending timers remain
      audio.cancelSleepTimer();

      // Open Queue Sheet in Light Mode
      await tester.tap(find.byTooltip('Liiska Muxaadarooyinka'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Liiska Muxaadarooyinka'), findsOneWidget);
      // Close sheet by popping Navigator
      Navigator.of(tester.element(find.textContaining('Liiska Muxaadarooyinka'))).pop();
      await tester.pumpAndSettle();
      expect(find.textContaining('Liiska Muxaadarooyinka'), findsNothing);
    });
  });
}
