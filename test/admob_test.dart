import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/ad_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/widgets/adaptive_banner_widget.dart';
import 'package:sheekh_xuseen_cali_jabuuti/widgets/wisdom_unlock_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(instanceManager.channel, (MethodCall call) async {
      return null;
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(instanceManager.channel, null);
  });

  group('Google AdMob Configuration & Safety Tests', () {
    test('AdService singleton returns exact official production AdMob IDs', () {
      expect(AdService.prodAppId, 'ca-app-pub-2250790038733678~7045184172');
      expect(AdService.prodBannerUnitId, 'ca-app-pub-2250790038733678/7807262196');
      expect(AdService.prodInterstitialUnitId, 'ca-app-pub-2250790038733678/8166694152');
      expect(AdService.prodRewardedUnitId, 'ca-app-pub-2250790038733678/4393139092');

      // In debug/test mode (kReleaseMode == false), test unit IDs must be served to protect account
      if (!kReleaseMode) {
        expect(AdService.bannerAdUnitId, AdService.testBannerUnitId);
        expect(AdService.interstitialAdUnitId, AdService.testInterstitialUnitId);
        expect(AdService.rewardedAdUnitId, AdService.testRewardedUnitId);
      }
    });

    test('AndroidManifest.xml contains official AdMob App ID meta-data', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue, reason: 'AndroidManifest.xml must exist');

      final content = manifestFile.readAsStringSync();
      expect(
        content.contains('com.google.android.gms.ads.APPLICATION_ID'),
        isTrue,
        reason: 'APPLICATION_ID meta-data tag must be present',
      );
      expect(
        content.contains('ca-app-pub-2250790038733678~7045184172'),
        isTrue,
        reason: 'Official AdMob App ID ca-app-pub-2250790038733678~7045184172 must be in AndroidManifest.xml',
      );
    });

    test('Interstitial ad never blocks navigation when audio is playing', () {
      final adService = AdService();
      bool dismissedCalled = false;

      adService.showInterstitialAd(
        isAudioPlaying: true,
        isSacredReading: false,
        onDismissed: () {
          dismissedCalled = true;
        },
      );

      expect(dismissedCalled, isTrue, reason: 'Navigation should proceed immediately when audio is playing');
    });

    test('Interstitial ad never blocks navigation during sacred reading (Quran/Dua)', () {
      final adService = AdService();
      bool dismissedCalled = false;

      adService.showInterstitialAd(
        isAudioPlaying: false,
        isSacredReading: true,
        onDismissed: () {
          dismissedCalled = true;
        },
      );

      expect(dismissedCalled, isTrue, reason: 'Navigation should proceed immediately during sacred reading');
    });

    test('Interstitial ad never blocks navigation when ad is not loaded or in cooldown', () {
      final adService = AdService();
      bool dismissedCalled = false;

      adService.showInterstitialAd(
        isAudioPlaying: false,
        isSacredReading: false,
        onDismissed: () {
          dismissedCalled = true;
        },
      );

      expect(dismissedCalled, isTrue, reason: 'Navigation must proceed seamlessly without blocking');
    });

    testWidgets('AdaptiveBannerWidget renders safely without crashing when uninitialized',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveBannerWidget(isDark: false),
          ),
        ),
      );

      expect(find.byType(AdaptiveBannerWidget), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('Rewarded Ad – Islamic Wisdom Section Tests', () {
    setUp(() {
      AdService().resetWisdomLockForTesting();
    });

    test('Wisdom section starts locked by default in a new session', () {
      final adService = AdService();
      expect(adService.isWisdomUnlocked, isFalse);
    });

    test('unlockWisdom marks section as unlocked for the session', () {
      final adService = AdService();
      expect(adService.isWisdomUnlocked, isFalse);
      adService.unlockWisdom();
      expect(adService.isWisdomUnlocked, isTrue);
    });

    testWidgets('When locked, showWisdomUnlockDialog displays explanation dialog',
        (WidgetTester tester) async {
      bool unlockedCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWisdomUnlockDialog(
                      context: context,
                      isDark: false,
                      onUnlocked: () {
                        unlockedCallbackCalled = true;
                      },
                    );
                  },
                  child: const Text('Open Wisdom'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Wisdom'));
      await tester.pumpAndSettle();

      // Explanation dialog must be displayed
      expect(find.text('Furitaanka Xikmadaha'), findsOneWidget);
      expect(find.text('حِكَمٌ وَمَوَاعِظُ إِسْلَامِيَّة'), findsOneWidget);
      expect(find.text('Daawo Xayeysiiska'), findsOneWidget);
      expect(find.text('Ka Noqo'), findsOneWidget);
      expect(unlockedCallbackCalled, isFalse);

      // Tapping 'Ka Noqo' dismisses dialog and keeps section locked
      await tester.tap(find.text('Ka Noqo'));
      await tester.pumpAndSettle();

      expect(find.text('Furitaanka Xikmadaha'), findsNothing);
      expect(unlockedCallbackCalled, isFalse);
      expect(AdService().isWisdomUnlocked, isFalse);
    });

    testWidgets('When already unlocked, showWisdomUnlockDialog navigates immediately without dialog',
        (WidgetTester tester) async {
      AdService().unlockWisdom();
      bool unlockedCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showWisdomUnlockDialog(
                      context: context,
                      isDark: false,
                      onUnlocked: () {
                        unlockedCallbackCalled = true;
                      },
                    );
                  },
                  child: const Text('Open Wisdom'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Wisdom'));
      await tester.pumpAndSettle();

      // Since unlocked, callback is invoked immediately and NO dialog appears
      expect(unlockedCallbackCalled, isTrue);
      expect(find.text('Furitaanka Xikmadaha'), findsNothing);
    });
  });
}
