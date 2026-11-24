import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../services/ad_service.dart';
import 'rub_el_hizb_icon.dart';

/// Shows the Islamic Wisdom Unlock Dialog.
/// If already unlocked for this session, invokes [onUnlocked] immediately.
/// Otherwise, presents an explanation dialog requiring the user to watch
/// a Rewarded Video Advertisement to gain access.
void showWisdomUnlockDialog({
  required BuildContext context,
  required bool isDark,
  required VoidCallback onUnlocked,
}) {
  final adService = AdService();

  // If already unlocked in this session, navigate directly
  if (adService.isWisdomUnlocked) {
    onUnlocked();
    return;
  }

  final cardBg = AppTheme.card(isDark);
  final textColor = AppTheme.text(isDark);
  final textSub = AppTheme.textSub(isDark);
  final borderColor = AppTheme.border(isDark);
  final accentColor = AppTheme.accent(isDark);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Islamic Arch Badge Icon
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF6B38B0), const Color(0xFF431985)]
                      : [AppColors.primary, AppColors.primaryDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: RubElHizbIcon(
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Arabic Header
            Text(
              'حِكَمٌ وَمَوَاعِظُ إِسْلَامِيَّة',
              textAlign: TextAlign.center,
              style: AppTypography.arabic(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),

            // Somali Title
            Text(
              'Furitaanka Xikmadaha',
              textAlign: TextAlign.center,
              style: AppTypography.serif(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Explanatory Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF231938) : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Text(
                    'Si aad u hesho xikmadaha iyo hadallada qiimaha badan ee culimada, fadlan daawo xayeysiis kooban si aad qaybtan u furto.',
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      fontSize: 13,
                      color: textSub,
                      lineHeight: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Wuxuu furnaanayaa fadhigan oo dhan',
                        style: AppTypography.sans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Ka Noqo',
              style: AppTypography.sans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textSub,
              ),
            ),
          ),

          // Watch Ad Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
            label: Text(
              'Daawo Xayeysiiska',
              style: AppTypography.sans(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleWatchRewardedAd(
                context: context,
                isDark: isDark,
                onUnlocked: onUnlocked,
              );
            },
          ),
        ],
      );
    },
  );
}

void _handleWatchRewardedAd({
  required BuildContext context,
  required bool isDark,
  required VoidCallback onUnlocked,
}) {
  final adService = AdService();

  adService.showWisdomRewardedAd(
    context: context,
    onRewardEarned: () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: const [
                Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Qaybta Xikmadaha si guul leh ayaa laguu furay!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
        onUnlocked();
      }
    },
    onDismissedWithoutReward: () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ma aadan dhammaystirin daawashada xayeysiiska; qaybta xikmaduhu wali way xiran tahay.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    },
    onAdUnavailable: (errorMessage) {
      if (context.mounted) {
        _showAdUnavailableDialog(
          context: context,
          isDark: isDark,
          errorMessage: errorMessage,
          onRetry: () {
            _handleWatchRewardedAd(
              context: context,
              isDark: isDark,
              onUnlocked: onUnlocked,
            );
          },
        );
      }
    },
  );
}

void _showAdUnavailableDialog({
  required BuildContext context,
  required bool isDark,
  required String errorMessage,
  required VoidCallback onRetry,
}) {
  final cardBg = AppTheme.card(isDark);
  final textColor = AppTheme.text(isDark);
  final textSub = AppTheme.textSub(isDark);
  final borderColor = AppTheme.border(isDark);
  final accentColor = AppTheme.accent(isDark);

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
        title: Row(
          children: [
            Icon(Icons.signal_wifi_connected_no_internet_4_rounded, color: accentColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'Xayeysiiska Lama Heli Karo',
              style: AppTypography.serif(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Text(
          errorMessage,
          style: AppTypography.sans(fontSize: 13, color: textSub, lineHeight: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Ka Noqo',
              style: AppTypography.sans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSub,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Isku Day Mar Kale',
              style: AppTypography.sans(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onRetry();
            },
          ),
        ],
      );
    },
  );
}
