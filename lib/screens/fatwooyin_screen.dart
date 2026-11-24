import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';
import '../widgets/arabesque_pattern.dart';
import '../widgets/rub_el_hizb_icon.dart';
import '../widgets/adaptive_banner_widget.dart';

class FatwooyinScreen extends StatefulWidget {
  const FatwooyinScreen({super.key});

  @override
  State<FatwooyinScreen> createState() => _FatwooyinScreenState();
}

class _FatwooyinScreenState extends State<FatwooyinScreen> {
  bool _isNotified = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final surfaceBg = AppTheme.surface(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);
    final accentColor = AppTheme.accent(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          tooltip: 'Dib u noqo (Back)',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Fatwooyin',
          style: AppTypography.serif(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: RubElHizbIcon(
                size: 22,
                color: accentColor.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Status Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBadgeBg : AppTheme.lightBadgeBg,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: accentColor.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'QAYBTA FATWOOYINKA • SOO SOCDA',
                      style: AppTypography.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Islamic Illustration & Centerpiece Ornament
              SizedBox(
                width: 220,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Arabesque Islamic Pattern Halo
                    ArabesquePattern(
                      size: 200,
                      opacity: isDark ? 0.22 : 0.14,
                      color: accentColor,
                    ),

                    // Outer Subtle Ring
                    Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                    ),

                    // Gradient Center Core with Shadow
                    Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.heroGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(isDark ? 0.45 : 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.question_answer_rounded,
                            size: 56,
                            color: Colors.white,
                          ),
                          Positioned(
                            top: 18,
                            right: 22,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD97706),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Quranic Calligraphy Card (Surah An-Nahl: 43)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  children: [
                    Text(
                      'فَاسْأَلُوا أَهْلَ الذِّكْرِ إِن كُنتُمْ لَا تَعْلَمُونَ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.arabic(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        lineHeight: 1.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '«Weydiiya kuwa cilmiga leh haddii aydan wax ogayn» (Suuradda An-Naxl: 43)',
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Main Heading
              Text(
                'Coming Soon',
                style: AppTypography.serif(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),

              // 5. Description (Exact text required)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Islamic Fatwas and Answers to Your Important Questions Will Be Available Soon.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                    lineHeight: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Qaybta Fatwooyinka shareecada Islaamka iyo jawaabaha su\'aalahaaga diiniga ah dhawaan ayay diyaar noqon doonaan insha\'Allah.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.normal,
                    color: textMuted.withOpacity(0.85),
                    lineHeight: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 6. Preview of Upcoming Features Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
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
                        Icon(
                          Icons.stars_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Maxaa Lagu Soo Kordhin Doonaa?',
                          style: AppTypography.sans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureItem(
                      icon: Icons.article_outlined,
                      iconBg: isDark ? const Color(0xFF2E2748) : AppColors.primaryFixed,
                      iconColor: accentColor,
                      title: 'Fatwooyin Qoraal Ah (Written Fatwas)',
                      description: 'Jawaabo waafi ah oo ku saabsan Salaadda, Soonka, Zakada, Qoyska iyo Macaamilaadka.',
                      textColor: textColor,
                      textMuted: textMuted,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.mic_none_outlined,
                      iconBg: isDark ? const Color(0xFF38231E) : AppColors.tertiaryFixed,
                      iconColor: isDark ? const Color(0xFFFFB59D) : AppColors.tertiary,
                      title: 'Fatwooyin Maqal Ah (Audio Fatwas)',
                      description: 'Su\'aalo iyo jawaabo cod ah oo uu bixiyay Sheekh Xuseen Cali Jabuuti oo tayo sare leh.',
                      textColor: textColor,
                      textMuted: textMuted,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.send_rounded,
                      iconBg: isDark ? const Color(0xFF1E3A4B) : const Color(0xFFD0F0FD),
                      iconColor: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7),
                      title: 'Weydii Su\'aashaada (Submit Questions)',
                      description: 'Fursad aad si toos ah ugu gudbin karto su\'aalahaaga shareecada ee aad jawaabta u baahan tahay.',
                      textColor: textColor,
                      textMuted: textMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 7. Action Button: Ku Noqo Hoyga (Return to Home)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    label: Text(
                      'Ku Noqo Hoyga',
                      style: AppTypography.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 8. Secondary Action Button: Ila Ogeysii (Notify Me)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isNotified
                          ? const Color(0xFF10B981)
                          : accentColor.withOpacity(0.6),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: _isNotified
                        ? const Color(0xFF10B981).withOpacity(0.12)
                        : surfaceBg,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNotified = !_isNotified;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isNotified
                              ? 'Waad ku mahadsan tahay! Waxaa laguugu soo diri doonaa ogeysiin marka qaybta Fatwooyinka la furo.'
                              : 'Ogeysiiskii waa laga noqday.',
                          style: AppTypography.sans(fontSize: 13, color: Colors.white),
                        ),
                        backgroundColor: _isNotified ? const Color(0xFF10B981) : const Color(0xFF333333),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: Icon(
                    _isNotified ? Icons.check_circle_rounded : Icons.notifications_active_outlined,
                    color: _isNotified ? const Color(0xFF10B981) : accentColor,
                    size: 19,
                  ),
                  label: Text(
                    _isNotified ? 'Ogeysiinta Waa Firfircoon tahay' : 'Ila Ogeysii Marka Ay Diyaar Noqoto',
                    style: AppTypography.sans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _isNotified ? const Color(0xFF10B981) : accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AdaptiveBannerWidget(isDark: isDark),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required Color textColor,
    required Color textMuted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.sans(
                  fontSize: 11.5,
                  color: textMuted,
                  lineHeight: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
