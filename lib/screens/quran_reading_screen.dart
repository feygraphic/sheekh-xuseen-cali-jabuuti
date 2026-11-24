import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/surah_model.dart';
import '../data/quran_data.dart';
import '../providers/favorites_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';
import '../constants/quran_theme.dart';

enum QuranThemeMode {
  serene, // Unified Serene Illumination (matches Page 1 exactly)
  light,  // Pure Light
  night,  // Night mode
}

class QuranReadingScreen extends StatefulWidget {
  final SurahModel initialSurah;
  final int initialAyahNumber;

  const QuranReadingScreen({
    super.key,
    required this.initialSurah,
    this.initialAyahNumber = 1,
  });

  @override
  State<QuranReadingScreen> createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends State<QuranReadingScreen> {
  late SurahModel _currentSurah;
  late List<AyahModel> _ayahs;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  double _arabicFontSize = 26.0;
  double _somaliFontSize = 15.0;
  QuranThemeMode _themeMode = QuranThemeMode.serene;

  bool _isLoadingVerses = false;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.initialSurah;
    _ayahs = QuranData.getCachedAyahs(_currentSurah.number);
    _buildAyahKeys();
    _loadSurahVerses(_currentSurah.number, targetAyah: widget.initialAyahNumber);
    _loadPreferences();
    _saveLastRead(widget.initialAyahNumber);
  }

  void _buildAyahKeys() {
    _ayahKeys.clear();
    for (final a in _ayahs) {
      _ayahKeys[a.ayahNumber] = GlobalKey();
    }
  }

  Future<void> _loadSurahVerses(int surahNumber, {int targetAyah = 1}) async {
    if (QuranData.hasCachedAyahs(surahNumber)) {
      final cached = QuranData.getCachedAyahs(surahNumber);
      setState(() {
        _ayahs = cached;
        _buildAyahKeys();
        _isLoadingVerses = false;
      });
      if (targetAyah > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyah(targetAyah);
        });
      }
      return;
    }

    setState(() {
      _isLoadingVerses = true;
    });

    final verses = await QuranData.loadAyahsForSurah(surahNumber);
    if (!mounted) return;

    setState(() {
      _ayahs = verses;
      _buildAyahKeys();
      _isLoadingVerses = false;
    });

    if (targetAyah > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(targetAyah);
      });
    }
  }

  Future<void> _loadPreferences() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _arabicFontSize = storage.getQuranArabicFontSize();
      _somaliFontSize = storage.getQuranSomaliFontSize();
      final themeStr = storage.getQuranReaderTheme();
      if (themeStr == 'night') {
        _themeMode = QuranThemeMode.night;
      } else if (themeStr == 'light') {
        _themeMode = QuranThemeMode.light;
      } else {
        _themeMode = QuranThemeMode.serene;
      }
    });
  }

  Future<void> _saveLastRead(int ayahNumber) async {
    final fav = Provider.of<FavoritesProvider>(context, listen: false);
    await fav.setLastRead(_currentSurah.number, ayahNumber);
  }

  void _changeSurah(SurahModel newSurah, {int targetAyah = 1}) {
    setState(() {
      _currentSurah = newSurah;
      _ayahs = QuranData.getCachedAyahs(newSurah.number);
      _buildAyahKeys();
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    _saveLastRead(targetAyah);
    _loadSurahVerses(newSurah.number, targetAyah: targetAyah);
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Active theme palette driven by centralized QuranReaderPalette & global theme
  QuranReaderPalette get _palette {
    final isDark = Provider.of<SettingsProvider>(context, listen: true).isDarkMode;
    if (isDark) {
      return QuranReaderPalette.dark;
    }
    switch (_themeMode) {
      case QuranThemeMode.night:
        return QuranReaderPalette.dark;
      case QuranThemeMode.serene:
        return QuranReaderPalette.serene;
      case QuranThemeMode.light:
        return QuranReaderPalette.light;
    }
  }

  Color get _bgColor => _palette.background;
  Color get _cardBgColor => _palette.cardBackground;
  Color get _arabicTextColor => _palette.arabicText;
  Color get _somaliTextColor => _palette.somaliText;
  Color get _accentColor => _palette.accent;
  Color get _badgeBgColor => _palette.badgeBackground;
  Color get _badgeTextColor => _palette.badgeText;
  Color get _badgeBorderColor => _palette.badgeBorder;
  Color get _dividerColor => _palette.divider;
  Color get _actionIconColor => _palette.actionIconColor;

  @override
  Widget build(BuildContext context) {
    final fav = Provider.of<FavoritesProvider>(context);
    final audio = Provider.of<AudioPlayerProvider>(context);
    final isSurahBookmarked = fav.isSurahBookmarked(_currentSurah.number);
    final isStreaming = audio.isSurahStreaming(_currentSurah.number);
    final isBuffering = audio.isSurahBuffering(_currentSurah.number);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor.withOpacity(0.95),
            border: Border(bottom: BorderSide(color: _dividerColor, width: 1)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: _arabicTextColor, size: 22),
                    tooltip: 'Dib u noqo',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),

                  // Surah selector title (Tappable to pick any of 114 Surahs)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showSurahPickerSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${_currentSurah.number}. ${_currentSurah.somaliName}',
                                    style: AppTypography.sans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: _arabicTextColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down, color: _accentColor, size: 20),
                              ],
                            ),
                            Text(
                              '${_currentSurah.arabicName} • ${_currentSurah.revelationType}',
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: _somaliTextColor,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Quran Audio Recitation Button
                  IconButton(
                    icon: isBuffering
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                            ),
                          )
                        : Icon(
                            isStreaming ? Icons.pause_circle_filled : Icons.play_circle_outline,
                            color: _accentColor,
                            size: 24,
                          ),
                    tooltip: isStreaming ? 'Jooji Dhagaysiga' : 'Dhagayso Codka Qaariga',
                    onPressed: () {
                      if (isStreaming) {
                        audio.pause();
                      } else {
                        audio.playQuranSurah(_currentSurah);
                      }
                    },
                  ),

                  // Jump to Ayah button
                  IconButton(
                    icon: Icon(Icons.find_in_page_outlined, color: _accentColor, size: 22),
                    tooltip: 'U bood Aayad',
                    onPressed: () => _showJumpToAyahDialog(context),
                  ),

                  // Text Size & Display Settings Button
                  IconButton(
                    icon: Icon(Icons.format_size, color: _accentColor, size: 23),
                    tooltip: 'Cabirka Farta & Midabka',
                    onPressed: () => _showTypographySheet(context),
                  ),

                  // Surah Bookmark
                  IconButton(
                    icon: Icon(
                      isSurahBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isSurahBookmarked ? _accentColor : _actionIconColor,
                      size: 23,
                    ),
                    tooltip: 'Calaamadee Suuradda',
                    onPressed: () {
                      fav.toggleSurahBookmark(_currentSurah.number);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isSurahBookmarked
                                ? 'Waa laga saaray calaamadda Suurada ${_currentSurah.somaliName}'
                                : 'Suurada ${_currentSurah.somaliName} waa la calaamadeeyay.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoadingVerses && _ayahs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _accentColor),
                  const SizedBox(height: 16),
                  Text(
                    'Soo rarayaa Suurada ${_currentSurah.somaliName}...',
                    style: AppTypography.sans(
                      fontSize: 14,
                      color: _somaliTextColor,
                    ),
                  ),
                ],
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                return false;
              },
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // Surah Header Banner (Juz, Hizb, Verses Count)
                  _buildSurahHeaderCard(),
                  const SizedBox(height: 18),

                  // Bismillah Header (Except Surah 9 At-Tawbah)
                  if (_currentSurah.number != 9) ...[
                    _buildBismillahBanner(),
                    const SizedBox(height: 20),
                  ],

                  // Verses List (Arabic + Somali Translation immediately underneath)
                  for (final ayah in _ayahs) ...[
                    _buildAyahItem(ayah, fav),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 12),
                  _buildSurahEndCard(),
                  const SizedBox(height: 16),
                  _buildSourceAttributionCard(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 1. Surah Header Banner Card
  Widget _buildSurahHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: QuranTheme.cardRadius,
        border: Border.all(color: _dividerColor),
        boxShadow: QuranTheme.softShadow,
      ),
      child: Column(
        children: [
          Text(
            _currentSurah.arabicName,
            style: AppTypography.arabic(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _accentColor,
              lineHeight: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Suurada ${_currentSurah.somaliName} (${_currentSurah.meaning})',
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _arabicTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildMetaTag('Aayadaha: ${_currentSurah.versesCount}'),
              _buildMetaTag(_currentSurah.revelationType),
              _buildMetaTag('Juz ${_currentSurah.juzNumber}'),
              _buildMetaTag('Xisbi ${_currentSurah.hizbNumber}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: _badgeBgColor.withOpacity(_themeMode == QuranThemeMode.night ? 0.35 : 0.45),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _badgeBorderColor),
      ),
      child: Text(
        label,
        style: AppTypography.sans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _badgeTextColor,
        ),
      ),
    );
  }

  // 2. Bismillah Header Banner
  Widget _buildBismillahBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: QuranTheme.cardRadius,
        border: Border.all(color: _accentColor.withOpacity(0.25)),
        boxShadow: QuranTheme.softShadow,
      ),
      child: Column(
        children: [
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: AppTypography.arabic(
              fontSize: _arabicFontSize * 0.95,
              fontWeight: FontWeight.bold,
              color: _arabicTextColor,
              lineHeight: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Magaca Eebbe yaan ku bilaabaynaa ee Naxariis guud iyo mid gaaraba Naxariista.',
            textAlign: TextAlign.center,
            style: AppTypography.sans(
              fontSize: _somaliFontSize * 0.92,
              color: _somaliTextColor,
              lineHeight: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Ayah Item Card (Arabic Quran text with Somali translation immediately underneath)
  Widget _buildAyahItem(AyahModel ayah, FavoritesProvider fav) {
    final isBookmarked = fav.isAyahBookmarked(_currentSurah.number, ayah.ayahNumber);

    return Container(
      key: _ayahKeys[ayah.ayahNumber],
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: QuranTheme.cardRadius,
        border: Border.all(
          color: isBookmarked ? _accentColor : _dividerColor,
          width: isBookmarked ? 1.5 : 1.0,
        ),
        boxShadow: QuranTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Header Row (Badge, Actions)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ayah Number Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeBgColor,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: _badgeBorderColor),
                ),
                child: Text(
                  'Aayadda ${ayah.ayahNumber}',
                  style: AppTypography.sans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: _badgeTextColor,
                  ),
                ),
              ),

              // Ayah Actions (Bookmark, Copy, Share)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? _accentColor : _actionIconColor,
                    ),
                    tooltip: 'Calaamadee Aayaddan',
                    onPressed: () {
                      fav.toggleAyahBookmark(_currentSurah.number, ayah.ayahNumber);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? 'Waa laga saaray calaamadda Aayadda ${ayah.ayahNumber}'
                                : 'Aayadda ${ayah.ayahNumber} ee Suurada ${_currentSurah.somaliName} waa la calaamadeeyay.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    iconSize: 19,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.copy, color: _actionIconColor),
                    tooltip: 'Koobiyeey Aayadda & Macnaha',
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              '${ayah.arabicText}\n\n${ayah.somaliTranslation}\n\n[Qur\'aanka: ${_currentSurah.somaliName} (${_currentSurah.number}):${ayah.ayahNumber}]',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aayadda iyo micnaha Soomaaliga waa la koobiyeeyay!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    iconSize: 19,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.share_outlined, color: _actionIconColor),
                    tooltip: 'Wadaag',
                    onPressed: () {
                      Share.share(
                        '${ayah.arabicText}\n\n${ayah.somaliTranslation}\n\n[Suurada ${_currentSurah.somaliName} : Aayadda ${ayah.ayahNumber}]\nQur\'aanka Kariimka',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 1. Quranic Arabic Text (Right Aligned, Explicit RTL Alignment, Beautiful Amiri Typography)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.arabicText,
              textAlign: TextAlign.right,
              style: AppTypography.arabic(
                fontSize: _arabicFontSize,
                fontWeight: FontWeight.bold,
                color: _arabicTextColor,
                lineHeight: 1.85,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Subtle Divider between Arabic and Somali
          Divider(color: _dividerColor, height: 1),

          const SizedBox(height: 10),

          // 2. Somali Translation directly underneath (LTR, High Contrast, Readable)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              ayah.somaliTranslation,
              textAlign: TextAlign.left,
              style: AppTypography.sans(
                fontSize: _somaliFontSize,
                color: _somaliTextColor,
                lineHeight: 1.55,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Surah End Summary Card
  Widget _buildSurahEndCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: QuranTheme.cardRadius,
        border: Border.all(color: _dividerColor),
        boxShadow: QuranTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: _accentColor, size: 30),
          const SizedBox(height: 8),
          Text(
            'Waxaad dhamaysatay Suurada ${_currentSurah.somaliName}',
            style: AppTypography.sans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _arabicTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentSurah.versesCount} Aayadood oo barakeysan',
            style: AppTypography.sans(fontSize: 12, color: _somaliTextColor),
          ),
          if (_currentSurah.number < 114) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: QuranTheme.buttonRadius),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                'U gudub Suurada xigta (${QuranData.allSurahs[_currentSurah.number].somaliName})',
                style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _changeSurah(QuranData.allSurahs[_currentSurah.number]);
              },
            ),
          ],
        ],
      ),
    );
  }

  // Source Attribution Card (QuranEnc & Tanzil)
  Widget _buildSourceAttributionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: QuranTheme.cardRadius,
        border: Border.all(color: _dividerColor),
        boxShadow: QuranTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 16, color: _accentColor),
              const SizedBox(width: 6),
              Text(
                'Data Sources & Attribution',
                style: AppTypography.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _arabicTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Somali Translation: QuranEnc.com (Sheikh Mahmud Muhammad Abduh / Yacob). '
            'Free for non-commercial distribution and spreading Islamic knowledge.\n'
            '• Quran Script (Uthmani Script): Tanzil Project (tanzil.net) under Creative Commons Attribution 3.0 License.',
            style: AppTypography.sans(
              fontSize: 11,
              color: _somaliTextColor,
              lineHeight: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Bottom Navigation Bar (Previous Surah, Jump, Next Surah)
  Widget _buildBottomNavigationBar() {
    final hasPrev = _currentSurah.number > 1;
    final hasNext = _currentSurah.number < 114;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: _dividerColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Surah Button
            TextButton.icon(
              onPressed: hasPrev
                  ? () => _changeSurah(QuranData.allSurahs[_currentSurah.number - 2])
                  : null,
              icon: const Icon(Icons.chevron_left, size: 20),
              label: Text(
                'Hore',
                style: AppTypography.sans(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: hasPrev ? _accentColor : _somaliTextColor.withOpacity(0.35),
              ),
            ),

            // Jump to Ayah Pill
            ActionChip(
              avatar: Icon(Icons.pin_drop, size: 16, color: _accentColor),
              label: Text(
                'Aayadaha (1 - ${_currentSurah.versesCount})',
                style: AppTypography.sans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: _arabicTextColor,
                ),
              ),
              backgroundColor: _badgeBgColor.withOpacity(0.5),
              side: BorderSide(color: _badgeBorderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              onPressed: () => _showJumpToAyahDialog(context),
            ),

            // Next Surah Button
            TextButton.icon(
              onPressed: hasNext
                  ? () => _changeSurah(QuranData.allSurahs[_currentSurah.number])
                  : null,
              label: Text(
                'Xigta',
                style: AppTypography.sans(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.chevron_right, size: 20),
              style: TextButton.styleFrom(
                foregroundColor: hasNext ? _accentColor : _somaliTextColor.withOpacity(0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Typography & Theme Settings Bottom Sheet
  void _showTypographySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _somaliTextColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Habaynta Akhriska Qur\'aanka',
                        style: AppTypography.sans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _arabicTextColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final nav = Navigator.of(ctx);
                          final storage = await StorageService.getInstance();
                          await storage.setQuranArabicFontSize(26.0);
                          await storage.setQuranSomaliFontSize(15.0);
                          await storage.setQuranReaderTheme('serene');
                          if (!mounted) return;
                          setState(() {
                            _arabicFontSize = 26.0;
                            _somaliFontSize = 15.0;
                            _themeMode = QuranThemeMode.serene;
                          });
                          nav.pop();
                        },
                        child: Text('Dib u celi', style: TextStyle(color: _accentColor, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Live Preview Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.right,
                          style: AppTypography.arabic(
                            fontSize: _arabicFontSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: _arabicTextColor,
                            lineHeight: 1.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Magaca Eebbe yaan ku bilaabaynaa ee Naxariis guud iyo mid gaaraba Naxariista.',
                          style: AppTypography.sans(
                            fontSize: _somaliFontSize * 0.9,
                            color: _somaliTextColor,
                            lineHeight: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Reading Theme Selection
                  Text(
                    'Midabka Shaashadda (Theme)',
                    style: AppTypography.sans(fontSize: 13, fontWeight: FontWeight.bold, color: _arabicTextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildThemeOption(
                        title: 'Aasaasi (Serene)',
                        mode: QuranThemeMode.serene,
                        color: QuranTheme.background,
                        textColor: QuranTheme.textDark,
                        onTap: () async {
                          final storage = await StorageService.getInstance();
                          await storage.setQuranReaderTheme('serene');
                          if (context.mounted) {
                            Provider.of<SettingsProvider>(context, listen: false).setThemeMode('light');
                          }
                          setSheetState(() => _themeMode = QuranThemeMode.serene);
                          setState(() => _themeMode = QuranThemeMode.serene);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        title: 'Cad (Light)',
                        mode: QuranThemeMode.light,
                        color: Colors.white,
                        textColor: const Color(0xFF0F172A),
                        onTap: () async {
                          final storage = await StorageService.getInstance();
                          await storage.setQuranReaderTheme('light');
                          if (context.mounted) {
                            Provider.of<SettingsProvider>(context, listen: false).setThemeMode('light');
                          }
                          setSheetState(() => _themeMode = QuranThemeMode.light);
                          setState(() => _themeMode = QuranThemeMode.light);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildThemeOption(
                        title: 'Madow (Night)',
                        mode: QuranThemeMode.night,
                        color: const Color(0xFF131417),
                        textColor: Colors.white,
                        onTap: () async {
                          final storage = await StorageService.getInstance();
                          await storage.setQuranReaderTheme('night');
                          if (context.mounted) {
                            Provider.of<SettingsProvider>(context, listen: false).setThemeMode('dark');
                          }
                          setSheetState(() => _themeMode = QuranThemeMode.night);
                          setState(() => _themeMode = QuranThemeMode.night);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Arabic Font Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Farta Carabiga', style: AppTypography.sans(fontSize: 13, color: _arabicTextColor)),
                      Text('${_arabicFontSize.toInt()} pt', style: AppTypography.sans(fontWeight: FontWeight.bold, color: _accentColor)),
                    ],
                  ),
                  Slider(
                    min: 20.0,
                    max: 38.0,
                    divisions: 9,
                    activeColor: _accentColor,
                    value: _arabicFontSize,
                    onChanged: (val) async {
                      setSheetState(() => _arabicFontSize = val);
                      setState(() => _arabicFontSize = val);
                      final storage = await StorageService.getInstance();
                      await storage.setQuranArabicFontSize(val);
                    },
                  ),

                  // Somali Translation Font Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Farta Tarjumada Soomaaliga', style: AppTypography.sans(fontSize: 13, color: _arabicTextColor)),
                      Text('${_somaliFontSize.toInt()} pt', style: AppTypography.sans(fontWeight: FontWeight.bold, color: _accentColor)),
                    ],
                  ),
                  Slider(
                    min: 12.0,
                    max: 22.0,
                    divisions: 10,
                    activeColor: _accentColor,
                    value: _somaliFontSize,
                    onChanged: (val) async {
                      setSheetState(() => _somaliFontSize = val);
                      setState(() => _somaliFontSize = val);
                      final storage = await StorageService.getInstance();
                      await storage.setQuranSomaliFontSize(val);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required QuranThemeMode mode,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final isSelected = _themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _accentColor : _dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.sans(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // 7. Jump to Ayah Dialog
  void _showJumpToAyahDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'U bood Aayad',
          style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.bold, color: _arabicTextColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gali lambarka aayadda (1 ilaa ${_currentSurah.versesCount}):',
              style: AppTypography.sans(fontSize: 12.5, color: _somaliTextColor),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: _arabicTextColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Tusaale: 5',
                hintStyle: TextStyle(color: _somaliTextColor.withOpacity(0.5)),
                filled: true,
                fillColor: _bgColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _dividerColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Jooji', style: TextStyle(color: _somaliTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: QuranTheme.buttonRadius),
            ),
            onPressed: () {
              final num = int.tryParse(controller.text.trim());
              if (num != null && num >= 1 && num <= _currentSurah.versesCount) {
                Navigator.pop(ctx);
                _scrollToAyah(num);
                _saveLastRead(num);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fadlan gali lambar u dhexeeya 1 iyo ${_currentSurah.versesCount}.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Bood Aayadda'),
          ),
        ],
      ),
    );
  }

  // 8. Surah Quick-Picker Sheet (Jump to any of 114 Surahs)
  void _showSurahPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = query.trim().isEmpty
                ? QuranData.allSurahs
                : QuranData.allSurahs.where((s) {
                    final q = query.toLowerCase();
                    return s.somaliName.toLowerCase().contains(q) ||
                        s.arabicName.contains(q) ||
                        s.number.toString() == q;
                  }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (ctx, scrollCtrl) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _somaliTextColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Xulo Suurad (114)',
                          style: AppTypography.sans(fontSize: 16, fontWeight: FontWeight.bold, color: _arabicTextColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: _somaliTextColor, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search box
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _dividerColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20, color: _somaliTextColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setSheetState(() => query = val);
                              },
                              style: TextStyle(color: _arabicTextColor, fontSize: 13.5),
                              decoration: InputDecoration(
                                hintText: 'Ka raadi magaca ama lambarka suuradda...',
                                hintStyle: TextStyle(color: _somaliTextColor.withOpacity(0.5), fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // List of 114 Surahs
                    Expanded(
                      child: ListView.separated(
                        controller: scrollCtrl,
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => Divider(color: _dividerColor, height: 1),
                        itemBuilder: (ctx, idx) {
                          final s = filtered[idx];
                          final isSelected = s.number == _currentSurah.number;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? _accentColor : _badgeBgColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? _accentColor : _badgeBorderColor),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${s.number}',
                                style: AppTypography.sans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : _badgeTextColor,
                                ),
                              ),
                            ),
                            title: Text(
                              s.somaliName,
                              style: AppTypography.sans(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? _accentColor : _arabicTextColor,
                              ),
                            ),
                            subtitle: Text(
                              '${s.versesCount} Aayadood • ${s.revelationType}',
                              style: AppTypography.sans(fontSize: 11, color: _somaliTextColor),
                            ),
                            trailing: Text(
                              s.arabicName,
                              style: AppTypography.arabic(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: _accentColor,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _changeSurah(s);
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
      },
    );
  }
}
