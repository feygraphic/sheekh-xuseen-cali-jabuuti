import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/reciter_selection_sheet.dart';
import '../widgets/rub_el_hizb_icon.dart';
import '../data/quran_data.dart';
import '../data/adhkar_data.dart';
import '../models/audio_category.dart';
import '../models/adkhar_model.dart';
import '../models/lecture_model.dart';
import '../models/surah_model.dart';
import '../models/ramadan_lecture.dart';

class PlayerScreen extends StatelessWidget {
  final AudioCategory? initialCategory;
  final AdkharModel? adhkar;
  final LectureModel? lecture;
  final SurahModel? surah;
  final RamadanLecture? ramadanLecture;
  final RamadanScholar? ramadanScholar;

  const PlayerScreen({
    super.key,
    this.initialCategory,
    this.adhkar,
    this.lecture,
    this.surah,
    this.ramadanLecture,
    this.ramadanScholar,
  });

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);
    final fav = Provider.of<FavoritesProvider>(context);
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;

    // Determine active audio category
    final category = initialCategory ?? audio.currentCategory;
    final isAdhkar = category == AudioCategory.adhkar ||
        (initialCategory == null && audio.currentAdhkar != null);
    final isQuran = category == AudioCategory.quran ||
        (initialCategory == null &&
            ((audio.isQuranStreaming && audio.currentQuranSurah != null) ||
                audio.currentSurah != null));
    final isRamadan = category == AudioCategory.ramadan ||
        (initialCategory == null && audio.currentRamadanLecture != null);

    // Active item resolution
    final activeAdhkar = adhkar ?? audio.currentAdhkar;
    final activeLecture = lecture ?? audio.currentLecture;
    final activeRamadanLecture = ramadanLecture ?? audio.currentRamadanLecture;
    final activeRamadanScholar = ramadanScholar ?? audio.currentRamadanScholar;

    // Item ID for bookmarking & download tracking
    final String currentId;
    if (isAdhkar) {
      currentId = activeAdhkar?.id ?? 'adhkar_01';
    } else if (isQuran) {
      currentId = 'quran_${audio.currentQuranSurah?.number ?? 1}';
    } else if (isRamadan) {
      currentId = activeRamadanLecture?.id ?? 'ramadan_01';
    } else {
      currentId = activeLecture?.id ?? 'lec_01';
    }

    // Favorite state
    final bool isFavorite;
    if (isAdhkar) {
      isFavorite = fav.isAdhkarBookmarked(currentId);
    } else if (isQuran) {
      isFavorite = audio.currentQuranSurah != null &&
          fav.isSurahBookmarked(audio.currentQuranSurah!.number);
    } else {
      isFavorite = fav.isLectureBookmarked(currentId);
    }

    final isDownloaded = isQuran ? false : fav.isDownloaded(currentId);

    // Duration and Progress
    final currentSeconds = audio.position.inSeconds;
    final totalSeconds = audio.duration.inSeconds > 0
        ? audio.duration.inSeconds
        : (isQuran ? 180 : (isAdhkar ? 60 : (45 * 60 + 30)));

    // Category-specific metadata mapping
    final String categoryBadgeLabel;
    final String seriesName;
    final int trackNum;
    final int totalTracks;
    final String trackPillLabel;
    final String somaliTitle;
    final String arabicTitle;
    final String speakerLabel;
    final IconData speakerIcon;
    final String verifiedBadgeText;
    final IconData verifiedBadgeIcon;
    final String artworkPath = audio.currentImage;

    if (isAdhkar) {
      categoryBadgeLabel = 'ADKAAR & DUCOOYIN';
      seriesName = activeAdhkar?.category ?? 'Ducooyinka & Xuska Alle';
      final playlist = audio.adhkarPlaylist.isNotEmpty ? audio.adhkarPlaylist : AdhkarData.allAdhkar;
      final foundIdx = activeAdhkar != null ? playlist.indexWhere((a) => a.id == activeAdhkar.id) : -1;
      trackNum = foundIdx != -1 ? foundIdx + 1 : 1;
      totalTracks = playlist.isNotEmpty ? playlist.length : 45;
      trackPillLabel = '● ${seriesName.toUpperCase()} • DUCO $trackNum OF $totalTracks';
      somaliTitle = activeAdhkar?.title ?? 'Duco & Adkaar';
      arabicTitle = activeAdhkar?.arabicTitle ??
          (activeAdhkar != null ? activeAdhkar.arabicText.split('\n').first.trim() : 'أَذْكَارُ الْمُسْلِمِ');
      speakerLabel = 'Duco Saxiix ah • ${activeAdhkar?.reference ?? "Xadiis & Sunno"}';
      speakerIcon = Icons.auto_awesome_rounded;
      verifiedBadgeText = 'Adkaar Saxiix ah';
      verifiedBadgeIcon = Icons.spa_rounded;
    } else if (isQuran) {
      categoryBadgeLabel = 'QUR\'AANKA KARIIMKA';
      seriesName = 'MP3Quran Online Recitation';
      trackNum = audio.currentQuranSurah?.number ?? 1;
      totalTracks = 114;
      trackPillLabel = '● SUURADA $trackNum EE $totalTracks • ${audio.currentReciter.nameEn.toUpperCase()}';
      somaliTitle = 'Suurada ${audio.currentQuranSurah?.somaliName ?? ""}';
      arabicTitle = audio.currentQuranSurah?.arabicName ?? '';
      speakerLabel = 'Qaariga: ${audio.currentReciter.nameEn}';
      speakerIcon = Icons.record_voice_over_rounded;
      verifiedBadgeText = 'Qiraa\'o Toos ah';
      verifiedBadgeIcon = Icons.menu_book_rounded;
    } else if (isRamadan) {
      categoryBadgeLabel = 'RAMADAAN MUXAADARO';
      seriesName = activeRamadanScholar?.title ?? 'Taxanaha Bisha Ramadaan';
      final playlist = audio.ramadanPlaylist;
      trackNum = activeRamadanLecture?.sortOrder ?? 1;
      totalTracks = playlist.isNotEmpty ? playlist.length : 10;
      trackPillLabel = '● ${(activeRamadanScholar?.name ?? "RAMADAAN").toUpperCase()} • MUXAADARO $trackNum OF $totalTracks';
      somaliTitle = activeRamadanLecture?.displayTitle ?? 'Muxaadaro Ramadaan';
      arabicTitle = activeRamadanScholar?.arabicTitle ?? 'رمضان المبارك';
      speakerLabel = 'Sheekh: ${activeRamadanScholar?.name ?? "Muxaadaro"}';
      speakerIcon = Icons.person_rounded;
      verifiedBadgeText = 'Muxaadaro Ramadaan';
      verifiedBadgeIcon = Icons.bedtime_rounded;
    } else {
      categoryBadgeLabel = 'MUXAADARADA';
      seriesName = activeLecture?.seriesName ?? 'Silsiladda Caqiidada';
      trackNum = activeLecture?.trackNumber ?? 1;
      totalTracks = audio.playlist.isNotEmpty ? audio.playlist.length : 31;
      trackPillLabel = '● ${seriesName.toUpperCase()} • TRACK $trackNum OF $totalTracks';
      somaliTitle = activeLecture?.somaliTitle ?? 'Ahmiyadda Towxiidka iyo Caqiidada Saxda ah';
      arabicTitle = activeLecture?.arabicTitle ?? 'أهمية التوحيد والعقيدة الصحيحة';
      speakerLabel = activeLecture?.sheikhName ?? 'Sheekh Xuseen Cali Jabuuti';
      speakerIcon = Icons.record_voice_over_outlined;
      verifiedBadgeText = 'Sheekha Rasmiga ah';
      verifiedBadgeIcon = Icons.verified;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.bg(isDark),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top App Bar (Dynamic for Theme)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Back button with circular dashed outline
                    CustomPaint(
                      painter: DashedCirclePainter(
                        color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.55),
                        strokeWidth: 1.5,
                        dashes: 14,
                        gapRatio: 0.35,
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppTheme.icon(isDark),
                          ),
                          tooltip: 'Dib u noqo',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // App Emblem & Title
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.badgeBg(isDark),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: RubElHizbIcon(
                              size: 19,
                              color: isDark ? AppTheme.primaryLight : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Faahfaahinta Codka',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.text(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Share Button
                    IconButton(
                      icon: Icon(
                        Icons.share_outlined,
                        size: 22,
                        color: AppTheme.icon(isDark),
                      ),
                      tooltip: 'Wadaag',
                      onPressed: () => _shareCurrent(
                        audio,
                        isAdhkar: isAdhkar,
                        isQuran: isQuran,
                        isRamadan: isRamadan,
                        mainTitle: somaliTitle,
                        speakerLabel: speakerLabel,
                      ),
                    ),

                    // Reciter, Sheikh or Adhkar Avatar
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          artworkPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? AppTheme.darkSecondary : AppColors.surfaceContainer,
                            alignment: Alignment.center,
                            child: Icon(
                              isAdhkar
                                  ? Icons.spa_rounded
                                  : (isQuran
                                      ? Icons.menu_book_rounded
                                      : (isRamadan ? Icons.bedtime_rounded : Icons.person_rounded)),
                              size: 18,
                              color: isDark ? AppTheme.primaryLight : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main Player Card (Player Body)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.border(isDark),
                        width: 1,
                      ),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? const [
                              Color(0xFF232128),
                              Color(0xFF191820),
                              Color(0xFF121118),
                            ]
                          : const [
                              Colors.white,
                              Color(0xFFFAF7FF),
                              Color(0xFFF3EDFF),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : AppColors.primary.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Card Header Row: Collapse Chevron, Title, Queue
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Chevron Down Button
                            CustomPaint(
                              painter: DashedCirclePainter(
                                color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.4),
                                strokeWidth: 1.3,
                                dashes: 14,
                                gapRatio: 0.35,
                              ),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF282631) : AppColors.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppTheme.icon(isDark),
                                    size: 26,
                                  ),
                                  tooltip: 'Xir',
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),

                            // Header Text
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      categoryBadgeLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.sans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textSub(isDark),
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      seriesName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.sans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Playlist / Queue Button
                            CustomPaint(
                              painter: DashedCirclePainter(
                                color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.4),
                                strokeWidth: 1.3,
                                dashes: 14,
                                gapRatio: 0.35,
                              ),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF282631) : AppColors.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isAdhkar
                                        ? Icons.format_list_bulleted_rounded
                                        : (isQuran ? Icons.menu_book_rounded : Icons.queue_music_rounded),
                                    color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                    size: 21,
                                  ),
                                  tooltip: isAdhkar
                                      ? 'Liiska Adkaarta'
                                      : (isQuran
                                          ? 'Liiska Suuradaha'
                                          : (isRamadan ? 'Liiska Ramadaanka' : 'Liiska Muxaadarooyinka')),
                                  onPressed: () => _showQueueSheet(
                                    context,
                                    audio,
                                    isQuran: isQuran,
                                    isAdhkar: isAdhkar,
                                    isRamadan: isRamadan,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Center Avatar Artwork with Glowing Ring & Verified Badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circular Glowing Ring Painter
                            CustomPaint(
                              size: const Size(206, 206),
                              painter: GlowingProgressRingPainter(
                                progressFraction: audio.progressFraction,
                                isDark: isDark,
                              ),
                            ),

                            // Portrait / Artwork Circle
                            Container(
                              width: 168,
                              height: 168,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(isDark ? 0.25 : 0.15),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  artworkPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildArtworkFallback(
                                    isAdhkar: isAdhkar,
                                    isQuran: isQuran,
                                    isRamadan: isRamadan,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            ),

                            // Verified Pill Badge (resting on bottom of circle)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                  borderRadius: BorderRadius.circular(99),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      verifiedBadgeIcon,
                                      size: 14,
                                      color: isDark ? const Color(0xFF1D0061) : Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      verifiedBadgeText,
                                      style: AppTypography.sans(
                                        color: isDark ? const Color(0xFF1D0061) : Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Track Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF26242C) : AppTheme.badgeBg(isDark),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: AppTheme.border(isDark),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            trackPillLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              color: isDark ? const Color(0xFFCBD5E1) : AppTheme.badgeText(isDark),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Main Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            somaliTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.sans(
                              color: AppTheme.text(isDark),
                              fontSize: 20.5,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.25,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Arabic Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            arabicTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.arabic(
                              fontSize: 17,
                              color: isDark ? const Color(0xFFE2E8F0) : AppColors.secondary,
                              lineHeight: 1.35,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Speaker / Reciter / Description Info
                        GestureDetector(
                          onTap: isQuran ? () => ReciterSelectionSheet.show(context) : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isQuran ? 12 : 8,
                              vertical: isQuran ? 5 : 2,
                            ),
                            decoration: isQuran
                                ? BoxDecoration(
                                    color: isDark ? const Color(0xFF26242D) : AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.35),
                                    ),
                                  )
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  speakerIcon,
                                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    speakerLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.sans(
                                      color: AppTheme.text(isDark),
                                      fontSize: 13.5,
                                      fontWeight: isQuran ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isQuran) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        if (audio.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_off, color: Color(0xFFF87171), size: 15),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    audio.errorMessage!,
                                    style: AppTypography.sans(
                                      color: const Color(0xFFFCA5A5),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isQuran)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: InkWell(
                              onTap: () => audio.setAutoPlayNextSurah(!audio.autoPlayNextSurah),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      audio.autoPlayNextSurah
                                          ? Icons.playlist_play_rounded
                                          : Icons.playlist_remove_rounded,
                                      size: 16,
                                      color: audio.autoPlayNextSurah
                                          ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                          : AppTheme.textSub(isDark),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Suuradda xigta si toos ah u daara: ${audio.autoPlayNextSurah ? "Haa" : "Maya"}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.sans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: audio.autoPlayNextSurah
                                              ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                              : AppTheme.textSub(isDark),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 14),

                        // Progress Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4.0,
                            activeTrackColor: isDark ? AppTheme.primaryLight : AppColors.primary,
                            inactiveTrackColor: isDark ? const Color(0xFF383542) : AppColors.primaryFixed,
                            thumbColor: isDark ? Colors.white : AppColors.primary,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7.5,
                            ),
                            overlayColor: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.2),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16.0,
                            ),
                          ),
                          child: Slider(
                            min: 0.0,
                            max: totalSeconds > 0 ? totalSeconds.toDouble() : 1.0,
                            value: currentSeconds
                                .toDouble()
                                .clamp(0.0, totalSeconds.toDouble()),
                            onChanged: (val) {
                              audio.seekTo(Duration(seconds: val.toInt()));
                            },
                          ),
                        ),

                        // Time & Audio Format Metadata Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(audio.position),
                                style: AppTypography.sans(
                                  color: AppTheme.textSub(isDark),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.graphic_eq,
                                        color: AppTheme.textSub(isDark),
                                        size: 15,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          isAdhkar
                                              ? 'Adkaar Audio'
                                              : (isQuran
                                                  ? 'MP3Quran Stream'
                                                  : (isRamadan ? 'Ramadan Audio' : 'MP3 High Audio')),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.sans(
                                            color: AppTheme.textSub(isDark),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                _formatDuration(audio.duration.inSeconds > 0
                                    ? audio.duration
                                    : Duration(seconds: totalSeconds)),
                                style: AppTypography.sans(
                                  color: AppTheme.textSub(isDark),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Playback Controls (Previous, Replay 10, Play/Pause, Forward 10, Next)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 26,
                              icon: Icon(
                                Icons.skip_previous_rounded,
                                color: AppTheme.icon(isDark),
                              ),
                              tooltip: isAdhkar
                                  ? 'Duco Hore'
                                  : (isQuran
                                      ? 'Suuraddii Hore'
                                      : (isRamadan ? 'Muxaadaro Hore' : 'Muxaadaradii Hore')),
                              onPressed: () => audio.playPrevious(),
                            ),
                            IconButton(
                              iconSize: 30,
                              icon: Icon(
                                Icons.replay_10_rounded,
                                color: AppTheme.icon(isDark),
                              ),
                              tooltip: '10 ilbiriqsi dib u noqo',
                              onPressed: () => audio.skipBackward(10),
                            ),
                            // Main Play/Pause Button with signature brand primary accent
                            GestureDetector(
                              onTap: () => audio.togglePlayPause(),
                              child: Container(
                                width: 66,
                                height: 66,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(isDark ? 0.45 : 0.35),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: audio.isLoading
                                    ? Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isDark ? const Color(0xFF1D0061) : Colors.white,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        audio.isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: isDark ? const Color(0xFF1D0061) : Colors.white,
                                        size: 38,
                                      ),
                              ),
                            ),
                            IconButton(
                              iconSize: 30,
                              icon: Icon(
                                Icons.forward_10_rounded,
                                color: AppTheme.icon(isDark),
                              ),
                              tooltip: '10 ilbiriqsi hore u soco',
                              onPressed: () => audio.skipForward(10),
                            ),
                            IconButton(
                              iconSize: 26,
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: AppTheme.icon(isDark),
                              ),
                              tooltip: isAdhkar
                                  ? 'Duco Xigta'
                                  : (isQuran
                                      ? 'Suuradda Xigta'
                                      : (isRamadan ? 'Muxaadaro Xigta' : 'Muxaadarada Xigta')),
                              onPressed: () => audio.playNext(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Auxiliary Deck: Speed Pill, Repeat, Sleep, Download, Share, Favorite
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Speed Pill
                            GestureDetector(
                              onTap: () => audio.toggleSpeed(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF26242D) : AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.border(isDark),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${audio.playbackSpeed}x',
                                      style: AppTypography.sans(
                                        color: AppTheme.text(isDark),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      Icons.unfold_more,
                                      color: AppTheme.icon(isDark),
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Repeat
                            IconButton(
                              iconSize: 22,
                              icon: Icon(
                                Icons.repeat,
                                color: audio.isRepeat
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : AppTheme.icon(isDark),
                              ),
                              tooltip: 'Ku celi',
                              onPressed: () => audio.toggleRepeat(),
                            ),

                            // Sleep Timer
                            IconButton(
                              iconSize: 22,
                              icon: Icon(
                                Icons.nightlight_round,
                                color: audio.sleepTimerRemainingMinutes != null
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : AppTheme.icon(isDark),
                              ),
                              tooltip: 'Waqtiga Hurdada',
                              onPressed: () => _showSleepTimerDialog(context, audio, isDark),
                            ),

                            // Download
                            IconButton(
                              iconSize: 22,
                              icon: Icon(
                                isDownloaded
                                    ? Icons.check_circle
                                    : Icons.download_for_offline_outlined,
                                color: isDownloaded
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : AppTheme.icon(isDark),
                              ),
                              tooltip: isDownloaded ? 'Degsan' : 'Degso',
                              onPressed: () => fav.toggleDownload(currentId),
                            ),

                            // Share
                            IconButton(
                              iconSize: 22,
                              icon: Icon(
                                Icons.share_outlined,
                                color: AppTheme.icon(isDark),
                              ),
                              tooltip: 'Wadaag',
                              onPressed: () => _shareCurrent(
                                audio,
                                isAdhkar: isAdhkar,
                                isQuran: isQuran,
                                isRamadan: isRamadan,
                                mainTitle: somaliTitle,
                                speakerLabel: speakerLabel,
                              ),
                            ),

                            // Favorite
                            IconButton(
                              iconSize: 22,
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite
                                    ? const Color(0xFFEF4444)
                                    : AppTheme.icon(isDark),
                              ),
                              tooltip: 'Kaydi',
                              onPressed: () {
                                if (isAdhkar) {
                                  fav.toggleAdhkarBookmark(currentId);
                                } else if (isQuran) {
                                  if (audio.currentQuranSurah != null) {
                                    fav.toggleSurahBookmark(audio.currentQuranSurah!.number);
                                  }
                                } else {
                                  fav.toggleLectureBookmark(currentId);
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Bottom Peek of "Muxaadarooyinka" or "Qur'aanka Kariimka"
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            height: 32,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF201E27) : AppColors.surfaceContainerHigh,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: AppTheme.border(isDark),
                                  width: 1,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: AppTheme.textSub(isDark),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isAdhkar
                                      ? 'Liiska Adkaarta'
                                      : (isQuran
                                          ? 'Qur\'aanka Kariimka'
                                          : (isRamadan ? 'Muxaadarooyinka Ramadaanka' : 'Muxaadarooyinka')),
                                  style: AppTypography.sans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.text(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  static void _shareCurrent(
    AudioPlayerProvider audio, {
    required bool isAdhkar,
    required bool isQuran,
    required bool isRamadan,
    required String mainTitle,
    required String speakerLabel,
  }) {
    if (isAdhkar && audio.currentAdhkar != null) {
      final a = audio.currentAdhkar!;
      Share.share(
        'Duco & Adkaar: ${a.title}\n${a.arabicText}\n${a.somaliTranslation}\n\nXigasho: ${a.reference}\nKa dhageyso App-ka Sheekh Xuseen Cali Jabuuti',
      );
    } else if (isQuran && audio.currentQuranSurah != null) {
      Share.share(
        'Suurada ${audio.currentQuranSurah!.somaliName} - Qaariga: ${audio.currentReciter.nameEn}\nKa dhageyso App-ka Sheekh Xuseen Cali Jabuuti',
      );
    } else if (isRamadan && audio.currentRamadanLecture != null) {
      final r = audio.currentRamadanLecture!;
      Share.share(
        'Muxaadarada Ramadaanka: ${r.displayTitle} - ${audio.currentRamadanScholar?.name ?? ""}\n${r.youtubeUrl}\nKa dhageyso App-ka Sheekh Xuseen Cali Jabuuti',
      );
    } else {
      Share.share(
        'Dhageyso Muxaadarada: $mainTitle - $speakerLabel:\nhttps://play.google.com/store/apps',
      );
    }
  }

  Widget _buildArtworkFallback({
    required bool isAdhkar,
    required bool isQuran,
    required bool isRamadan,
    required bool isDark,
  }) {
    return Container(
      color: isDark ? const Color(0xFF1E1C24) : AppColors.surfaceContainer,
      child: Center(
        child: Icon(
          isAdhkar
              ? Icons.spa_rounded
              : (isQuran
                  ? Icons.menu_book_rounded
                  : (isRamadan ? Icons.bedtime_rounded : Icons.person_rounded)),
          size: 72,
          color: isDark ? AppTheme.primaryLight : AppColors.primary,
        ),
      ),
    );
  }

  void _showQueueSheet(
    BuildContext context,
    AudioPlayerProvider audio, {
    required bool isQuran,
    required bool isAdhkar,
    required bool isRamadan,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(isDark),
      isScrollControlled: isQuran || isAdhkar || isRamadan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        if (isAdhkar) {
          final adhkarList = audio.adhkarPlaylist.isNotEmpty ? audio.adhkarPlaylist : AdhkarData.allAdhkar;
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
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
                          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Liiska Adkaarta (${adhkarList.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.text(isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Xuska Alle iyo Ducooyinka Saxiixa ah',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.icon(isDark), size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    Divider(color: AppTheme.divider(isDark)),
                    Expanded(
                      child: ListView.separated(
                        itemCount: adhkarList.length,
                        separatorBuilder: (_, _) => Divider(color: AppTheme.divider(isDark)),
                        itemBuilder: (ctx, idx) {
                          final item = adhkarList[idx];
                          final isCurrent = audio.currentAdhkar?.id == item.id;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : (isDark ? const Color(0xFF2C2A34) : AppColors.surfaceContainer),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: isCurrent && audio.isPlaying
                                  ? Icon(
                                      Icons.equalizer,
                                      color: isDark ? const Color(0xFF1D0061) : Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      '${idx + 1}',
                                      style: AppTypography.sans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? (isDark ? const Color(0xFF1D0061) : Colors.white)
                                            : AppTheme.text(isDark),
                                      ),
                                    ),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 13.5,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                color: isCurrent
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : AppTheme.text(isDark),
                              ),
                            ),
                            subtitle: Text(
                              '${item.category} • ${item.reference}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: AppTheme.textSub(isDark),
                              ),
                            ),
                            trailing: Icon(
                              isCurrent && audio.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_outline,
                              color: isCurrent
                                  ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                  : AppTheme.icon(isDark),
                              size: 26,
                            ),
                            onTap: () {
                              audio.playAdhkar(item);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isRamadan) {
          final ramadanList = audio.ramadanPlaylist;
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
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
                          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Muxaadarooyinka Ramadaanka (${ramadanList.length})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.text(isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                audio.currentRamadanScholar?.name ?? 'Muxaadarooyin Duuban',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.icon(isDark), size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    Divider(color: AppTheme.divider(isDark)),
                    Expanded(
                      child: ListView.separated(
                        itemCount: ramadanList.length,
                        separatorBuilder: (_, _) => Divider(color: AppTheme.divider(isDark)),
                        itemBuilder: (ctx, idx) {
                          final item = ramadanList[idx];
                          final isCurrent = audio.currentRamadanLecture?.id == item.id;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : (isDark ? const Color(0xFF2C2A34) : AppColors.surfaceContainer),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: isCurrent && audio.isPlaying
                                  ? Icon(
                                      Icons.equalizer,
                                      color: isDark ? const Color(0xFF1D0061) : Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      '${item.sortOrder}',
                                      style: AppTypography.sans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? (isDark ? const Color(0xFF1D0061) : Colors.white)
                                            : AppTheme.text(isDark),
                                      ),
                                    ),
                            ),
                            title: Text(
                              item.displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 13.5,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                color: isCurrent
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : AppTheme.text(isDark),
                              ),
                            ),
                            subtitle: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: AppTheme.textSub(isDark),
                              ),
                            ),
                            trailing: Icon(
                              isCurrent && audio.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_outline,
                              color: isCurrent
                                  ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                  : AppTheme.icon(isDark),
                              size: 26,
                            ),
                            onTap: () {
                              audio.playRamadanLecture(item, scholar: audio.currentRamadanScholar);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isQuran) {
          final surahs = QuranData.allSurahs;
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
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
                          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Liiska Suuradaha (114)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.text(isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Qaariga: ${audio.currentReciter.nameEn}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.icon(isDark), size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    Divider(color: AppTheme.divider(isDark)),
                    Expanded(
                      child: ListView.separated(
                        itemCount: surahs.length,
                        separatorBuilder: (_, _) => Divider(color: AppTheme.divider(isDark)),
                        itemBuilder: (ctx, idx) {
                          final surah = surahs[idx];
                          final isCurrent = audio.currentQuranSurah?.number == surah.number;
                          final isStreaming = audio.isSurahStreaming(surah.number);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : (isDark ? const Color(0xFF2C2A34) : AppColors.surfaceContainer),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: isStreaming
                                  ? Icon(
                                      Icons.equalizer,
                                      color: isCurrent && isDark ? const Color(0xFF1D0061) : Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      '${surah.number}',
                                      style: AppTypography.sans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? (isDark ? const Color(0xFF1D0061) : Colors.white)
                                            : AppTheme.text(isDark),
                                      ),
                                    ),
                            ),
                            title: Text(
                              surah.somaliName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 13.5,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                color: isCurrent
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : AppTheme.text(isDark),
                              ),
                            ),
                            subtitle: Text(
                              '${surah.meaning} • ${surah.versesCount} Aayadood',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.sans(
                                fontSize: 11,
                                color: AppTheme.textSub(isDark),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  surah.arabicName,
                                  style: AppTypography.arabic(
                                    fontSize: 15,
                                    color: isCurrent
                                        ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                        : (isDark ? const Color(0xFFE2E8F0) : AppColors.secondary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isStreaming
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_outline,
                                  color: isCurrent
                                      ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                      : AppTheme.icon(isDark),
                                  size: 26,
                                ),
                              ],
                            ),
                            onTap: () {
                              audio.playQuranSurah(surah);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final playlist = audio.playlist;
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
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Liiska Muxaadarooyinka (${playlist.length})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sans(
                          fontSize: 16,
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
                    itemCount: playlist.length,
                    separatorBuilder: (_, _) => Divider(color: AppTheme.divider(isDark)),
                    itemBuilder: (ctx, idx) {
                      final lec = playlist[idx];
                      final isCurrent = audio.currentLecture?.id == lec.id;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                : (isDark ? const Color(0xFF2C2A34) : AppColors.surfaceContainer),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isCurrent
                              ? Icon(
                                  Icons.equalizer,
                                  color: isDark ? const Color(0xFF1D0061) : Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  '${lec.trackNumber}',
                                  style: AppTypography.sans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? (isDark ? const Color(0xFF1D0061) : Colors.white)
                                        : AppTheme.text(isDark),
                                  ),
                                ),
                        ),
                        title: Text(
                          lec.somaliTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sans(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent
                                ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                : AppTheme.text(isDark),
                          ),
                        ),
                        subtitle: Text(
                          '${lec.arabicTitle} • ${lec.durationString} daqiiqo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sans(
                            fontSize: 11,
                            color: AppTheme.textSub(isDark),
                          ),
                        ),
                        trailing: Icon(
                          isCurrent ? Icons.pause_circle : Icons.play_circle_outline,
                          color: isCurrent
                              ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                              : AppTheme.icon(isDark),
                          size: 24,
                        ),
                        onTap: () {
                          audio.playLecture(lec);
                          Navigator.pop(ctx);
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

  void _showSleepTimerDialog(BuildContext context, AudioPlayerProvider audio, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card(isDark),
        title: Text(
          'Waqtiga Hurdada (Sleep Timer)',
          style: AppTypography.serif(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.text(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mins in [15, 30, 45, 60])
              ListTile(
                title: Text(
                  '$mins Daqiiqo Kadib',
                  style: TextStyle(color: AppTheme.text(isDark)),
                ),
                trailing: audio.sleepTimerRemainingMinutes == mins
                    ? Icon(Icons.check, color: isDark ? AppTheme.primaryLight : AppColors.primary)
                    : null,
                onTap: () {
                  audio.setSleepTimer(mins);
                  Navigator.pop(ctx);
                },
              ),
            if (audio.sleepTimerRemainingMinutes != null)
              ListTile(
                title: const Text(
                  'Dami (Cancel Timer)',
                  style: TextStyle(color: Color(0xFFEF4444)),
                ),
                onTap: () {
                  audio.cancelSleepTimer();
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Dashed Circle Stroke Painter for the rounded back, collapse, and playlist buttons
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;
  final double gapRatio;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashes = 14,
    this.gapRatio = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final totalAngle = 2 * math.pi;
    final dashAngle = (totalAngle / dashes) * (1 - gapRatio);
    final gapAngle = (totalAngle / dashes) * gapRatio;

    double currentAngle = -math.pi / 2;
    for (int i = 0; i < dashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashes != dashes ||
        oldDelegate.gapRatio != gapRatio;
  }
}

/// Painter for the glowing avatar ring with themed progress arc and indicator
class GlowingProgressRingPainter extends CustomPainter {
  final double progressFraction;
  final bool isDark;

  GlowingProgressRingPainter({
    required this.progressFraction,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // 1. Base track ring
    final basePaint = Paint()
      ..color = isDark ? const Color(0xFF2E2C37) : AppColors.primaryFixed.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius, basePaint);

    // 2. Glowing Arc (using brand primary purple)
    final arcColor = isDark ? AppTheme.primaryLight : AppColors.primary;

    final glowPaint = Paint()
      ..color = arcColor.withOpacity(isDark ? 0.4 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    // Progress arc from ~12:30 to 3:30 (about -pi/12 to ~0.65 pi)
    const startAngle = -math.pi / 12;
    const sweepAngle = math.pi * 0.65;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // 3. Glowing indicator knob at ~210 degrees (bottom-left / 7:30 clock position)
    const knobAngle = math.pi * 1.15; // ~207 degrees
    final knobX = center.dx + radius * math.cos(knobAngle);
    final knobY = center.dy + radius * math.sin(knobAngle);
    final knobCenter = Offset(knobX, knobY);

    // Outer glow
    final knobGlow = Paint()
      ..color = (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(isDark ? 0.7 : 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(knobCenter, 9, knobGlow);

    // Inner knob
    final knobFill = Paint()
      ..color = isDark ? const Color(0xFFC4B5FD) : AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(knobCenter, 7.5, knobFill);

    // White rim on knob
    final knobRim = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(knobCenter, 7.5, knobRim);
  }

  @override
  bool shouldRepaint(covariant GlowingProgressRingPainter oldDelegate) {
    return oldDelegate.progressFraction != progressFraction ||
        oldDelegate.isDark != isDark;
  }
}
