import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../models/surah_model.dart';
import '../widgets/arabesque_pattern.dart';
import '../data/quran_data.dart';
import 'quran_reading_screen.dart';
import 'player_screen.dart';
import 'search_screen.dart';
import '../widgets/reciter_selection_sheet.dart';

class QuranScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback? onBack;

  const QuranScreen({
    super.key,
    required this.onOpenDrawer,
    this.onBack,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _selectedTab = 'Suuradaha';
  String _searchQuery = '';
  bool _sortAscending = true;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = [
    'Suuradaha (114)',
    'Ajzada (30 Juz)',
    'Tafsiirka Sheekha',
    'Aayadaha La Doortay',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SurahModel> _getFilteredSurahs() {
    List<SurahModel> list = List.from(QuranData.allSurahs);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) {
        return s.somaliName.toLowerCase().contains(q) ||
            s.arabicName.contains(q) ||
            s.number.toString() == q;
      }).toList();
    }

    if (_selectedTab == 'Aayadaha La Doortay') {
      final fav = Provider.of<FavoritesProvider>(context, listen: false);
      list = list.where((s) => s.tag != null || fav.isSurahBookmarked(s.number)).toList();
    } else if (_selectedTab.startsWith('Tafsiirka')) {
      list = list.where((s) => s.audioUrl.isNotEmpty).toList();
    }

    if (_sortAscending) {
      list.sort((a, b) => a.number.compareTo(b.number));
    } else {
      list.sort((a, b) => b.number.compareTo(a.number));
    }

    return list;
  }

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

    final surahs = _getFilteredSurahs();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.92),
            border: Border(
              bottom: BorderSide(
                color: borderColor,
              ),
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
                      widget.onBack != null ? Icons.arrow_back_rounded : Icons.menu,
                      size: 24,
                      color: textColor,
                    ),
                    tooltip: widget.onBack != null ? 'Dib u noqo' : 'Menu Drawer',
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
                            color: isDark ? AppTheme.primaryLight : QuranTheme.primary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qur\'aanka Kariimka',
                          style: AppTypography.serif(
                            fontSize: 18,
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
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.tertiary,
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
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),

            // 1. Continue Reading & Audio Tafsiir Hero Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildHeroCard(context, audio, fav, isDark),
            ),
            const SizedBox(height: 16),

            // 2. Segmented Navigation Filters
            _buildNavigationFilters(isDark),
            const SizedBox(height: 14),

            // 3. Search & Quick Utilities Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSearchBar(context, isDark),
            ),
            const SizedBox(height: 12),

            // 3.5. Reciter Selector Strip (MP3Quran API)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildReciterSelectorStrip(context, audio, isDark),
            ),
            const SizedBox(height: 14),

            // 4. Surahs List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Liiska Suuradaha',
                        style: AppTypography.serif(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkBadgeBg : QuranTheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          '114',
                          style: AppTypography.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkBadgeText : QuranTheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          _sortAscending ? 'Kala Saar (1-114)' : 'Kala Saar (114-1)',
                          style: AppTypography.sans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.primaryLight : QuranTheme.primary,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, size: 18, color: isDark ? AppTheme.primaryLight : QuranTheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 5. Surah Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: surahs.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final surah = surahs[i];
                  final isLastRead = surah.number == fav.lastReadSurah;
                  return _buildSurahCard(context, surah, audio, fav, isLastRead, isDark);
                },
              ),
            ),
            const SizedBox(height: 24),

            // 6. Featured Hadith Knowledge Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildHadithVirtueCard(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Hero Card
  Widget _buildHeroCard(
    BuildContext context,
    AudioPlayerProvider audio,
    FavoritesProvider fav,
    bool isDark,
  ) {
    final lastReadSurah = QuranData.getSurahByNumber(fav.lastReadSurah);
    final lastReadAyah = fav.lastReadAyah;
    final totalVerses = lastReadSurah.versesCount > 0 ? lastReadSurah.versesCount : 1;
    final progressFraction = (lastReadAyah / totalVerses).clamp(0.01, 1.0);
    final progressPercent = (progressFraction * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -25,
            top: -25,
            child: ArabesquePattern(size: 180, opacity: 0.12),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Metadata & Bookmark Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bookmark, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Akhriskii Ugu Dambeeyay',
                            style: AppTypography.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Juz ${lastReadSurah.juzNumber} • Xisbi ${lastReadSurah.hizbNumber}',
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: AppColors.secondaryFixed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Surah Title & Verse Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suurada ${lastReadSurah.somaliName}',
                          style: AppTypography.serif(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Aayadda $lastReadAyah ee ${lastReadSurah.versesCount}',
                          style: AppTypography.sans(
                            fontSize: 13,
                            color: AppColors.secondaryFixed,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      lastReadSurah.arabicName,
                      style: AppTypography.arabic(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        lineHeight: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Audio Tafsiir Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.record_voice_over, size: 18, color: AppColors.tertiaryFixed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lastReadSurah.audioTafsiirTitle.isNotEmpty
                              ? 'Codka Sheekha: ${lastReadSurah.audioTafsiirTitle}'
                              : 'Codka Sheekha: Tafsiirka Suuradda',
                          style: AppTypography.sans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dhamaystirka Juzka',
                      style: AppTypography.sans(
                        fontSize: 11.5,
                        color: AppColors.secondaryFixed,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: AppTypography.sans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    height: 6,
                    color: Colors.white.withOpacity(0.2),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressFraction,
                      child: Container(color: AppColors.tertiaryFixed),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action CTAs
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: Text(
                          'Sii Wad Akhriska',
                          style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => QuranReadingScreen(
                                initialSurah: lastReadSurah,
                                initialAyahNumber: lastReadAyah,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white.withOpacity(0.25)),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          elevation: 0,
                        ),
                        icon: Icon(
                          audio.isSurahStreaming(lastReadSurah.number)
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          size: 18,
                        ),
                        label: Text(
                          audio.isSurahStreaming(lastReadSurah.number)
                              ? 'Jooji Codka'
                              : 'Dhagayso Tafsiirka',
                          style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (audio.isSurahStreaming(lastReadSurah.number)) {
                            audio.pause();
                          } else {
                            audio.playQuranSurah(lastReadSurah);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const PlayerScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Navigation Filters
  Widget _buildNavigationFilters(bool isDark) {
    final borderColor = AppTheme.border(isDark);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final tab = _tabs[i];
          final titleOnly = tab.split(' ')[0];
          final isSelected = _selectedTab == titleOnly || _selectedTab == tab;

          IconData icon = Icons.menu_book;
          if (i == 1) icon = Icons.grid_view;
          if (i == 2) icon = Icons.mic;
          if (i == 3) icon = Icons.star;

          final tabBg = isSelected
              ? (isDark ? AppTheme.primaryLight : QuranTheme.primary)
              : (isDark ? AppTheme.darkSecondary : QuranTheme.surfaceContainerHigh);
          final tabTextColor = isSelected
              ? Colors.white
              : (isDark ? AppTheme.darkTextSecondary : QuranTheme.iconColor);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = (i == 0) ? 'Suuradaha' : (i == 3) ? 'Aayadaha La Doortay' : tab;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: tabBg,
                borderRadius: BorderRadius.circular(99),
                border: isSelected ? null : Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: tabTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tab,
                    style: AppTypography.sans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: tabTextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Search Bar
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: AppTypography.sans(fontSize: 13.5, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Raadi Suurad, Aayad ama Mawduuc...',
                      hintStyle: AppTypography.sans(fontSize: 13, color: textMuted),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: QuranTheme.softShadow,
          ),
          child: IconButton(
            icon: Icon(Icons.swap_vert, size: 20, color: isDark ? AppTheme.primaryLight : QuranTheme.iconColor),
            tooltip: 'Kala saar',
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSecondary : QuranTheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: QuranTheme.softShadow,
          ),
          child: IconButton(
            icon: Icon(Icons.my_location, size: 20, color: isDark ? AppTheme.primaryLight : QuranTheme.onSecondaryContainer),
            tooltip: 'U bood aayad',
            onPressed: () {
              _showJumpToAyahDialog(context, isDark);
            },
          ),
        ),
      ],
    );
  }

  // 3.5. Reciter Selector Strip
  Widget _buildReciterSelectorStrip(
    BuildContext context,
    AudioPlayerProvider audio,
    bool isDark,
  ) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final borderColor = AppTheme.border(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: QuranTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (isDark ? AppTheme.primaryLight : QuranTheme.primary).withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                audio.currentReciter.displayImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QAARIGA QUR\'AANKA (MP3QURAN)',
                  style: AppTypography.sans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.primaryLight : QuranTheme.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${audio.currentReciter.nameEn} • ${audio.currentReciter.nameAr}',
                  style: AppTypography.sans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.primaryLight : QuranTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 0,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: Text(
              'Beddel',
              style: AppTypography.sans(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => ReciterSelectionSheet.show(context),
          ),
        ],
      ),
    );
  }

  // 5. Surah Card
  Widget _buildSurahCard(
    BuildContext context,
    SurahModel surah,
    AudioPlayerProvider audio,
    FavoritesProvider fav,
    bool isActive,
    bool isDark,
  ) {
    final isBookmarked = fav.isSurahBookmarked(surah.number);
    final isStreaming = audio.isSurahStreaming(surah.number);
    final isBuffering = audio.isSurahBuffering(surah.number);
    final isCurrent = audio.currentQuranSurah?.number == surah.number;
    final isCardHighlighted = isActive || isCurrent || isStreaming;

    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final activeColor = isDark ? AppTheme.primaryLight : QuranTheme.primary;

    return GestureDetector(
      onTap: () {
        _showSurahReadModal(context, surah);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: QuranTheme.cardRadius,
          border: isCardHighlighted
              ? Border.all(color: activeColor, width: 1.5)
              : Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: QuranTheme.cardRadius,
          child: Container(
            decoration: BoxDecoration(
              border: isCardHighlighted
                  ? Border(left: BorderSide(color: activeColor, width: 4.5))
                  : null,
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCardHighlighted
                            ? activeColor
                            : (isDark ? AppTheme.darkBadgeBg : QuranTheme.badgeBackground),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${surah.number}',
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCardHighlighted
                              ? Colors.white
                              : (isDark ? AppTheme.darkBadgeText : QuranTheme.badgeText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                surah.somaliName,
                                style: AppTypography.serif(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${surah.versesCount} Aayadood',
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            surah.meaning,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      surah.arabicName,
                      style: AppTypography.arabic(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFC4B5FD) : QuranTheme.arabicCalligraphy,
                        lineHeight: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSecondary
                            : (isCardHighlighted ? AppColors.secondaryContainer : AppColors.surfaceContainer),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isStreaming ? Icons.equalizer : (isCardHighlighted ? Icons.graphic_eq : Icons.mic),
                            size: 14,
                            color: isCardHighlighted
                                ? (isDark ? AppTheme.primaryLight : QuranTheme.onSecondaryContainer)
                                : (isDark ? const Color(0xFFFFB59D) : AppColors.tertiary),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isStreaming || isCurrent
                                ? 'Codka: ${audio.currentReciter.nameEn}'
                                : surah.audioTafsiirTitle,
                            style: AppTypography.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isCardHighlighted
                                  ? (isDark ? AppTheme.darkTextPrimary : QuranTheme.onSecondaryContainer)
                                  : textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          iconSize: 20,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? activeColor : textMuted,
                          ),
                          onPressed: () {
                            fav.toggleSurahBookmark(surah.number);
                          },
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (isStreaming) {
                              audio.pause();
                            } else if (isCurrent) {
                              audio.resume();
                            } else {
                              audio.playQuranSurah(surah);
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isStreaming ? const Color(0xFF10B981) : activeColor,
                              shape: BoxShape.circle,
                            ),
                            child: isBuffering
                                ? const Padding(
                                    padding: EdgeInsets.all(9.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    isStreaming ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. Hadith Virtue Card
  Widget _buildHadithVirtueCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppTheme.darkCard : AppColors.surfaceContainerLow;
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: isDark ? AppTheme.primaryLight : AppColors.tertiary),
              const SizedBox(width: 6),
              Text(
                'FADLIGA AKHRISKA & BARASHADA QUR\'AANKA',
                style: AppTypography.sans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.primaryLight : AppColors.tertiary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '« خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ »',
            textAlign: TextAlign.center,
            style: AppTypography.arabic(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
              lineHeight: 1.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"Waxa idiinku khayr badan qofka Qur\'aanka barta, dadkana bara."',
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              fontSize: 13.5,
              color: textMuted,
              lineHeight: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Riyaadu Saalixiina (Xadiis 993) • Saxnuul Bukhaari',
            style: AppTypography.sans(
              fontSize: 11,
              color: textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showSurahReadModal(BuildContext context, SurahModel surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => QuranReadingScreen(
          initialSurah: surah,
        ),
      ),
    );
  }

  void _showJumpToAyahDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();
    final fav = Provider.of<FavoritesProvider>(context, listen: false);
    final lastReadSurah = QuranData.getSurahByNumber(fav.lastReadSurah);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: Text('U bood Aayad', style: AppTypography.serif(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suurada ${lastReadSurah.somaliName} (1 - ${lastReadSurah.versesCount}):',
              style: AppTypography.sans(fontSize: 12.5, color: textMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Gali Lambarka Aayadda',
                hintStyle: TextStyle(color: textMuted),
                filled: true,
                fillColor: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Jooji', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isDark ? AppTheme.primaryLight : AppColors.primary),
            onPressed: () {
              final ayah = int.tryParse(controller.text.trim()) ?? 1;
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => QuranReadingScreen(
                    initialSurah: lastReadSurah,
                    initialAyahNumber: ayah,
                  ),
                ),
              );
            },
            child: const Text('Tag Aayadda', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
