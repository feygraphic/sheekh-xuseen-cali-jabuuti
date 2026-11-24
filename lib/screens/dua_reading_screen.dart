import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/adkhar_model.dart';
import '../providers/adhkar_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

class DuaReadingScreen extends StatefulWidget {
  final AdkharModel initialDua;
  final List<AdkharModel> categoryDuas;
  final int initialIndex;

  const DuaReadingScreen({
    super.key,
    required this.initialDua,
    required this.categoryDuas,
    this.initialIndex = 0,
  });

  @override
  State<DuaReadingScreen> createState() => _DuaReadingScreenState();
}

class _DuaReadingScreenState extends State<DuaReadingScreen> {
  late PageController _pageController;
  late int _currentIndex;
  double _fontScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex >= 0 && widget.initialIndex < widget.categoryDuas.length
        ? widget.initialIndex
        : widget.categoryDuas.indexWhere((d) => d.id == widget.initialDua.id);
    if (_currentIndex == -1) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.categoryDuas.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _shareDua(AdkharModel dua) {
    final text = '''
${dua.title}
${dua.arabicTitle != null ? '${dua.arabicTitle}\n' : ''}
${dua.arabicText}

Macnaha:
${dua.somaliTranslation}

Xigasho: ${dua.reference} (${dua.authenticity ?? 'Saxiix'})
${dua.virtue != null ? '\nFadliga: ${dua.virtue}' : ''}

App-ka Sheekh Xuseen Cali Jabuuti
''';
    Share.share(text, subject: dua.title);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final fav = Provider.of<FavoritesProvider>(context);
    final adhkarProv = Provider.of<AdhkarProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final textColor = AppTheme.text(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    final currentDua = widget.categoryDuas.isNotEmpty && _currentIndex < widget.categoryDuas.length
        ? widget.categoryDuas[_currentIndex]
        : widget.initialDua;

    // Synchronize latest count and completion from provider
    final liveDua = adhkarProv.adhkarList.firstWhere(
      (d) => d.id == currentDua.id,
      orElse: () => currentDua,
    );

    final isBookmarked = fav.isAdhkarBookmarked(liveDua.id);

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
        title: Column(
          children: [
            Text(
              liveDua.category,
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            Text(
              '${_currentIndex + 1} / ${widget.categoryDuas.length}',
              style: AppTypography.sans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cabbirka Qoraalka',
            icon: Icon(Icons.text_fields_rounded, size: 22, color: textColor),
            onPressed: () {
              setState(() {
                if (_fontScale >= 1.3) {
                  _fontScale = 0.9;
                } else {
                  _fontScale += 0.15;
                }
              });
            },
          ),
          IconButton(
            tooltip: isBookmarked ? 'Ka saar calaamadaha' : 'Ku dar calaamadaha',
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 24,
              color: isBookmarked ? const Color(0xFFE28945) : textColor,
            ),
            onPressed: () {
              fav.toggleAdhkarBookmark(liveDua.id);
            },
          ),
          IconButton(
            tooltip: 'La wadaag',
            icon: Icon(Icons.share_rounded, size: 21, color: textColor),
            onPressed: () => _shareDua(liveDua),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.categoryDuas.length,
        itemBuilder: (ctx, index) {
          final item = widget.categoryDuas[index];
          final syncedItem = adhkarProv.adhkarList.firstWhere(
            (d) => d.id == item.id,
            orElse: () => item,
          );
          return _buildDuaBody(context, syncedItem, adhkarProv, audio, isDark);
        },
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark, adhkarProv, liveDua),
    );
  }

  Widget _buildDuaBody(
    BuildContext context,
    AdkharModel item,
    AdhkarProvider adhkarProv,
    AudioPlayerProvider audio,
    bool isDark,
  ) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);
    final arabicBg = isDark ? const Color(0xFF1F1B2C) : const Color(0xFFF7F2FE);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBadgeBg : AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'Duco #${_currentIndex + 1}',
                  style: AppTypography.sans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkBadgeText : AppColors.onPrimaryFixed,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? Colors.green.withOpacity(0.15)
                      : (isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: item.isCompleted ? Colors.green : borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isCompleted ? Icons.check_circle_rounded : Icons.repeat_rounded,
                      size: 14,
                      color: item.isCompleted ? Colors.green : textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.isCompleted
                          ? 'Waa La Dhammaystiray'
                          : 'Tirada: ${item.targetCount} Jeer',
                      style: AppTypography.sans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: item.isCompleted ? Colors.green : textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Titles
          Text(
            item.title,
            style: AppTypography.serif(
              fontSize: 20 * _fontScale,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (item.arabicTitle != null && item.arabicTitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.arabicTitle!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTypography.arabic(
                fontSize: 16 * _fontScale,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Arabic Dua Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: arabicBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.format_quote_rounded, size: 24, color: accentColor.withOpacity(0.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'النص القرآني / النبوي',
                        style: AppTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.arabic(
                    fontSize: 22 * _fontScale,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    lineHeight: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Transliteration (if available)
          if (item.transliteration != null && item.transliteration!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.record_voice_over_rounded, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        'Dhawaaqida (Transliteration)',
                        style: AppTypography.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.transliteration!,
                    style: AppTypography.sans(
                      fontSize: 13.5 * _fontScale,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.9),
                      lineHeight: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Somali Meaning
          Container(
            padding: const EdgeInsets.all(16),
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
                    Icon(Icons.translate_rounded, size: 17, color: accentColor),
                    const SizedBox(width: 6),
                    Text(
                      'Macnaha Af-Soomaaliga',
                      style: AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.somaliTranslation,
                  style: AppTypography.sans(
                    fontSize: 14 * _fontScale,
                    color: textColor.withOpacity(0.92),
                    lineHeight: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Virtue Card (Fadliga)
          if (item.virtue != null && item.virtue!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF261D16) : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE28945).withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_rounded, size: 20, color: Color(0xFFE28945)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fadliga & Faaiidada',
                          style: AppTypography.sans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE28945),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.virtue!,
                          style: AppTypography.sans(
                            fontSize: 13 * _fontScale,
                            color: textColor.withOpacity(0.9),
                            lineHeight: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Reference & Source
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.library_books_rounded, size: 16, color: textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Xigasho: ${item.reference}',
                    style: AppTypography.sans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
                if (item.authenticity != null && item.authenticity!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBadgeBg : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      item.authenticity!,
                      style: AppTypography.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Interactive Counter Box
          _buildCounterSection(context, item, adhkarProv, isDark),
          const SizedBox(height: 20),

          // Audio Player Controls (Requirement 3: Play/Pause, Rewind, Forward, Speed, Progress, Duration)
          _buildAudioPlayerCard(context, item, audio, isDark),
        ],
      ),
    );
  }

  Widget _buildCounterSection(
    BuildContext context,
    AdkharModel item,
    AdhkarProvider adhkarProv,
    bool isDark,
  ) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    final progress = item.targetCount > 0
        ? (item.currentCount / item.targetCount).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isCompleted ? Colors.green.withOpacity(0.5) : borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xisaabiyaha Akhriska',
                    style: AppTypography.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    item.isCompleted
                        ? 'Hadafkii waa la gaaray! Allaha kaaga aqbalo'
                        : 'Riix badhanka si aad u tiriso',
                    style: AppTypography.sans(
                      fontSize: 12,
                      color: item.isCompleted ? Colors.green : textMuted,
                    ),
                  ),
                ],
              ),
              if (item.currentCount > 0)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    adhkarProv.resetDhikr(item.id);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Dib u celi'),
                  style: TextButton.styleFrom(
                    foregroundColor: textMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Giant Interactive Tap Area
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              adhkarProv.incrementDhikr(item.id);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                gradient: item.isCompleted
                    ? const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)])
                    : LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF7A45C8), const Color(0xFF4A1BC4)]
                            : [AppColors.primary, AppColors.primaryDark],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (item.isCompleted ? Colors.green : AppColors.primary).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.isCompleted ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.currentCount} / ${item.targetCount}',
                        style: AppTypography.sans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.isCompleted ? 'Waa la dhammaystiray (Riix dib u bilow)' : 'Halkan taabo si aad u tiriso',
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 8,
              color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHighest,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: item.isCompleted ? Colors.green : accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerCard(
    BuildContext context,
    AdkharModel item,
    AudioPlayerProvider audio,
    bool isDark,
  ) {
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    final isThisPlaying = audio.isAdhkarPlaying(item.id);
    final position = isThisPlaying ? audio.position : Duration.zero;
    final duration = isThisPlaying && audio.duration > Duration.zero
        ? audio.duration
        : const Duration(seconds: 45);

    final progressRatio = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    String formatDuration(Duration d) {
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isThisPlaying ? accentColor.withOpacity(0.5) : borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.headphones_rounded, size: 20, color: accentColor),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dhagayso Codka',
                        style: AppTypography.sans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isThisPlaying ? 'Codku wuu socdaa...' : 'Cod sugan oo cad',
                        style: AppTypography.sans(
                          fontSize: 11.5,
                          color: isThisPlaying ? accentColor : textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Playback Speed Toggle
              GestureDetector(
                onTap: () => audio.toggleSpeed(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    '${audio.playbackSpeed}x',
                    style: AppTypography.sans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Slider Progress
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: accentColor,
              inactiveTrackColor: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHighest,
              thumbColor: accentColor,
            ),
            child: Slider(
              value: progressRatio,
              onChanged: (val) {
                if (isThisPlaying && duration > Duration.zero) {
                  final target = Duration(milliseconds: (val * duration.inMilliseconds).toInt());
                  audio.seekTo(target);
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(position),
                  style: AppTypography.sans(fontSize: 11, color: textMuted),
                ),
                Text(
                  formatDuration(duration),
                  style: AppTypography.sans(fontSize: 11, color: textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Player Buttons: Rewind 10s, Play/Pause, Forward 10s, Repeat
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: '10 ilbiriqsi dib u celi',
                icon: Icon(Icons.replay_10_rounded, size: 26, color: textColor),
                onPressed: () => audio.skipBackward(10),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  audio.playAdhkar(item, playlist: widget.categoryDuas);
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF7A45C8), const Color(0xFF4A1BC4)]
                          : [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: audio.isLoading && isThisPlaying
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Icon(
                          isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                tooltip: '10 ilbiriqsi horay u wad',
                icon: Icon(Icons.forward_10_rounded, size: 26, color: textColor),
                onPressed: () => audio.skipForward(10),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Ku celi',
                icon: Icon(
                  Icons.repeat_rounded,
                  size: 22,
                  color: audio.isRepeat ? accentColor : textMuted,
                ),
                onPressed: () => audio.toggleRepeat(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    bool isDark,
    AdhkarProvider adhkarProv,
    AdkharModel liveDua,
  ) {
    final bgColor = AppTheme.bg(isDark);
    final borderColor = AppTheme.border(isDark);
    final textColor = AppTheme.text(isDark);
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < widget.categoryDuas.length - 1;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: hasPrev ? _goToPrevious : null,
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
            label: const Text('Ducadii Hore'),
            style: TextButton.styleFrom(
              foregroundColor: hasPrev ? textColor : textColor.withOpacity(0.3),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.categoryDuas.length}',
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: hasNext ? _goToNext : null,
            label: const Text('Ducada Xigta'),
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            style: TextButton.styleFrom(
              foregroundColor: hasNext ? textColor : textColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
