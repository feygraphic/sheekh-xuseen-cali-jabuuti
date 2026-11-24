import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/screens/app_splash_screen.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Splash Screen & App Icon Asset Integrity Tests', () {
    test('New Sheikh portrait asset exists and is valid', () {
      final portraitFile = File('assets/images/sheikh_portrait_new.jpg');
      expect(portraitFile.existsSync(), isTrue, reason: 'Portrait asset must exist in assets/images');
      expect(portraitFile.lengthSync(), greaterThan(100000), reason: 'High-res image should exceed 100KB');
    });

    test('All Android launcher icon densities exist with square, round, and adaptive layers', () {
      final densities = ['mipmap-mdpi', 'mipmap-hdpi', 'mipmap-xhdpi', 'mipmap-xxhdpi', 'mipmap-xxxhdpi'];

      for (final density in densities) {
        final legacyIcon = File('android/app/src/main/res/$density/ic_launcher.png');
        final roundIcon = File('android/app/src/main/res/$density/ic_launcher_round.png');
        final foregroundIcon = File('android/app/src/main/res/$density/ic_launcher_foreground.png');

        expect(legacyIcon.existsSync(), isTrue, reason: '$density/ic_launcher.png missing');
        expect(roundIcon.existsSync(), isTrue, reason: '$density/ic_launcher_round.png missing');
        expect(foregroundIcon.existsSync(), isTrue, reason: '$density/ic_launcher_foreground.png missing');

        expect(legacyIcon.lengthSync(), greaterThan(1500));
        expect(roundIcon.lengthSync(), greaterThan(1500));
        expect(foregroundIcon.lengthSync(), greaterThan(1500));
      }

      // Check adaptive icon XML definitions
      final adaptiveIcon = File('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml');
      final adaptiveRoundIcon = File('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml');
      expect(adaptiveIcon.existsSync(), isTrue);
      expect(adaptiveRoundIcon.existsSync(), isTrue);
    });

    test('AndroidManifest.xml contains both standard icon and roundIcon definitions', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest.contains('android:icon="@mipmap/ic_launcher"'), isTrue);
      expect(manifest.contains('android:roundIcon="@mipmap/ic_launcher_round"'), isTrue);
    });

    test('Native launch background uses splash logo and theme background', () {
      final launchBg = File('android/app/src/main/res/drawable/launch_background.xml').readAsStringSync();
      final splashLogo = File('android/app/src/main/res/drawable/splash_logo.png');

      expect(splashLogo.existsSync(), isTrue);
      expect(launchBg.contains('@color/splash_background'), isTrue);
      expect(launchBg.contains('@drawable/splash_logo'), isTrue);
    });

    test('Android 12+ (API 31+) SplashScreen API configurations exist and are valid', () {
      final v31Light = File('android/app/src/main/res/values-v31/styles.xml');
      final v31Night = File('android/app/src/main/res/values-night-v31/styles.xml');
      final v31Icon = File('android/app/src/main/res/drawable/splash_icon_v31.xml');

      expect(v31Light.existsSync(), isTrue, reason: 'values-v31/styles.xml must exist for Android 12+');
      expect(v31Night.existsSync(), isTrue, reason: 'values-night-v31/styles.xml must exist for Android 12+');
      expect(v31Icon.existsSync(), isTrue, reason: 'splash_icon_v31.xml must exist for Android 12+');

      final lightContent = v31Light.readAsStringSync();
      expect(lightContent.contains('android:windowSplashScreenBackground'), isTrue);
      expect(lightContent.contains('android:windowSplashScreenAnimatedIcon'), isTrue);
      expect(lightContent.contains('@drawable/splash_icon_v31'), isTrue);
    });

    test('Play Store 512x512 icon is generated', () {
      final playStoreIcon = File('android/app/src/main/play_store_512.png');
      expect(playStoreIcon.existsSync(), isTrue);
      expect(playStoreIcon.lengthSync(), greaterThan(50000));
    });
  });

  group('AppSplashScreen Widget & Animation Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
    });

    testWidgets('AppSplashScreen displays title, portrait card, and branding', (WidgetTester tester) async {
      final storage = await StorageService.getInstance();
      final settings = SettingsProvider(storage);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: settings,
          child: const MaterialApp(
            home: AppSplashScreen(autoNavigate: false),
          ),
        ),
      );

      // Verify splash elements
      expect(find.text('Sheekh Xuseen Cali Jabuuti'), findsOneWidget);
      expect(find.text('Maktabadda Muxaadarooyinka iyo Duruusta'), findsOneWidget);
      expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Advance animation frames cleanly
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sheekh Xuseen Cali Jabuuti'), findsOneWidget);
    });
  });
}
