import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/adkhar_model.dart';
import '../models/adhkar_category_model.dart';
import '../providers/adhkar_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import 'dua_reading_screen.dart';

class AdhkarCategoryScreen extends StatefulWidget {
  final AdhkarCategoryModel category;

  const AdhkarCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<AdhkarCategoryScreen> createState() => _AdhkarCategoryScreenState();
}

class _AdhkarCategoryScreenState extends State<AdhkarCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final adhkarProv = Provider.of<AdhkarProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context);
    final fav = Provider.of<FavoritesProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    final cat = widget.category;
    final allCategoryDuas = adhkarProv.getDuasForCategory(cat.id);
    final filteredDuas = adhkarProv.getFilteredDuasForCategory(cat.id, _searchQuery);

    final completedCount = allCategoryDuas.where((d) => d.isCompleted).length;
    final progress = allCategoryDuas.isNotEmpty
        ? (completedCount / allCategoryDuas.length).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          cat.somaliTitle,
          style: AppTypography.serif(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBadgeBg : AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              cat.arabicTitle,
              style: AppTypography.arabic(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkBadgeText : AppColors.onPrimaryFixed,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Header Banner
            _buildHeroBanner(context, cat, allCategoryDuas.length, completedCount, progress, isDark),
            const SizedBox(height: 16),

            // 2. Specialized Category Feature Banners
            if (cat.id == 'ruqyah') ...[
              _buildRuqyahDedicatedPlayer(context, allCategoryDuas, audio, isDark),
              const SizedBox(height: 16),
            ] else if (cat.id == 'market') ...[
              _buildMarketSpecialBanner(context, isDark),
              const SizedBox(height: 16),
            ] else if (cat.id == 'after_salah') ...[
              _buildAfterSalahGuideBanner(context, isDark),
              const SizedBox(height: 16),
            ],

            // 3. Search Bar within this Category (Requirement 2)
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: AppTypography.sans(fontSize: 13.5, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Ka raadi ${cat.somaliTitle}...',
                  hintStyle: AppTypography.sans(fontSize: 13, color: textMuted),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18, color: textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 4. Section Subtitle & Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ducooyinka Qaybta (${filteredDuas.length})',
                  style: AppTypography.serif(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Riix si aad u akhriso',
                  style: AppTypography.sans(
                    fontSize: 11.5,
                    color: textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5. Duas List
            if (filteredDuas.isEmpty)
              _buildEmptySearchState(context, cardBg, borderColor, textMuted)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredDuas.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final item = filteredDuas[i];
                  return _buildDuaCard(
                    context,
                    item,
                    i + 1,
                    allCategoryDuas,
                    adhkarProv,
                    audio,
                    fav,
                    isDark,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    AdhkarCategoryModel cat,
    int totalCount,
    int completedCount,
    double progress,
    bool isDark,
  ) {
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2A1A44), const Color(0xFF1B142B)]
              : [const Color(0xFFF4EEFF), const Color(0xFFEDE3FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF7A45C8), const Color(0xFF4A1BC4)]
                        : [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cat.iconData, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cat.somaliTitle,
                            style: AppTypography.serif(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.arabicTitle,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.arabic(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat.description,
                      style: AppTypography.sans(fontSize: 12, color: textMuted, lineHeight: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.task_alt_rounded, size: 16, color: accentColor),
                  const SizedBox(width: 5),
                  Text(
                    'Akhriska Qaybta',
                    style: AppTypography.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                '$completedCount / $totalCount Dhammaystiran',
                style: AppTypography.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 6,
              color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHighest,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: completedCount == totalCount && totalCount > 0
                        ? Colors.green
                        : accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dedicated Ruqyah Audio Player (Requirement 6)
  Widget _buildRuqyahDedicatedPlayer(
    BuildContext context,
    List<AdkharModel> ruqyahDuas,
    AudioPlayerProvider audio,
    bool isDark,
  ) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    final isRuqyahActive = audio.currentAdhkar != null &&
        ruqyahDuas.any((d) => d.id == audio.currentAdhkar!.id);

    final isPlaying = isRuqyahActive && audio.isPlaying;
    final currentPlayingTitle = isRuqyahActive && audio.currentAdhkar != null
        ? audio.currentAdhkar!.title
        : 'Dhagayso Ruqyah Shariah oo Buuxda';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying ? accentColor : borderColor,
          width: isPlaying ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8C389E), Color(0xFF5B1C6D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COD DEDICATED AH • RUQYAH SHARIAH',
                      style: AppTypography.sans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      currentPlayingTitle,
                      style: AppTypography.serif(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Akhrinta Aayadaha & Ducooyinka Nabawiga ah',
                      style: AppTypography.sans(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              // Repeat button
              IconButton(
                icon: Icon(
                  Icons.repeat_rounded,
                  size: 20,
                  color: audio.isRepeat ? accentColor : textMuted,
                ),
                tooltip: 'Ku celi',
                onPressed: () => audio.toggleRepeat(),
              ),
              // Speed
              GestureDetector(
                onTap: () => audio.toggleSpeed(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${audio.playbackSpeed}x',
                    style: AppTypography.sans(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Audio Slider
          if (isRuqyahActive) ...[
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                activeTrackColor: accentColor,
                inactiveTrackColor: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHighest,
                thumbColor: accentColor,
              ),
              child: Slider(
                value: audio.duration.inMilliseconds > 0
                    ? (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0)
                    : 0.0,
                onChanged: (val) {
                  if (audio.duration > Duration.zero) {
                    final target = Duration(milliseconds: (val * audio.duration.inMilliseconds).toInt());
                    audio.seekTo(target);
                  }
                },
              ),
            ),
          ],

          // Controls Row: Previous, Play/Pause, Next
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous_rounded, size: 28, color: textColor),
                tooltip: 'Aayaddii hore',
                onPressed: () => audio.playPreviousAdhkar(),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  if (isRuqyahActive) {
                    audio.togglePlayPause();
                  } else if (ruqyahDuas.isNotEmpty) {
                    audio.playAdhkar(ruqyahDuas.first, playlist: ruqyahDuas);
                  }
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF7A45C8), const Color(0xFF4A1BC4)]
                          : [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                icon: Icon(Icons.skip_next_rounded, size: 28, color: textColor),
                tooltip: 'Aayadda xigta',
                onPressed: () => audio.playNextAdhkar(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Market Dua Special Banner (Requirement 5)
  Widget _buildMarketSpecialBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B1F14) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.military_tech_rounded, color: Color(0xFFD97706), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fadliga Weyn: 1,000,000 Xasanaad',
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rasuulku (scw) wuxuu yiri: Qofkii suuqa gala oo akhriya ducadan: Eebbe wuxuu u qoraa hal milyan oo xasano, wuxuuna ka tirtiraa hal milyan oo dambi, waxaana looga dhisaa guri Jannada dhexdeeda ah.',
                  style: AppTypography.sans(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF78350F),
                    lineHeight: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Xigasho: Jaami\' At-Tirmadi (3428) • Saxiixul Jaamic (6231)',
                  style: AppTypography.sans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // After Salah Guide Banner (Requirement 4)
  Widget _buildAfterSalahGuideBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2332) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taxanaha Adkaarta Salaadda Kadib',
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ku bilow Istiqfaar 3 jeer, ducooyinka tawxiidka, Tasbiixda (33), Taxmiidda (33), Takbiirta (33), iyo Aayadul Kursi.',
                  style: AppTypography.sans(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(
    BuildContext context,
    Color cardBg,
    Color borderColor,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: textMuted),
          const SizedBox(height: 8),
          Text(
            'Wax duco ah lagama helin raadintaada "$_searchQuery".',
            style: AppTypography.sans(fontSize: 13, color: textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(
    BuildContext context,
    AdkharModel item,
    int index,
    List<AdkharModel> allDuas,
    AdhkarProvider adhkarProv,
    AudioPlayerProvider audio,
    FavoritesProvider fav,
    bool isDark,
  ) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);
    final arabicBg = isDark ? const Color(0xFF1F1A2A) : const Color(0xFFF9F5FF);

    final isBookmarked = fav.isAdhkarBookmarked(item.id);
    final isPlaying = audio.isAdhkarPlaying(item.id);

    return GestureDetector(
      onTap: () {
        final originalIdx = allDuas.indexWhere((d) => d.id == item.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => DuaReadingScreen(
              initialDua: item,
              categoryDuas: allDuas,
              initialIndex: originalIdx != -1 ? originalIdx : 0,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPlaying ? accentColor : borderColor,
            width: isPlaying ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Number, Reference, Audio & Bookmark Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBadgeBg : AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$index',
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkBadgeText : AppColors.onPrimaryFixed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.isCompleted
                            ? Colors.green.withOpacity(0.15)
                            : (isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.isCompleted ? Icons.check_circle_rounded : Icons.repeat_rounded,
                            size: 13,
                            color: item.isCompleted ? Colors.green : textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isCompleted ? 'Dhammaystiran' : '${item.targetCount} Jeer',
                            style: AppTypography.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.isCompleted ? Colors.green : textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.volume_up_rounded,
                        color: isPlaying ? accentColor : textMuted,
                      ),
                      tooltip: isPlaying ? 'Hakki codka' : 'Dhagayso',
                      onPressed: () {
                        audio.playAdhkar(item, playlist: allDuas);
                      },
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? const Color(0xFFE28945) : textMuted,
                      ),
                      tooltip: 'Calaamadee',
                      onPressed: () {
                        fav.toggleAdhkarBookmark(item.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTypography.serif(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textMuted),
              ],
            ),
            const SizedBox(height: 8),

            // Arabic text snippet
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: arabicBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                item.arabicText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.arabic(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  lineHeight: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Somali snippet
            Text(
              item.somaliTranslation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sans(
                fontSize: 12.5,
                color: textMuted,
                lineHeight: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
