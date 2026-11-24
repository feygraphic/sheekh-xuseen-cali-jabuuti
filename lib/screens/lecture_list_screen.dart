import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/lecture_model.dart';
import '../providers/audio_player_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../data/sample_data.dart';
import 'player_screen.dart';

class LectureListScreen extends StatefulWidget {
  final int? categoryNumber; // null means 'Dhammaan'
  final String categoryTitle;
  final String categorySubtitle;
  final String categoryArabic;

  const LectureListScreen({
    super.key,
    required this.categoryNumber,
    required this.categoryTitle,
    required this.categorySubtitle,
    required this.categoryArabic,
  });

  @override
  State<LectureListScreen> createState() => _LectureListScreenState();
}

class _LectureListScreenState extends State<LectureListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LectureModel> _getCategoryLectures() {
    List<LectureModel> list = widget.categoryNumber == null
        ? List.from(SampleData.lectures)
        : SampleData.lectures.where((l) => l.seriesNumber == widget.categoryNumber).toList();

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((l) {
        return l.somaliTitle.toLowerCase().contains(q) ||
            l.arabicTitle.toLowerCase().contains(q) ||
            l.trackNumber.toString() == q;
      }).toList();
    }

    if (_sortAscending) {
      list.sort((a, b) => a.trackNumber.compareTo(b.trackNumber));
    } else {
      list.sort((a, b) => b.trackNumber.compareTo(a.trackNumber));
    }

    return list;
  }

  void _openPlayer(BuildContext context, LectureModel lecture, AudioPlayerProvider audio, List<LectureModel> playlist) {
    if (audio.currentLecture?.id != lecture.id) {
      audio.playLecture(lecture, playlist: playlist);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const PlayerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);
    final fav = Provider.of<FavoritesProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    final lectures = _getCategoryLectures();
    final totalCount = widget.categoryNumber == null
        ? SampleData.lectures.length
        : SampleData.lectures.where((l) => l.seriesNumber == widget.categoryNumber).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.95),
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    tooltip: 'Dib u noqo qaybaha',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryTitle,
                          style: AppTypography.serif(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.categorySubtitle} • $totalCount Muxaadaro',
                          style: AppTypography.sans(
                            fontSize: 11,
                            color: isDark ? const Color(0xFFB49EFF) : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.share_outlined, color: textMuted, size: 21),
                    tooltip: 'Wadaag',
                    onPressed: () {
                      Share.share(
                        'Dhageyso ${widget.categoryTitle} ($totalCount Muxaadaro) ee Sheekh Xuseen Cali Jabuuti: https://play.google.com/store/apps',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
        children: [
          // 1. Category Header Mini Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: widget.categoryNumber == null ? AppColors.heroGradient : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.categoryNumber == null ? 'ALL' : 'Q${widget.categoryNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryArabic,
                        style: AppTypography.arabic(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalCount Muxaadaro oo diyaar ah',
                        style: AppTypography.sans(
                          fontSize: 12,
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Search & Filter Bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textColor, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Ka raadi cinwaanka carabi ama soomaali...',
                      hintStyle: TextStyle(color: textMuted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: Icon(Icons.clear, size: 18, color: textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Results Header & Sort Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Muxaadarooyinka (${lectures.length})',
                style: AppTypography.serif(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _sortAscending ? 'Ugu dambeeyay' : 'Ugu horreeyay',
                      style: AppTypography.sans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFB49EFF) : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.swap_vert,
                      size: 16,
                      color: isDark ? const Color(0xFFB49EFF) : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4. Lectures List
          if (lectures.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'Wax muxaadaro ah lagama helin raadintaada.',
                    style: AppTypography.sans(fontSize: 13.5, color: textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lectures.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final lecture = lectures[i];
                final isCurrentActive = audio.currentLecture?.id == lecture.id;
                final isDownloaded = fav.isDownloaded(lecture.id);

                return _buildLectureCard(
                  context: context,
                  lecture: lecture,
                  isCurrentActive: isCurrentActive,
                  isPlaying: audio.isPlaying && isCurrentActive,
                  isDownloaded: isDownloaded,
                  audio: audio,
                  fav: fav,
                  playlist: lectures,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  textMuted: textMuted,
                  isDark: isDark,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLectureCard({
    required BuildContext context,
    required LectureModel lecture,
    required bool isCurrentActive,
    required bool isPlaying,
    required bool isDownloaded,
    required AudioPlayerProvider audio,
    required FavoritesProvider fav,
    required List<LectureModel> playlist,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required bool isDark,
  }) {
    final activeBorderColor = isDark ? const Color(0xFF9D84FF) : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentActive ? activeBorderColor : borderColor,
          width: isCurrentActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openPlayer(context, lecture, audio, playlist),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Lecture Number Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCurrentActive
                        ? AppColors.primary
                        : (isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${lecture.trackNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isCurrentActive
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Lecture Titles (Arabic & Somali)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic Title
                      Text(
                        lecture.arabicTitle,
                        style: AppTypography.arabic(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isCurrentActive ? activeBorderColor : textColor,
                          lineHeight: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Somali Title & Duration
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lecture.somaliTitle,
                              style: AppTypography.sans(
                                fontSize: 12,
                                color: textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lecture.durationString,
                            style: AppTypography.sans(
                              fontSize: 11,
                              color: textMuted.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Download Button
                IconButton(
                  icon: Icon(
                    isDownloaded ? Icons.check_circle : Icons.download_rounded,
                    size: 20,
                    color: isDownloaded ? Colors.green : textMuted,
                  ),
                  tooltip: isDownloaded ? 'Waa la degsaday' : 'Degso codka',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    fav.toggleDownload(lecture.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isDownloaded
                              ? 'Muxaadarada waa laga saaray liiska degsan'
                              : 'Muxaadarada si guul leh ayaa loo degsaday!',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Play Button
                GestureDetector(
                  onTap: () => _openPlayer(context, lecture, audio, playlist),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCurrentActive
                          ? AppColors.primary
                          : (isDark ? const Color(0xFF2C2542) : AppColors.primaryFixed.withOpacity(0.7)),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isCurrentActive && isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 20,
                      color: isCurrentActive ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
