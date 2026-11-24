import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central Google AdMob Service for Sheikh Xuseen Cali Jabuuti Application.
///
/// Features:
/// - Official Production Ad Unit IDs for release builds; Google Test IDs for dev/testing.
/// - Non-blocking interstitial ads at natural navigation transition points with frequency limits.
/// - Mandatory audio playback & sacred reading protection (never interrupts audio or Quran).
/// - Launch grace period protection (never shows ads immediately upon app launch).
/// - Rewarded ad unlocking system for the Islamic Wisdom section.
/// - Robust preloading, error recovery, and disposal management.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;

  AdService._internal() {
    _appStartTime = DateTime.now();
  }

  // Official Production AdMob IDs provided by user:
  static const String prodAppId = 'ca-app-pub-2250790038733678~7045184172';
  static const String prodBannerUnitId = 'ca-app-pub-2250790038733678/7807262196';
  static const String prodInterstitialUnitId = 'ca-app-pub-2250790038733678/8166694152';
  static const String prodRewardedUnitId = 'ca-app-pub-2250790038733678/4393139092';

  // Google Test IDs (Used during development & debug testing to protect AdMob account):
  static const String testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Select appropriate unit IDs based on build mode:
  // kReleaseMode ensures the official production IDs are used in release builds.
  static String get bannerAdUnitId =>
      kReleaseMode ? prodBannerUnitId : testBannerUnitId;

  static String get interstitialAdUnitId =>
      kReleaseMode ? prodInterstitialUnitId : testInterstitialUnitId;

  static String get rewardedAdUnitId =>
      kReleaseMode ? prodRewardedUnitId : testRewardedUnitId;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  late final DateTime _appStartTime;
  // Launch grace period: no interstitial within first 25 seconds of app launch
  static const Duration _launchGracePeriod = Duration(seconds: 25);

  // Interstitial Ad Management
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  DateTime? _lastInterstitialShownAt;
  int _navigationTransitionCount = 0;

  // Reasonable frequency limits:
  // Minimum 60 seconds cooldown between interstitial ads
  static const Duration _interstitialCooldown = Duration(seconds: 60);
  // Show interstitial at most once every 3 major transitions
  static const int _transitionsPerInterstitial = 3;

  // Rewarded Ad Management
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // Session-based access state for Islamic Wisdom section
  bool _isWisdomUnlocked = false;
  bool get isWisdomUnlocked => _isWisdomUnlocked;

  void unlockWisdom() {
    _isWisdomUnlocked = true;
  }

  void resetWisdomLockForTesting() {
    _isWisdomUnlocked = false;
  }

  Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitialAd();
      preloadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  // --- Preloading Ads ---

  void preloadInterstitialAd() {
    if (kIsWeb || _interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialLoading = false;
            debugPrint('AdMob: Interstitial ad loaded successfully.');
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob: Interstitial failed to load: ${error.message} (code: ${error.code})');
            _interstitialAd = null;
            _isInterstitialLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('AdMob: Error preloading interstitial ad: $e');
      _interstitialAd = null;
      _isInterstitialLoading = false;
    }
  }

  void preloadRewardedAd({void Function(bool success)? onComplete}) {
    if (kIsWeb) {
      onComplete?.call(false);
      return;
    }
    if (_rewardedAd != null) {
      onComplete?.call(true);
      return;
    }
    if (_isRewardedLoading) {
      return;
    }
    _isRewardedLoading = true;

    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedLoading = false;
            debugPrint('AdMob: Rewarded ad loaded successfully.');
            onComplete?.call(true);
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob: Rewarded ad failed to load: ${error.message} (code: ${error.code})');
            _rewardedAd = null;
            _isRewardedLoading = false;
            onComplete?.call(false);
          },
        ),
      );
    } catch (e) {
      debugPrint('AdMob: Error preloading rewarded ad: $e');
      _rewardedAd = null;
      _isRewardedLoading = false;
      onComplete?.call(false);
    }
  }

  // --- Interstitial Display with Natural Navigation & Frequency Limits ---

  /// Attempts to display an interstitial ad at a natural transition.
  /// Calls [onDismissed] immediately if ad is unavailable, capped, in cooldown, or during audio/reading.
  /// Navigation is NEVER blocked.
  void showInterstitialAd({
    required VoidCallback onDismissed,
    bool isAudioPlaying = false,
    bool isSacredReading = false,
  }) {
    _navigationTransitionCount++;

    // Safety checks: Never interrupt active audio or sacred reading, skip on web
    if (kIsWeb || isAudioPlaying || isSacredReading) {
      onDismissed();
      return;
    }

    final now = DateTime.now();

    // Never show an ad immediately when the app launches
    if (now.difference(_appStartTime) < _launchGracePeriod) {
      onDismissed();
      if (_interstitialAd == null) {
        preloadInterstitialAd();
      }
      return;
    }

    final isCooldownActive = _lastInterstitialShownAt != null &&
        now.difference(_lastInterstitialShownAt!) < _interstitialCooldown;
    final isTransitionReady = _navigationTransitionCount >= _transitionsPerInterstitial;

    if (!isTransitionReady || isCooldownActive || _interstitialAd == null) {
      onDismissed();
      if (_interstitialAd == null) {
        preloadInterstitialAd();
      }
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;

    bool dismissedHandled = false;
    void safeDismiss() {
      if (!dismissedHandled) {
        dismissedHandled = true;
        onDismissed();
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _lastInterstitialShownAt = DateTime.now();
        _navigationTransitionCount = 0;
        preloadInterstitialAd();
        safeDismiss();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdMob: Interstitial failed to show: ${error.message}');
        ad.dispose();
        preloadInterstitialAd();
        safeDismiss();
      },
    );

    try {
      ad.show();
    } catch (e) {
      debugPrint('AdMob: Error showing interstitial ad: $e');
      preloadInterstitialAd();
      safeDismiss();
    }
  }

  // --- Rewarded Ad for Islamic Wisdom ---

  bool get isRewardedLoaded => _rewardedAd != null;

  /// Shows the Rewarded Ad for the Islamic Wisdom section.
  /// Section is unlocked ONLY if [onUserEarnedReward] is invoked.
  /// If user closes without earning the reward, the section remains locked.
  void showWisdomRewardedAd({
    required BuildContext context,
    required VoidCallback onRewardEarned,
    required VoidCallback onDismissedWithoutReward,
    required void Function(String errorMessage) onAdUnavailable,
  }) {
    if (kIsWeb) {
      // On web environments, unlock directly
      _isWisdomUnlocked = true;
      onRewardEarned();
      return;
    }

    if (_rewardedAd == null) {
      // Attempt on-demand preloading with callback
      if (!_isRewardedLoading) {
        preloadRewardedAd(
          onComplete: (success) {
            if (success && _rewardedAd != null) {
              _presentRewardedAd(
                onRewardEarned: onRewardEarned,
                onDismissedWithoutReward: onDismissedWithoutReward,
                onAdUnavailable: onAdUnavailable,
              );
            } else {
              onAdUnavailable(
                'Xayeysiiska lama heli karo xilligan. Fadlan hubi khadka internet-kaaga oo dib u tijaabi.',
              );
            }
          },
        );
      } else {
        onAdUnavailable(
          'Xayeysiiska ayaa weli la soo dejinayaa, fadlan dib u tijaabi daqiiqad ka dib.',
        );
      }
      return;
    }

    _presentRewardedAd(
      onRewardEarned: onRewardEarned,
      onDismissedWithoutReward: onDismissedWithoutReward,
      onAdUnavailable: onAdUnavailable,
    );
  }

  void _presentRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onDismissedWithoutReward,
    required void Function(String errorMessage) onAdUnavailable,
  }) {
    if (_rewardedAd == null) {
      onAdUnavailable('Xayeysiiska lama heli karo xilligan.');
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;
    bool userEarnedReward = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadRewardedAd();

        if (userEarnedReward) {
          _isWisdomUnlocked = true;
          onRewardEarned();
        } else {
          onDismissedWithoutReward();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdMob: Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        preloadRewardedAd();
        onAdUnavailable(
          'Xayeysiiska wuu furmi waayay (${error.message}). Fadlan dib u tijaabi.',
        );
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (adWithoutView, reward) {
          debugPrint('AdMob: User successfully earned reward: ${reward.type} (${reward.amount})');
          userEarnedReward = true;
        },
      );
    } catch (e) {
      debugPrint('AdMob: Error presenting rewarded ad: $e');
      preloadRewardedAd();
      onAdUnavailable('Khalad ayaa dhacay markii xayeysiiska la furayey.');
    }
  }
}
