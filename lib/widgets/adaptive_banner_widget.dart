import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../services/ad_service.dart';

/// Anchored Adaptive Banner Widget for Sheikh Xuseen Cali Jabuuti Application.
///
/// Features:
/// - Computes anchored adaptive banner size matching the device's width.
/// - Clear, subtle AdMob-compliant attribution ("XAYEEYSIIS • ADVERTISEMENT") so users
///   are never confused between app content and advertisements.
/// - Safe lifecycle handling: avoids duplicate loads and disposes native ad resources properly.
/// - Prevents layout flickering by rendering SizedBox.shrink() until ad is verified loaded.
/// - Beautiful themed container matching light and dark modes.
class AdaptiveBannerWidget extends StatefulWidget {
  final bool isDark;
  final EdgeInsetsGeometry? margin;

  const AdaptiveBannerWidget({
    super.key,
    required this.isDark,
    this.margin,
  });

  @override
  State<AdaptiveBannerWidget> createState() => _AdaptiveBannerWidgetState();
}

class _AdaptiveBannerWidgetState extends State<AdaptiveBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) return;
    if (!_isLoaded && !_isLoading) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    if (kIsWeb || _bannerAd != null || _isLoading) return;
    _isLoading = true;

    try {
      final screenWidth = MediaQuery.sizeOf(context).width.truncate();
      final adWidth = (screenWidth - 32).clamp(300, 728);

      final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth) ??
          AdSize.banner;

      if (!mounted) {
        _isLoading = false;
        return;
      }

      final banner = BannerAd(
        adUnitId: AdService.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoaded = true;
              _isLoading = false;
              _adSize = size;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdMob: Adaptive banner failed to load: ${error.message} (code: ${error.code})');
            ad.dispose();
            if (mounted) {
              setState(() {
                _isLoaded = false;
                _isLoading = false;
                _bannerAd = null;
              });
            }
          },
        ),
      );

      await banner.load();
    } catch (e) {
      debugPrint('AdMob: Error loading adaptive banner: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_isLoaded || _bannerAd == null || _adSize == null) {
      return const SizedBox.shrink();
    }

    final cardBg = AppTheme.card(widget.isDark);
    final borderColor = AppTheme.border(widget.isDark);
    final textSub = AppTheme.textSub(widget.isDark);

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ad Attribution Label (Google AdMob Policy Compliant)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded, size: 10, color: textSub.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  'XAYEEYSIIS • ADVERTISEMENT',
                  style: AppTypography.sans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: textSub.withOpacity(0.7),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _adSize!.width.toDouble(),
            height: _adSize!.height.toDouble(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ],
      ),
    );
  }
}
