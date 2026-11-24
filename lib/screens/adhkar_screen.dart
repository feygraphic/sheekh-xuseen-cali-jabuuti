import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/adhkar_category_model.dart';
import '../providers/adhkar_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ad_service.dart';
import '../widgets/adaptive_banner_widget.dart';
import '../data/sample_data.dart';
import 'adhkar_category_screen.dart';
import 'search_screen.dart';
import 'tasbeeh_screen.dart';

class AdhkarScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback? onBack;

  const AdhkarScreen({
    super.key,
    required this.onOpenDrawer,
    this.onBack,
  });

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  final TextEditingController _categorySearchController = TextEditingController();
  String _categorySearchQuery = '';

  @override
  void dispose() {
    _categorySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adhkarProv = Provider.of<AdhkarProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    // Filter categories based on search input
    final allCategories = adhkarProv.categories;
    final filteredCategories = _categorySearchQuery.trim().isEmpty
        ? allCategories
        : allCategories.where((c) {
            final q = _categorySearchQuery.trim().toLowerCase();
            return c.somaliTitle.toLowerCase().contains(q) ||
                c.arabicTitle.contains(q) ||
                c.englishTitle.toLowerCase().contains(q) ||
                c.description.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      widget.onBack != null ? Icons.arrow_back_rounded : Icons.menu_rounded,
                      size: 24,
                      color: textColor,
                    ),
                    tooltip: widget.onBack != null ? 'Dib u noqo' : 'Menu',
                    onPressed: widget.onBack ?? widget.onOpenDrawer,
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
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qaybaha Adkaarta',
                          style: AppTypography.serif(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.touch_app_rounded, size: 23, color: textMuted),
                    tooltip: 'Misbaxada Tasbiixda',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const TasbeehScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.search_rounded, size: 23, color: textMuted),
                    tooltip: 'Raadi Adkaar',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const SearchScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_none_rounded, size: 23, color: textMuted),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Time-Context Recommendation & Overall Progress Banner
            _buildContextRecommendationBanner(context, adhkarProv, isDark),
            const SizedBox(height: 14),

            // 2. Audio Commentary Card by Sheikh Xuseen
            _buildAudioCommentaryCard(context, audio, isDark),
            const SizedBox(height: 18),

            // 4. Category Search Filter
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _categorySearchController,
                onChanged: (val) {
                  setState(() {
                    _categorySearchQuery = val;
                  });
                },
                style: AppTypography.sans(fontSize: 13, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Ka raadi qaybaha adkaarta (Tusaale: Subax, Ruqyah, Suuqa)...',
                  hintStyle: AppTypography.sans(fontSize: 12.5, color: textMuted),
                  prefixIcon: Icon(Icons.search_rounded, size: 19, color: textMuted),
                  suffixIcon: _categorySearchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 16, color: textMuted),
                          onPressed: () {
                            _categorySearchController.clear();
                            setState(() {
                              _categorySearchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. Section Title & Total Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dhammaan Qaybaha (${filteredCategories.length})',
                      style: AppTypography.serif(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBadgeBg : AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${adhkarProv.totalCount} Duco',
                    style: AppTypography.sans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkBadgeText : AppColors.onPrimaryFixed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 6. Categories 2-Column Grid (Requirement 1: 13 Beautiful Category Cards)
            if (filteredCategories.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'Wax qayb ah lagama helin "$_categorySearchQuery".',
                  style: AppTypography.sans(fontSize: 13, color: textMuted),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (ctx, i) {
                  final cat = filteredCategories[i];
                  return _buildCategoryCard(context, cat, adhkarProv, isDark);
                },
              ),
            const SizedBox(height: 16),
            AdaptiveBannerWidget(isDark: isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Time-of-Day Context Banner
  Widget _buildContextRecommendationBanner(
    BuildContext context,
    AdhkarProvider adhkarProv,
    bool isDark,
  ) {
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    final hour = DateTime.now().hour;
    String periodTitle;
    String periodSubtitle;
    String targetCatId;
    IconData periodIcon;

    if (hour >= 4 && hour < 12) {
      periodTitle = 'Waqtiga: Adkaar Subax (Fajr - Duhur)';
      periodSubtitle = 'Ka bilow maalintaada xusidda Eebbe iyo barakada subaxda';
      targetCatId = 'morning';
      periodIcon = Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 20) {
      periodTitle = 'Waqtiga: Adkaar Galab (Casir - Cishaa)';
      periodSubtitle = 'Dhowrsoonida nafta iyo xusidda Eebbe xilliga gabbalka';
      targetCatId = 'evening';
      periodIcon = Icons.wb_twilight_rounded;
    } else {
      periodTitle = 'Waqtiga: Hurdada & Tooska';
      periodSubtitle = 'Ilaalinta hurdada iyo aayadda Kursiga intaadan seexan';
      targetCatId = 'sleeping';
      periodIcon = Icons.bedtime_rounded;
    }

    final targetCat = adhkarProv.getCategoryById(targetCatId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF281C3D), const Color(0xFF1B132B)]
              : [const Color(0xFFF4EEFF), const Color(0xFFEFE6FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(periodIcon, size: 18, color: const Color(0xFFE28945)),
                  const SizedBox(width: 6),
                  Text(
                    periodTitle,
                    style: AppTypography.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE28945),
                    ),
                  ),
                ],
              ),
              if (targetCat != null)
                GestureDetector(
                  onTap: () {
                    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
                    AdService().showInterstitialAd(
                      isAudioPlaying: audio.isPlaying,
                      onDismissed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AdhkarCategoryScreen(category: targetCat),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Fur Hadda',
                          style: AppTypography.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            periodSubtitle,
            style: AppTypography.sans(fontSize: 12.5, color: textMuted),
          ),
          const SizedBox(height: 12),

          // Total Daily Completed Adhkar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wadarta la akhriyey maanta:',
                style: AppTypography.sans(fontSize: 12, color: textColor),
              ),
              Text(
                adhkarProv.overallProgressText,
                style: AppTypography.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 5,
              color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHighest,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: adhkarProv.overallProgress,
                child: Container(color: accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Audio Commentary Card by Sheikh Xuseen
  Widget _buildAudioCommentaryCard(
    BuildContext context,
    AudioPlayerProvider audio,
    bool isDark,
  ) {
    final cardBg = isDark ? AppTheme.darkCard : AppColors.surfaceContainerHigh;
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final innerRowBg = isDark ? AppTheme.darkSecondary : Colors.white;
    final accentColor = AppTheme.accent(isDark);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/sheikh_adkaar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, size: 12, color: Colors.white),
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
                      'CODKA SHEEKHA',
                      style: AppTypography.sans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Dhagayso Codka Sheekh Xuseen',
                      style: AppTypography.serif(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Sharaxaadda Adkaarta & Ilaalinta Nafsiga',
                      style: AppTypography.sans(fontSize: 11.5, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: innerRowBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    audio.playLecture(SampleData.lectures.first);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Darsi Buuxa oo MP3 ah',
                        style: AppTypography.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Sharax qoto-dheer oo cod ah',
                        style: AppTypography.sans(fontSize: 10.5, color: textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBadgeBg : AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.graphic_eq_rounded, size: 14, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        'MP3 Cod',
                        style: AppTypography.sans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
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

  // Category Card - 2-Column Grid Item (Requirement 1 & 3)
  Widget _buildCategoryCard(
    BuildContext context,
    AdhkarCategoryModel cat,
    AdhkarProvider adhkarProv,
    bool isDark,
  ) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    final duas = adhkarProv.getDuasForCategory(cat.id);
    final completedCount = duas.where((d) => d.isCompleted).length;
    final totalCount = duas.isNotEmpty ? duas.length : cat.duaCount;
    final progress = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return InkWell(
      onTap: () {
        final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
        AdService().showInterstitialAd(
          isAudioPlaying: audio.isPlaying,
          onDismissed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => AdhkarCategoryScreen(category: cat),
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Category Icon & Dua Count Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF6B38B0), const Color(0xFF431985)]
                          : [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(cat.iconData, color: Colors.white, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$totalCount Duco',
                    style: AppTypography.sans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textMuted,
                    ),
                  ),
                ),
              ],
            ),

            // Middle: Somali Title, Arabic Title & Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.somaliTitle,
                  style: AppTypography.serif(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    lineHeight: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    cat.arabicTitle,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.arabic(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      lineHeight: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cat.description,
                  style: AppTypography.sans(
                    fontSize: 10.8,
                    color: textMuted,
                    lineHeight: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Bottom: Completion Status & Mini Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        completedCount == totalCount && totalCount > 0
                            ? 'Waa la dhammaystiray'
                            : '$completedCount / $totalCount la akhriyey',
                        style: AppTypography.sans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: completedCount == totalCount && totalCount > 0
                              ? Colors.green
                              : accentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    height: 3.5,
                    color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHighest,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        color: completedCount == totalCount && totalCount > 0
                            ? Colors.green
                            : accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
