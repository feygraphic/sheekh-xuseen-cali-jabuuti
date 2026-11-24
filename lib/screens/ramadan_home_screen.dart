import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../data/ramadan_data.dart';
import '../models/ramadan_lecture.dart';
import '../providers/settings_provider.dart';
import '../providers/audio_player_provider.dart';
import '../services/ad_service.dart';
import '../widgets/adaptive_banner_widget.dart';
import 'ramadan_lectures_screen.dart';

class RamadanHomeScreen extends StatelessWidget {
  const RamadanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textSub = AppTheme.textSub(isDark);
    final accentColor = isDark ? AppTheme.primaryLight : AppColors.primary;
    final borderColor = AppTheme.border(isDark);

    final scholars = RamadanData.scholars;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.icon(isDark)),
          tooltip: 'Dib u noqo',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bisha Ramadaan',
              style: AppTypography.sans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'شهر رمضان المبارك',
              style: AppTypography.arabic(
                fontSize: 12,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ramadan Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: AppColors.heroGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.nights_stay, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KUSOO DHOWOW RAMADAAN',
                          style: AppTypography.sans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Duruusta & Muxaadarooyinka\nBisha Ramadaan',
                      style: AppTypography.sans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        lineHeight: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'شهر رمضان الذي أنزل فيه القرآن',
                      style: AppTypography.arabic(
                        fontSize: 15,
                        color: const Color(0xFFE6DEFF),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Text(
                        '● 75 Muxaadaro oo Muuqaal ah • 5 Mashaa\'iikh',
                        style: AppTypography.sans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Scholars Section Header
              Text(
                'Mashaa\'iikhda Ramadaanka',
                style: AppTypography.sans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dooro sheekha aad dooneyso inaad ka daawato muxaadarooyinka',
                style: AppTypography.sans(
                  fontSize: 12.5,
                  color: textSub,
                ),
              ),

              const SizedBox(height: 14),

              // 3. Five Scholar Cards in 2-Column Grid View
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: scholars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (ctx, idx) {
                  final scholar = scholars[idx];
                  return _buildScholarCard(
                    context: context,
                    scholar: scholar,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    textSub: textSub,
                    accentColor: accentColor,
                  );
                },
              ),
              const SizedBox(height: 16),
              AdaptiveBannerWidget(isDark: isDark),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScholarCard({
    required BuildContext context,
    required RamadanScholar scholar,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textSub,
    required Color accentColor,
  }) {
    final lectures = RamadanData.getLecturesByScholar(scholar.id);

    return InkWell(
      onTap: () {
        final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
        AdService().showInterstitialAd(
          isAudioPlaying: audio.isPlaying,
          onDismissed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => RamadanLecturesScreen(scholar: scholar),
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Section: Avatar + Names
            Column(
              children: [
                // Scholar Avatar / Monogram with Islamic ring
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: scholar.imageAsset != null
                      ? ClipOval(
                          child: Image.asset(
                            scholar.imageAsset!,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        )
                      : _buildScholarMonogram(scholar, accentColor),
                ),
                const SizedBox(height: 9),

                // Scholar Name
                Text(
                  scholar.name,
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    lineHeight: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Arabic Title
                Text(
                  scholar.arabicTitle,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.arabic(
                    fontSize: 12,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Bottom Badges Section
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lectures.length} Muxaadaro',
                    style: AppTypography.sans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000).withOpacity(0.09),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_fill, size: 11, color: Color(0xFFE50914)),
                      const SizedBox(width: 4),
                      Text(
                        'YouTube In-App',
                        style: AppTypography.sans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE50914),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarMonogram(RamadanScholar scholar, Color accent) {
    final parts = scholar.name.split(' ');
    String initials = 'SX';
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}';
    }
    return Text(
      initials,
      style: AppTypography.sans(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: accent,
      ),
    );
  }
}
