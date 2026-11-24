import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../data/sample_data.dart';
import '../models/lecture_model.dart';
import '../providers/settings_provider.dart';
import '../providers/audio_player_provider.dart';
import '../services/ad_service.dart';
import '../widgets/adaptive_banner_widget.dart';
import '../widgets/arabesque_pattern.dart';
import 'search_screen.dart';
import 'lecture_list_screen.dart';

class CategoryItemData {
  final int? number; // null for Dhammaan
  final String title;
  final String subtitle;
  final String arabicTitle;
  final int count;
  final IconData icon;

  const CategoryItemData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.arabicTitle,
    required this.count,
    required this.icon,
  });
}

class LecturesScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback? onBack;

  const LecturesScreen({
    super.key,
    required this.onOpenDrawer,
    this.onBack,
  });

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryItemData> _getDynamicCategories() {
    final all = SampleData.lectures;

    // Group dynamically from actual CSV lectures data
    final Map<int, List<LectureModel>> grouped = {};
    for (final lec in all) {
      grouped.putIfAbsent(lec.seriesNumber, () => []).add(lec);
    }

    final categoryNames = {
      1: 'Muxaadarooyinka Guud',
      2: 'Akhlaaqda & Barbaarinta',
      3: 'Quluubta & Iimaanka',
      4: 'Duruusta & Waanooyinka',
      5: 'Towxiidka & Cilmiga',
      6: 'Tilmaamaha Mu\'miniinta',
      7: 'Qisooyin Cajiib ah',
      8: 'Xusuusashada Aakhiro',
      9: 'Qisooyinka Saxaabada',
      10: 'Dardaaran & Waano',
    };

    final categoryArabic = {
      1: 'محاضرات عامة ودعوة',
      2: 'الأخلاق والتربية الإسلامية',
      3: 'أعمال القلوب وحلاوة الإيمان',
      4: 'دروس ومواعظ بليغة',
      5: 'التوحيد وأصول العقيدة',
      6: 'صفات المؤمنين الصادقين',
      7: 'قصص الأنبياء والصالحين',
      8: 'أهوال القيامة وذكر الموت',
      9: 'سير الصحابة والصحابيات',
      10: 'وصايا جامعة ونصائح نافعة',
    };

    final categoryIcons = {
      1: Icons.mic_rounded,
      2: Icons.family_restroom_rounded,
      3: Icons.favorite_rounded,
      4: Icons.auto_stories_rounded,
      5: Icons.menu_book_rounded,
      6: Icons.verified_rounded,
      7: Icons.history_edu_rounded,
      8: Icons.hourglass_bottom_rounded,
      9: Icons.groups_rounded,
      10: Icons.format_quote_rounded,
    };

    final List<CategoryItemData> list = [];

    // Category 0: Dhammaan Muxaadarooyinka (All 131)
    list.add(
      CategoryItemData(
        number: null,
        title: 'Dhammaan Muxaadarooyinka',
        subtitle: 'Dhammaan 131-ka muxaadaro oo dhammaystiran',
        arabicTitle: 'جميع المحاضرات والدروس الإسلامية',
        count: all.length,
        icon: Icons.all_inclusive_rounded,
      ),
    );

    // Categories 1 to 10
    final sortedKeys = grouped.keys.toList()..sort();
    for (final catNum in sortedKeys) {
      final subList = grouped[catNum]!;
      list.add(
        CategoryItemData(
          number: catNum,
          title: 'Qaybta ${catNum}aad',
          subtitle: categoryNames[catNum] ?? subList.first.seriesName,
          arabicTitle: categoryArabic[catNum] ?? 'محاضرات الشيخ حسين علي',
          count: subList.length,
          icon: categoryIcons[catNum] ?? Icons.podcasts_rounded,
        ),
      );
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      return list.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.subtitle.toLowerCase().contains(q) ||
            c.arabicTitle.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  void _navigateToCategory(BuildContext context, CategoryItemData cat) {
    final audio = Provider.of<AudioPlayerProvider>(context, listen: false);
    AdService().showInterstitialAd(
      isAudioPlaying: audio.isPlaying,
      onDismissed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => LectureListScreen(
              categoryNumber: cat.number,
              categoryTitle: cat.title,
              categorySubtitle: cat.subtitle,
              categoryArabic: cat.arabicTitle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final cardBg = AppTheme.card(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    final categories = _getDynamicCategories();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.92),
            border: Border(bottom: BorderSide(color: borderColor)),
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
                            color: isDark ? AppTheme.primaryLight : AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Muxaadarooyinka',
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
                  IconButton(
                    icon: Icon(Icons.share_outlined, size: 22, color: textMuted),
                    tooltip: 'Wadaag',
                    onPressed: () {
                      Share.share(
                        'Dhageyso Muxaadarooyinka Diiniga ah ee Sheekh Xuseen Cali Jabuuti (131 Qaybood): https://play.google.com/store/apps',
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
          // 1. Hero Banner Card
          _buildHeroBanner(context, isDark),
          const SizedBox(height: 16),

          // 2. Search Field
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
                      hintText: 'Raadi qaybaha muxaadarooyinka...',
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
          const SizedBox(height: 16),

          // 3. Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qaybaha Muxaadarooyinka',
                style: AppTypography.serif(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2542) : AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '10 Qaybood + Dhammaan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFEDE8F5) : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Categories Cards List
          if (categories.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'Wax qayb ah lagama helin raadintaada.',
                    style: AppTypography.sans(fontSize: 13.5, color: textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final isAll = cat.number == null;

                return _buildCategoryCard(
                  context: context,
                  cat: cat,
                  isAll: isAll,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  textMuted: textMuted,
                  isDark: isDark,
                );
              },
            ),
          const SizedBox(height: 16),
          AdaptiveBannerWidget(isDark: isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Hero Banner Card
  Widget _buildHeroBanner(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -25,
            bottom: -25,
            child: ArabesquePattern(size: 160, opacity: 0.12),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/sheikh_lectures.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'TAXANAHA GUUD',
                                style: AppTypography.sans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryFixed,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${SampleData.lectures.length} Muxaadaro',
                                style: AppTypography.sans(
                                  fontSize: 11,
                                  color: AppColors.primaryFixed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Muxaadarooyinka Diiniga Ah',
                            style: AppTypography.serif(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'مجموعة محاضرات ودروس قيمة',
                            style: AppTypography.arabic(
                              fontSize: 13,
                              color: AppColors.primaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.category_rounded, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Dooro qayb si aad codadka u dhageysato',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category Card Widget
  Widget _buildCategoryCard({
    required BuildContext context,
    required CategoryItemData cat,
    required bool isAll,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required bool isDark,
  }) {
    final cardBorderColor = isAll
        ? (isDark ? const Color(0xFF9D84FF) : AppColors.primary)
        : borderColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorderColor, width: isAll ? 1.5 : 1.0),
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
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToCategory(context, cat),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Category Avatar / Number Badge
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: isAll ? AppColors.heroGradient : null,
                    color: isAll
                        ? null
                        : (isDark ? AppTheme.darkSecondary : AppColors.primaryFixed.withOpacity(0.6)),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isAll
                      ? const Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 24)
                      : Text(
                          'Q${cat.number}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 14),

                // Category Titles & Counts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.title,
                              style: AppTypography.serif(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isAll
                                  ? (isDark ? AppTheme.darkBadgeBg : AppColors.primary.withOpacity(0.12))
                                  : (isDark ? AppTheme.darkSecondary : AppColors.surfaceContainerHigh),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${cat.count} Muxaadaro',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAll
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat.subtitle,
                        style: AppTypography.sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cat.arabicTitle,
                        style: AppTypography.arabic(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB49EFF) : AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF8E86A6) : AppColors.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
