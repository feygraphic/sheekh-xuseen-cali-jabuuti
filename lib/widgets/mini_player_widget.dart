import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    if (!audio.isMiniPlayerVisible) {
      return const SizedBox.shrink();
    }

    final cardBg = isDark ? AppTheme.darkCard : Colors.white.withOpacity(0.96);
    final borderColor = isDark ? AppTheme.darkBorder : AppColors.outlineVariant.withOpacity(0.35);
    final textColor = isDark ? AppTheme.darkTextPrimary : AppColors.onSurface;
    final textMuted = isDark ? AppTheme.darkTextSecondary : AppColors.onSurfaceVariant;
    final trackBg = isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const PlayerScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.4) : AppColors.primary.withOpacity(0.14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  height: 3.5,
                  width: double.infinity,
                  color: trackBg,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: audio.progressFraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Content Row
              Row(
                children: [
                  // Album Art with EQ Badge
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 4,
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.primaryContainer.withOpacity(0.2),
                          ),
                          image: DecorationImage(
                            image: AssetImage(audio.currentImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(
                            Icons.graphic_eq,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Title and Arabic Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          audio.currentTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          audio.currentSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.arabic(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: textMuted,
                            lineHeight: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  // Replay 10s
                  IconButton(
                    iconSize: 22,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.replay_10, color: textMuted),
                    tooltip: 'Dib ugu noqo 10s',
                    onPressed: () {
                      audio.skipBackward(10);
                    },
                  ),
                  const SizedBox(width: 4),

                  // Play / Pause Circle Button
                  GestureDetector(
                    onTap: () {
                      audio.togglePlayPause();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppTheme.primaryLight : AppColors.primaryContainer).withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: audio.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              audio.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Close Mini-Player
                  IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close, color: textMuted),
                    tooltip: 'Xidh codka yar',
                    onPressed: () {
                      audio.hideMiniPlayer();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
