import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../data/sample_data.dart';
import '../models/lecture_model.dart';
import '../widgets/arabesque_pattern.dart';
import 'search_screen.dart';
import 'player_screen.dart';
import 'tasbeeh_screen.dart';
import 'ramadan_home_screen.dart';
import 'fatwooyin_screen.dart';
import 'wisdom_screen.dart';
import '../widgets/rub_el_hizb_icon.dart';
import '../widgets/adaptive_banner_widget.dart';
import '../widgets/wisdom_unlock_dialog.dart';
import '../services/ad_service.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTabChange;
  final VoidCallback onOpenDrawer;

  const HomeScreen({
    super.key,
    required this.onTabChange,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);
    final fav = Provider.of<FavoritesProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.92),
            border: Border(bottom: BorderSide(color: borderColor)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, size: 26, color: textColor),
                    tooltip: 'Menu Drawer',
                    onPressed: onOpenDrawer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHEEKH XUSEEN CALI JABUUTI',
                          style: AppTypography.sans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Hoyga',
                          style: AppTypography.serif(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, size: 23, color: textMuted),
                    tooltip: 'Raadi',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const SearchScreen()),
                      );
                    },
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none, size: 23, color: textMuted),
                        tooltip: 'Ogeysiisyada',
                        onPressed: () {
                          _showNotificationsSheet(context, isDark);
                        },
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.tertiaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // 1. Islamic Welcome & Hero Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildHeroCard(context, audio, isDark),
            ),
            const SizedBox(height: 24),

            // 2. Quick Islamic Navigation Carousel
            _buildQuickServices(context, isDark),
            const SizedBox(height: 24),

            // 3. Muxaadarooyinka Qaybaha (Series 1 - 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSeriesSection(context, audio, isDark),
            ),
            const SizedBox(height: 24),

            // 4. Daily Islamic Reminder / Xikmadda Maalinta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildDailyQuoteCard(context, isDark),
            ),
            const SizedBox(height: 24),

            // Dedicated Islamic Wisdom Section (HIKMADO IYO HADALLO QAALI AH)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildWisdomBannerCard(context, isDark),
            ),
            const SizedBox(height: 24),

            // 5. Recently Played Track
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildRecentlyPlayed(context, audio, fav, isDark),
            ),
            const SizedBox(height: 16),

            // 6. Responsive Anchored Adaptive Banner Ad
            AdaptiveBannerWidget(isDark: isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 1. Hero Card
  Widget _buildHeroCard(BuildContext context, AudioPlayerProvider audio, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -20,
            top: -20,
            child: ArabesquePattern(size: 200, opacity: 0.15),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 15, color: AppColors.primaryFixed),
                              const SizedBox(width: 5),
                              Text(
                                'KUSOO DHOWOW',
                                style: AppTypography.sans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryFixed,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكَاتُهُ',
                            style: AppTypography.arabic(
                              fontSize: 18.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              lineHeight: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Maktabadda Muxaadarooyinka, Duruusta iyo Xikmadaha Sheekh Xuseen Cali Jabuuti.',
                            style: AppTypography.sans(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              lineHeight: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryFixed.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/sheikh_hero.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Latest Lecture Sub-card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Muxaadaradii Ugu Dambaysay',
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: AppColors.primaryFixed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              SampleData.heroLecture.somaliTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.serif(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          audio.playLecture(SampleData.heroLecture);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const PlayerScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '45:20',
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Quick Services Carousel
  Widget _buildQuickServices(BuildContext context, bool isDark) {
    final textColor = AppTheme.text(isDark);
    final cardBg = AppTheme.card(isDark);
    final borderColor = AppTheme.border(isDark);

    final services = [
      {
        'name': 'Duruus',
        'icon': Icons.podcasts,
        'bg': isDark ? const Color(0xFF2E2748) : AppColors.primaryFixed,
        'color': isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
        'tab': 1,
      },
      {
        'name': 'Qur\'aan',
        'icon': Icons.menu_book,
        'bg': isDark ? const Color(0xFF282540) : AppColors.secondaryFixed,
        'color': isDark ? const Color(0xFFC4B5FD) : AppColors.secondary,
        'tab': 2,
      },
      {
        'name': 'Adkaar',
        'icon': Icons.spa,
        'bg': isDark ? const Color(0xFF38231E) : AppColors.tertiaryFixed,
        'color': isDark ? const Color(0xFFFFB59D) : AppColors.tertiary,
        'tab': 3,
      },
      {
        'name': 'Tasbiix',
        'icon': Icons.pin,
        'bg': isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHighest,
        'color': isDark ? AppTheme.darkTextSecondary : AppColors.onSurfaceVariant,
        'tab': 3,
      },
      {
        'name': 'Ramadaan',
        'icon': Icons.bedtime,
        'bg': isDark ? const Color(0xFF282540) : AppColors.secondaryFixed,
        'color': isDark ? const Color(0xFFC4B5FD) : AppColors.secondary,
        'tab': 1,
      },
      {
        'name': 'Fatwooyin',
        'icon': Icons.forum,
        'bg': isDark ? AppTheme.darkSecondary : AppColors.surfaceContainer,
        'color': isDark ? AppTheme.darkTextPrimary : AppColors.onSurface,
        'tab': 1,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Adeegyada Degdegga ah',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.serif(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onTabChange(1),
                child: Text(
                  'Dhammaan',
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 94,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final s = services[i];
              return GestureDetector(
                onTap: () {
                  if (s['name'] == 'Tasbiix') {
                    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
                    AdService().showInterstitialAd(
                      isAudioPlaying: audio.isPlaying,
                      onDismissed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TasbeehScreen(),
                          ),
                        );
                      },
                    );
                  } else if (s['name'] == 'Ramadaan') {
                    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
                    AdService().showInterstitialAd(
                      isAudioPlaying: audio.isPlaying,
                      onDismissed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RamadanHomeScreen(),
                          ),
                        );
                      },
                    );
                  } else if (s['name'] == 'Fatwooyin') {
                    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
                    AdService().showInterstitialAd(
                      isAudioPlaying: audio.isPlaying,
                      onDismissed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FatwooyinScreen(),
                          ),
                        );
                      },
                    );
                  } else {
                    onTabChange(s['tab'] as int);
                  }
                },
                child: Container(
                  width: 82,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: s['bg'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          s['icon'] as IconData,
                          color: s['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            s['name'] as String,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: AppTypography.sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Series Cards Section
  Widget _buildSeriesSection(BuildContext context, AudioPlayerProvider audio, bool isDark) {
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final cardBg = AppTheme.card(isDark);
    final borderColor = AppTheme.border(isDark);

    final series = [
      {
        'q': 'Q1',
        'arabic': 'محاضرات الشيخ حسين قسم الاول',
        'somali': 'Muxaadarooyinka Qaybta 1aad',
        'count': '48 Dersi',
        'tag': 'Dhammaystiran',
        'lecture': SampleData.getLectureAt(0),
      },
      {
        'q': 'Q2',
        'arabic': 'محاضرات الشيخ حسين قسم الثاني',
        'somali': 'Muxaadarooyinka Qaybta 2aad',
        'count': '36 Dersi',
        'tag': 'Tafsiir & Fiqhi',
        'lecture': SampleData.getLectureAt(1),
      },
      {
        'q': 'Q3',
        'arabic': 'محاضرات الشيخ حسين قسم الثالث',
        'somali': 'Muxaadarooyinka Qaybta 3aad',
        'count': '52 Dersi',
        'tag': 'Quluubta & Akhlaaqda',
        'lecture': SampleData.getLectureAt(2),
      },
      {
        'q': 'Q4',
        'arabic': 'محاضرات الشيخ حسين قسم الرابع',
        'somali': 'Muxaadarooyinka Qaybta 4aad',
        'count': '40 Dersi',
        'tag': 'Taariikhda Saxaabada',
        'lecture': SampleData.getLectureAt(3),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Muxaadarooyinka Qaybaha',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.serif(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Silsiladaha 1 - 4',
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: series.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final item = series[i];
            final lecture = item['lecture'] as LectureModel;
            return GestureDetector(
              onTap: () {
                onTabChange(1);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/sheikh_series.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? AppTheme.primaryLight : AppColors.primaryContainer).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              item['q'] as String,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['arabic'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.arabic(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              lineHeight: 1.2,
                            ),
                          ),
                          Text(
                            item['somali'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.serif(
                              fontSize: 13,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                item['count'] as String,
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: borderColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['tag'] as String,
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (i == 0)
                              ? (isDark ? AppTheme.darkSecondary : AppColors.primaryFixed)
                              : (isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: (i == 0)
                              ? (isDark ? AppTheme.primaryLight : AppColors.primaryContainer)
                              : textMuted,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        audio.playLecture(lecture);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const PlayerScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 4. Daily Islamic Reminder
  Widget _buildDailyQuoteCard(BuildContext context, bool isDark) {
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final cardBg = isDark ? AppTheme.darkCard : AppColors.surfaceContainerLow;
    final borderColor = AppTheme.border(isDark);
    final btnBg = isDark ? AppTheme.darkSecondary : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, size: 17, color: AppColors.tertiaryContainer),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'AAYADDA & XIKMADDA MAALINTA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiaryContainer,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Suuradda Al-Zumar : 9',
                style: AppTypography.sans(
                  fontSize: 11.5,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ',
            textAlign: TextAlign.center,
            style: AppTypography.arabic(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
              lineHeight: 1.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"Dheh: Ma siman yihiin kuwa wax og iyo kuwa aan waxba ogayn?"',
            textAlign: TextAlign.center,
            style: AppTypography.serif(
              fontSize: 13.5,
              color: textColor,
              lineHeight: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: btnBg,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: Icon(Icons.share, size: 16, color: textColor),
                label: Text(
                  'La Wadaag',
                  style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                ),
                onPressed: () {
                  Share.share(
                    'Aayadda Maalinta: "قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ"\n"Dheh: Ma siman yihiin kuwa wax og iyo kuwa aan waxba ogayn?" - Suuradda Al-Zumar : 9\n\nSheekh Xuseen Cali Jabuuti App',
                  );
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: btnBg,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: Icon(Icons.bookmark_border, size: 16, color: textColor),
                label: Text(
                  'Kaydi',
                  style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aayadda si guul leh ayaa loo kaydiyay!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dedicated Islamic Wisdom Card: HIKMADO IYO HADALLO QAALI AH
  Widget _buildWisdomBannerCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.primary.withOpacity(0.35)
                : AppColors.primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showWisdomUnlockDialog(
                context: context,
                isDark: isDark,
                onUnlocked: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const WisdomScreen()),
                  );
                },
              );
            },
            child: Stack(
              children: [
                // 1. Background Image with Gradient Overlay
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/adhkar_artwork.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // Purple and Deep Overlay according to app theme
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF1E1035).withOpacity(0.92),
                                const Color(0xFF2E1065).withOpacity(0.88),
                                const Color(0xFF170928).withOpacity(0.94),
                              ]
                            : [
                                const Color(0xFF381E72).withOpacity(0.92),
                                const Color(0xFF4F2B99).withOpacity(0.88),
                                const Color(0xFF21005D).withOpacity(0.94),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // 2. Arabesque Decorative Pattern
                Positioned(
                  right: -25,
                  bottom: -25,
                  child: ArabesquePattern(
                    size: 160,
                    opacity: 0.18,
                    color: Colors.white,
                  ),
                ),
                // 3. Card Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const RubElHizbIcon(size: 12, color: Color(0xFFFFD54F)),
                                const SizedBox(width: 6),
                                Text(
                                  'HIKMADO IYO HADALLO QAALI AH',
                                  style: AppTypography.sans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFD54F),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Title & Subtitle
                      Text(
                        'Islamic Wisdom & Sayings',
                        style: AppTypography.serif(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'حِكَمٌ وَأَقْوَالٌ إِسْلَامِيَّةٌ خَالِدَةٌ',
                        style: AppTypography.arabic(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hadallo dhaxal-gal ah oo laga soo xigtay Nebiga ﷺ, Saxaabada (RA) iyo Culimadii waaweyneyd ee Islaamka.',
                        style: AppTypography.sans(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.85),
                          lineHeight: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Quick feature pills
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildWisdomPill(Icons.auto_stories, '8 Qaybood'),
                          _buildWisdomPill(Icons.verified, 'Xigasho Sugan'),
                          _buildWisdomPill(Icons.wb_sunny_rounded, 'Hikmadda Maanta'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWisdomPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.sans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Recently Played
  Widget _buildRecentlyPlayed(
    BuildContext context,
    AudioPlayerProvider audio,
    FavoritesProvider fav,
    bool isDark,
  ) {
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final cardBg = AppTheme.card(isDark);
    final borderColor = AppTheme.border(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Kuwii Ugu Dambeeyay ee la Dhageystay',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.serif(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                fav.clearRecentlyPlayed();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Taariikhda dhageysiga waa la tirtiray.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Tirtir Taariikhda',
                style: AppTypography.sans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSecondary : AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_edu,
                  color: isDark ? AppTheme.primaryLight : AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taariikhda Saxaabada: Abuu Bakar (RC)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.serif(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'الصحابة الكرام',
                          style: AppTypography.arabic(
                            fontSize: 12,
                            color: textMuted,
                            lineHeight: 1.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: borderColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '32 daqiiqo ayaa kuu dhiman',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: textColor,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  audio.playLecture(SampleData.getLectureAt(0));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const PlayerScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context, bool isDark) {
    final sheetBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ogeysiisyada (Notifications)',
                  style: AppTypography.serif(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.mic, color: isDark ? AppTheme.primaryLight : AppColors.primaryContainer),
              title: Text('Muxaadaro Cusub ayaa soo dhacday', style: AppTypography.sans(fontWeight: FontWeight.w600, color: textColor)),
              subtitle: Text('Wanaagga Waalidiinta & Barbaarinta - Dhageyso hadda.', style: AppTypography.sans(fontSize: 12, color: textMuted)),
            ),
            ListTile(
              leading: const Icon(Icons.wb_twilight, color: AppColors.tertiaryContainer),
              title: Text('Xusuusinta Adkaarta Galabta', style: AppTypography.sans(fontWeight: FontWeight.w600, color: textColor)),
              subtitle: Text('Waqtiga adkaarta galabta ayaa la gaaray, xus Eebbe.', style: AppTypography.sans(fontSize: 12, color: textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
