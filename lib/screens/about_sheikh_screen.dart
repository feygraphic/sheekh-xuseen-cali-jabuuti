import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';

class AboutSheikhScreen extends StatelessWidget {
  const AboutSheikhScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Sheikh Xuseen Cali Jabuuti',
          style: AppTypography.serif(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Profile Hero Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/sheikh_hero.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, size: 20, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Sheikh Xuseen Cali Jabuuti',
                  textAlign: TextAlign.center,
                  style: AppTypography.serif(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'May Allah Preserve and Protect Him',
                  style: AppTypography.sans(
                    fontSize: 13,
                    color: AppColors.primaryFixed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Text(
                    'Islamic Scholar • Mufassir • Preacher',
                    style: AppTypography.sans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Biography
          _buildInfoCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            icon: Icons.person_outline,
            title: 'Biography',
            children: [
              Text(
                'Sheikh Xuseen Cali Jabuuti is among the most influential and widely revered contemporary Islamic scholars in the Somali-speaking world. He is universally recognized for his dedication to spreading authentic Islamic knowledge, Quranic exegesis (Tafseer), and heart-touching moral admonitions.',
                style: AppTypography.sans(fontSize: 13.5, color: textColor, lineHeight: 1.55),
              ),
              const SizedBox(height: 10),
              Text(
                'Born and raised in the Republic of Djibouti, he embarked on his pursuit of sacred knowledge at an early age, memorizing the Holy Quran and mastering the fundamentals of classical Arabic and foundational Islamic sciences under the tutelage of respected regional scholars.',
                style: AppTypography.sans(fontSize: 13.5, color: textMuted, lineHeight: 1.55),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Islamic Education
          _buildInfoCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            icon: Icons.school_outlined,
            title: 'Islamic Education',
            children: [
              Text(
                'Sheikh Xuseen Cali Jabuuti acquired extensive classical Islamic jurisprudence (Fiqh), Prophetic traditions (Hadith), Islamic creed (Aqeedah), and Quranic sciences from renowned senior scholars.',
                style: AppTypography.sans(fontSize: 13.5, color: textColor, lineHeight: 1.55),
              ),
              const SizedBox(height: 10),
              Text(
                'His academic and spiritual journey included rigorous advanced studies in the esteemed centers of Islamic learning in Makkah Al-Mukarramah and Al-Madinah Al-Munawwarah. This comprehensive grounding empowered him with a profound command of Islamic heritage, enabling him to teach complex religious disciplines with clarity and accessibility.',
                style: AppTypography.sans(fontSize: 13.5, color: textMuted, lineHeight: 1.55),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Scholarly Contributions
          _buildInfoCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            icon: Icons.auto_stories_outlined,
            title: 'Scholarly Contributions',
            children: [
              _buildFeatureItem(
                icon: Icons.menu_book,
                title: 'Comprehensive Quranic Tafseer',
                desc: 'A complete, verse-by-verse commentary of the Holy Quran, translated and explained in clear, lucid language accessible to scholars and laypersons alike.',
                textColor: textColor,
                textMuted: textMuted,
              ),
              const Divider(height: 18),
              _buildFeatureItem(
                icon: Icons.library_books_outlined,
                title: 'Classical Text Expositions',
                desc: 'Detailed series explaining core classical texts including Riyadh as-Saliheen, Bulugh al-Maram, and foundational manuals of Islamic jurisprudence.',
                textColor: textColor,
                textMuted: textMuted,
              ),
              const Divider(height: 18),
              _buildFeatureItem(
                icon: Icons.podcasts,
                title: 'Extensive Lecture Archive',
                desc: 'Hundreds of lectures covering faith purification, the reality of the Hereafter, Islamic ethics, righteous companionship, and supplications.',
                textColor: textColor,
                textMuted: textMuted,
              ),
              const Divider(height: 18),
              _buildFeatureItem(
                icon: Icons.family_restroom,
                title: 'Family & Social Guidance',
                desc: 'Dedicated pastoral counsel addressing contemporary marital harmony, righteous child-rearing, youth mentorship, and communal unity.',
                textColor: textColor,
                textMuted: textMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Dawah and Teaching Journey
          _buildInfoCard(
            cardBg: cardBg,
            borderColor: borderColor,
            textColor: textColor,
            textMuted: textMuted,
            icon: Icons.public,
            title: 'Dawah and Teaching Journey',
            children: [
              Text(
                'Over decades of persistent service, Sheikh Xuseen Cali Jabuuti has delivered sermons, organized educational seminars, and led public teaching across Djibouti, Somalia, Kenya, Ethiopia, and throughout the global Somali diaspora.',
                style: AppTypography.sans(fontSize: 13.5, color: textColor, lineHeight: 1.55),
              ),
              const SizedBox(height: 10),
              Text(
                'His methodology is characterized by profound wisdom, gentle admonition, patient engagement, and steadfast adherence to the Quran and authentic Prophetic Sunnah according to the understanding of the righteous early generations (Salaf as-Salih).',
                style: AppTypography.sans(fontSize: 13.5, color: textMuted, lineHeight: 1.55),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volunteer_activism_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All audio lectures, Tafseer lessons, and religious resources in this application are preserved and provided free of charge for the universal benefit of the Muslim Ummah.',
                        style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.serif(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String desc,
    required Color textColor,
    required Color textMuted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.sans(fontSize: 12.5, color: textMuted, lineHeight: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
