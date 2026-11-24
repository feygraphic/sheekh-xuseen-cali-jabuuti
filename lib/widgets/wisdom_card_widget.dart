import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/islamic_wisdom_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/arabesque_pattern.dart';
import '../widgets/rub_el_hizb_icon.dart';

class WisdomCardWidget extends StatelessWidget {
  final IslamicWisdomModel wisdom;
  final bool isFeatured;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const WisdomCardWidget({
    super.key,
    required this.wisdom,
    this.isFeatured = false,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final fav = Provider.of<FavoritesProvider>(context);
    final isDark = settings.isDarkMode;

    final isBookmarked = fav.isWisdomBookmarked(wisdom.id);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textSub = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    // Dynamic gradient accents based on backgroundTheme
    final gradients = [
      AppColors.heroGradient,
      const LinearGradient(
        colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF92400E), Color(0xFFB45309), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    final themeGradient = gradients[wisdom.backgroundTheme % gradients.length];

    if (isFeatured) {
      return _buildFeaturedCard(
        context,
        fav,
        isDark,
        isBookmarked,
        themeGradient,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBookmarked ? accentColor.withOpacity(0.5) : borderColor,
          width: isBookmarked ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Arabesque corner pattern
          Positioned(
            right: -25,
            top: -25,
            child: ArabesquePattern(
              size: 130,
              opacity: isDark ? 0.12 : 0.06,
              color: accentColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Category Tag & Era Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBadgeBg : AppTheme.lightBadgeBg,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: accentColor.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RubElHizbIcon(size: 12, color: accentColor),
                          const SizedBox(width: 5),
                          Text(
                            wisdom.categoryName,
                            style: AppTypography.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTypeBadge(wisdom.type, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Arabic Text (Amiri Font, Center Aligned, RTL)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161524)
                        : AppColors.surfaceContainerLow.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    wisdom.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.arabic(
                      fontSize: 18.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF812803),
                      lineHeight: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Somali Translation
                Text(
                  '« ${wisdom.somali} »',
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    lineHeight: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Divider with Rub El Hizb
                Row(
                  children: [
                    Expanded(child: Divider(color: borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: RubElHizbIcon(
                        size: 14,
                        color: accentColor.withOpacity(0.6),
                      ),
                    ),
                    Expanded(child: Divider(color: borderColor)),
                  ],
                ),
                const SizedBox(height: 12),

                // Speaker and Reference Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: themeGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          wisdom.type == 'xadiis'
                              ? Icons.auto_awesome
                              : Icons.person_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wisdom.speaker,
                            style: AppTypography.sans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (wisdom.speakerTitle.isNotEmpty)
                            Text(
                              wisdom.speakerTitle,
                              style: AppTypography.sans(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: textSub,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 12,
                                color: isDark ? const Color(0xFFFBBF24) : AppColors.tertiaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  wisdom.reference,
                                  style: AppTypography.sans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFFFBBF24) : AppColors.tertiaryContainer,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Bar: Share, Copy, Bookmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Copy Button
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      color: textSub,
                      tooltip: 'Nuuxi Hadalka (Copy)',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '${wisdom.arabic}\n\n"${wisdom.somali}"\n\n- ${wisdom.speaker} (${wisdom.reference})'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Xikmadda waa la nuuxiyay!',
                              style: AppTypography.sans(fontSize: 13, color: Colors.white),
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),

                    // Share Button
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18),
                      color: textSub,
                      tooltip: 'La Wadaag (Share)',
                      onPressed: () {
                        final shareText = """
✨ HIKMAD IYO HADAL QAALI AH ✨

« ${wisdom.arabic} »

"${wisdom.somali}"

🎙️ Hadalkii: ${wisdom.speaker}
📌 Maqaamka: ${wisdom.speakerTitle}
📖 Xigashada: ${wisdom.reference}
🏷️ Qaybta: ${wisdom.categoryName}

📱 Laga soo xigtay: App-ka Sheekh Xuseen Cali Jabuuti
                        """.trim();
                        Share.share(shareText);
                      },
                    ),

                    // Bookmark Button
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: isBookmarked ? const Color(0xFFEF4444) : textSub,
                      ),
                      tooltip: isBookmarked ? 'Ka Saar Kaydka' : 'Ku Kaydi',
                      onPressed: () {
                        fav.toggleWisdomBookmark(wisdom.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked
                                  ? 'Waa laga saaray kaydkaaga.'
                                  : 'Waa lagu daray xikmadahaaga kaydsan!',
                              style: AppTypography.sans(fontSize: 13, color: Colors.white),
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
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

  // Featured Daily Wisdom Card with Rich Hero Gradient & Previous/Next Navigation
  Widget _buildFeaturedCard(
    BuildContext context,
    FavoritesProvider fav,
    bool isDark,
    bool isBookmarked,
    LinearGradient gradient,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -30,
            top: -30,
            child: ArabesquePattern(size: 220, opacity: 0.18),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Tag Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 13, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 5),
                          Text(
                            'HIKMADDA MAANTA • DAILY WISDOM',
                            style: AppTypography.sans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? const Color(0xFFEF4444) : Colors.white,
                        size: 22,
                      ),
                      tooltip: isBookmarked ? 'Ka Saar Kaydka' : 'Ku Kaydi',
                      onPressed: () => fav.toggleWisdomBookmark(wisdom.id),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Arabic Text Calligraphy
                Text(
                  wisdom.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.arabic(
                    fontSize: 20.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    lineHeight: 1.6,
                  ),
                ),
                const SizedBox(height: 10),

                // Somali Translation
                Text(
                  '« ${wisdom.somali} »',
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.95),
                    lineHeight: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Speaker and Reference Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${wisdom.speaker} • ${wisdom.reference}',
                          style: AppTypography.sans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Bottom Controls: Previous / Next / Share
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: onPrevious,
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 12),
                      label: Text(
                        'Hore',
                        style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Share Button
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                      tooltip: 'La Wadaag',
                      onPressed: () {
                        final shareText = """
✨ HIKMAD IYO HADAL QAALI AH ✨

« ${wisdom.arabic} »

"${wisdom.somali}"

🎙️ Hadalkii: ${wisdom.speaker}
📌 Maqaamka: ${wisdom.speakerTitle}
📖 Xigashada: ${wisdom.reference}
🏷️ Qaybta: ${wisdom.categoryName}

📱 Laga soo xigtay: App-ka Sheekh Xuseen Cali Jabuuti
                        """.trim();
                        Share.share(shareText);
                      },
                    ),

                    // Next Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                      ),
                      onPressed: onNext,
                      icon: Text(
                        'Xigta',
                        style: AppTypography.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      label: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
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

  Widget _buildTypeBadge(String type, bool isDark) {
    Color badgeColor;
    String label;

    switch (type) {
      case 'xadiis':
        badgeColor = const Color(0xFF10B981);
        label = 'XADIIS SAXIIX AH';
        break;
      case 'saxaabi':
        badgeColor = const Color(0xFF8B5CF6);
        label = 'SAXAABI';
        break;
      case 'taabici':
        badgeColor = const Color(0xFFF59E0B);
        label = 'TAABICI';
        break;
      default:
        badgeColor = const Color(0xFF3B82F6);
        label = 'CAALIM SALAF AH';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: AppTypography.sans(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
