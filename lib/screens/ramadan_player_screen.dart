import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../data/ramadan_data.dart';
import '../models/ramadan_lecture.dart';
import '../providers/settings_provider.dart';

class RamadanPlayerScreen extends StatefulWidget {
  final RamadanLecture lecture;
  final RamadanScholar scholar;

  const RamadanPlayerScreen({
    super.key,
    required this.lecture,
    required this.scholar,
  });

  @override
  State<RamadanPlayerScreen> createState() => _RamadanPlayerScreenState();
}

class _RamadanPlayerScreenState extends State<RamadanPlayerScreen> {
  late RamadanLecture _currentLecture;
  late List<RamadanLecture> _scholarLectures;
  late int _currentIndex;
  YoutubePlayerController? _controller;
  bool _hasError = false;
  String? _errorMessage;

  bool get _isTestEnvironment =>
      WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    _currentLecture = widget.lecture;
    _scholarLectures = RamadanData.getLecturesByScholar(widget.scholar.id);
    _currentIndex = _scholarLectures.indexWhere((l) => l.id == _currentLecture.id);
    if (_currentIndex == -1) _currentIndex = 0;

    _initPlayer();
  }

  void _initPlayer() {
    if (_isTestEnvironment) return;

    final videoId = _currentLecture.videoId;
    if (videoId == null || videoId.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Cinwaanka fiidiyowga YouTube-ka lama helin (Invalid Video ID).';
      });
      return;
    }

    try {
      _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          strictRelatedVideos: true,
          enableCaption: false,
        ),
      );

      _controller!.loadVideoById(videoId: videoId);

      _controller!.listen((event) {
        if (event.error != YoutubeError.none && mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Fiidiyowgan waxaa laga yaabaa in YouTube uu xaddiday '
                'in toos looga dhex daawado abka (Embedding restricted by YouTube).';
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Khalad ayaa dhacay intii fiidiyowga la diyaarinayay.';
        });
      }
    }
  }

  void _changeLecture(RamadanLecture newLecture) {
    setState(() {
      _currentLecture = newLecture;
      _currentIndex = _scholarLectures.indexWhere((l) => l.id == newLecture.id);
      _hasError = false;
      _errorMessage = null;
    });

    if (!_isTestEnvironment && _controller != null) {
      final videoId = newLecture.videoId;
      if (videoId != null && videoId.isNotEmpty) {
        _controller!.loadVideoById(videoId: videoId);
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textSub = AppTheme.textSub(isDark);
    final accentColor = isDark ? AppTheme.primaryLight : AppColors.primary;
    final borderColor = AppTheme.border(isDark);

    final total = _scholarLectures.length;
    final currentNum = _currentIndex + 1;

    final playerWidget = _isTestEnvironment
        ? Container(
            height: 220,
            color: Colors.black,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 54),
                const SizedBox(height: 8),
                Text(
                  _currentLecture.displayTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : (_hasError
            ? Container(
                height: 220,
                color: isDark ? const Color(0xFF1E1E28) : const Color(0xFFF1F5F9),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 44),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage ?? 'Fiidiyowgu ma shaqeynayo.',
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                        fontSize: 13,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _errorMessage = null;
                        });
                        _initPlayer();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Isku day mar kale'),
                    ),
                  ],
                ),
              )
            : YoutubePlayer(
                controller: _controller!,
                aspectRatio: 16 / 9,
              ));

    final content = Scaffold(
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
              'Daawo Muxaadarada',
              style: AppTypography.sans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              widget.scholar.name,
              style: AppTypography.sans(
                fontSize: 11.5,
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppTheme.icon(isDark), size: 21),
            tooltip: 'Wadaag',
            onPressed: () {
              Share.share(
                'Daawo Muxaadarada: ${_currentLecture.displayTitle} - ${widget.scholar.name}\n${_currentLecture.youtubeUrl}',
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.playlist_play_rounded, color: accentColor, size: 26),
            tooltip: 'Liiska Muxaadarooyinka',
            onPressed: () => _showPlaylistSheet(context, isDark),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. YouTube In-App Player
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: playerWidget,
              ),

              // 2. Video & Scholar Information Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scholar Pill & Order Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Scholar Badge
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: accentColor.withOpacity(0.4)),
                              ),
                              alignment: Alignment.center,
                              child: widget.scholar.imageAsset != null
                                  ? ClipOval(
                                      child: Image.asset(
                                        widget.scholar.imageAsset!,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        width: 32,
                                        height: 32,
                                      ),
                                    )
                                  : Icon(Icons.person, color: accentColor, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.scholar.name,
                                  style: AppTypography.sans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  widget.scholar.arabicTitle,
                                  style: AppTypography.arabic(
                                    fontSize: 11,
                                    color: textSub,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Order Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF282538) : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            '$currentNum / $total',
                            style: AppTypography.sans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Actual Lecture Title
                    Text(
                      _currentLecture.displayTitle,
                      style: AppTypography.sans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        lineHeight: 1.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tags Row: Category, Language, In-App Tag
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildTag(
                          icon: Icons.calendar_month,
                          label: 'Bisha Ramadaan',
                          isDark: isDark,
                        ),
                        _buildTag(
                          icon: Icons.language,
                          label: _currentLecture.language,
                          isDark: isDark,
                        ),
                        _buildTag(
                          icon: Icons.play_arrow_rounded,
                          label: 'Muuqaal Toos ah (In-App)',
                          isDark: isDark,
                          highlight: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Divider(color: borderColor),
                    const SizedBox(height: 10),

                    // Navigation Controls: Previous / Next Lecture
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _currentIndex > 0
                                ? () => _changeLecture(_scholarLectures[_currentIndex - 1])
                                : null,
                            icon: const Icon(Icons.skip_previous, size: 18),
                            label: const Text(
                              'Kii Hore',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _currentIndex < total - 1
                                ? () => _changeLecture(_scholarLectures[_currentIndex + 1])
                                : null,
                            icon: const Icon(Icons.skip_next, size: 18),
                            label: const Text(
                              'Ka Xiga',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Next Up Card
                    if (_currentIndex < total - 1) ...[
                      Text(
                        'Muxaadarada Xigta',
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textSub,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildNextLectureCard(
                        _scholarLectures[_currentIndex + 1],
                        isDark,
                        cardBg,
                        borderColor,
                        textColor,
                        textSub,
                        accentColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_isTestEnvironment || _controller == null) {
      return content;
    }

    return YoutubePlayerControllerProvider(
      controller: _controller!,
      child: content,
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required bool isDark,
    bool highlight = false,
  }) {
    final accent = isDark ? AppTheme.primaryLight : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? accent.withOpacity(0.12)
            : (isDark ? const Color(0xFF282538) : AppColors.surfaceContainer),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? accent.withOpacity(0.35) : AppTheme.border(isDark),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: highlight ? accent : AppTheme.icon(isDark)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.sans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: highlight ? accent : AppTheme.textSub(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextLectureCard(
    RamadanLecture nextLec,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color textSub,
    Color accentColor,
  ) {
    return InkWell(
      onTap: () => _changeLecture(nextLec),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${nextLec.sortOrder}'.padLeft(2, '0'),
                style: AppTypography.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nextLec.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.sans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.play_circle_outline, color: accentColor, size: 22),
          ],
        ),
      ),
    );
  }

  void _showPlaylistSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.scholar.name} (${_scholarLectures.length} Muuqaal)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text(isDark),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.icon(isDark), size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Divider(color: AppTheme.divider(isDark)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _scholarLectures.length,
                    separatorBuilder: (_, _) => Divider(color: AppTheme.divider(isDark), height: 1),
                    itemBuilder: (ctx, idx) {
                      final lec = _scholarLectures[idx];
                      final isCurrent = lec.id == _currentLecture.id;
                      final accent = isDark ? AppTheme.primaryLight : AppColors.primary;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isCurrent ? accent : (isDark ? const Color(0xFF282538) : AppColors.surfaceContainer),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${lec.sortOrder}',
                            style: AppTypography.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : AppTheme.text(isDark),
                            ),
                          ),
                        ),
                        title: Text(
                          lec.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sans(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent ? accent : AppTheme.text(isDark),
                          ),
                        ),
                        trailing: isCurrent
                            ? Icon(Icons.volume_up_rounded, color: accent, size: 18)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          _changeLecture(lec);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
