import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/settings_provider.dart';
import '../providers/tasbeeh_provider.dart';
import '../widgets/adaptive_banner_widget.dart';

/// Standalone Dedicated Tasbeeh Screen for Sheikh Xuseen Cali Jabuuti Application.
///
/// Designed with the exact purple/lavender aesthetic, full light/dark theme adaptation,
/// circular bead ring with realistic 3D beads, statistics tracking (Today, Yesterday, Total),
/// target selection (33, 100, 1000, custom), undo, reset with confirmation, and custom Dhikr creation.
class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap(TasbeehProvider tasbeeh) {
    _scaleController.reverse().then((_) => _scaleController.forward());
    tasbeeh.increment();

    // Check if target completed to show congratulatory feedback
    if (tasbeeh.targetCompletedEvent) {
      tasbeeh.consumeTargetCompletedEvent();
      _showCompletionSheet(context, tasbeeh);
    }
  }

  void _showCompletionSheet(BuildContext context, TasbeehProvider tasbeeh) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isDark = settings.isDarkMode;
    final item = tasbeeh.currentItem;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppTheme.card(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppTheme.border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider(isDark),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Masha\'Allah! Waad Dhammaystirtay',
                style: AppTypography.serif(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                item.arabic,
                textDirection: TextDirection.rtl,
                style: AppTypography.arabic(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Waxaad gaadhay hadafka ${item.target} jeer. Wareegga: ${item.cycleCount}',
                style: AppTypography.sans(
                  fontSize: 13.5,
                  color: AppTheme.textSub(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.border(isDark)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Xidh',
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text(isDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.primaryLight : AppColors.primary,
                        foregroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        tasbeeh.continueNextRound();
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Wareeg Cusub',
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetConfirmation(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.border(isDark)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E2748) : AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dib u Bilow Misbaxada?',
                  style: AppTypography.serif(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text(isDark),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Ma hubtaa inaad tirada dhikrigan (${tasbeeh.currentCount}) ka dhigto eber? '
            'Xusuusnow: Tirada guud iyo ta maanta waxba iskama beddeli doonaan.',
            style: AppTypography.sans(
              fontSize: 13.5,
              color: AppTheme.textSub(isDark),
              lineHeight: 1.45,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Ka noqo',
                style: AppTypography.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSub(isDark),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.primaryLight : AppColors.primary,
                foregroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () {
                tasbeeh.resetCurrentDhikr();
                Navigator.pop(ctx);
              },
              child: Text(
                'Haa, Eber',
                style: AppTypography.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasbeeh = Provider.of<TasbeehProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = AppTheme.bg(isDark);
    final textColor = AppTheme.text(isDark);
    final textMuted = AppTheme.textSub(isDark);
    final borderColor = AppTheme.border(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background subtle geometric patterns
          Positioned.fill(
            child: CustomPaint(
              painter: _TasbeehBackgroundPainter(
                color: isDark ? AppTheme.primaryLight : AppColors.primary,
                opacity: isDark ? 0.045 : 0.035,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Top Bar (Back button, Title, Style/Settings button)
                _buildTopBar(context, isDark, textColor, borderColor),

                // Main Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),

                        // 2. Horizontal Dhikr Selector with (+) button
                        _buildHorizontalDhikrSelector(context, tasbeeh, isDark, textColor, textMuted, borderColor),
                        const SizedBox(height: 12),

                        // 3. Prominent Selected Dhikr Card
                        _buildCurrentDhikrCard(context, tasbeeh, isDark, textColor, textMuted, borderColor),
                        const SizedBox(height: 14),

                        // 4. Target Selector Pill
                        _buildTargetSelectorPill(context, tasbeeh, isDark, textColor, borderColor),
                        const SizedBox(height: 18),

                        // 5. Main Circular Tasbeeh Counter with Beads
                        _buildCircularTasbeehCounter(context, tasbeeh, isDark),
                        const SizedBox(height: 22),

                        // 6. Statistics Section (Today, Yesterday, Total)
                        _buildStatisticsSection(context, tasbeeh, isDark, textColor, textMuted, borderColor),
                        const SizedBox(height: 16),

                        // 7. Bottom Controls (Undo, Reset)
                        _buildBottomControls(context, tasbeeh, isDark, textColor, borderColor),
                        const SizedBox(height: 16),

                        // 8. Adaptive Banner Ad
                        AdaptiveBannerWidget(isDark: isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Top Bar ---
  Widget _buildTopBar(BuildContext context, bool isDark, Color textColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.card(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: textColor,
              ),
            ),
            tooltip: 'Dib u noqo',
            onPressed: () => Navigator.pop(context),
          ),

          // Title
          Text(
            'Tasbiix',
            style: AppTypography.serif(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          // Settings / Customization Button ("Qaabka")
          GestureDetector(
            onTap: () => _showSettingsModal(context, isDark),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.card(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 16,
                    color: isDark ? AppTheme.primaryLight : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Qaabka',
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Horizontal Dhikr Selector with (+) Button ---
  Widget _buildHorizontalDhikrSelector(
    BuildContext context,
    TasbeehProvider tasbeeh,
    bool isDark,
    Color textColor,
    Color textMuted,
    Color borderColor,
  ) {
    final items = tasbeeh.items;

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length + 1, // +1 for the (+) add button
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (ctx, index) {
          // The Add (+) button
          if (index == items.length) {
            return GestureDetector(
              onTap: () => _showAddCustomDhikrModal(context, tasbeeh, isDark),
              child: Container(
                width: 58,
                decoration: BoxDecoration(
                  color: AppTheme.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.primaryLight.withOpacity(0.5) : AppColors.primary.withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 26,
                    color: isDark ? AppTheme.primaryLight : AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final item = items[index];
          final isSelected = item.id == tasbeeh.selectedId;
          final isCycleDone = item.cycleCount > 0;

          final cardBg = isSelected
              ? (isDark ? const Color(0xFF282142) : AppColors.primaryFixed.withOpacity(0.65))
              : AppTheme.card(isDark);

          final activeBorder = isSelected
              ? Border.all(
                  color: isDark ? AppTheme.primaryLight : AppColors.primary,
                  width: 1.6,
                )
              : Border.all(color: borderColor);

          return GestureDetector(
            onTap: () => tasbeeh.selectDhikr(item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: activeBorder,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(isDark ? 0.35 : 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                              : textMuted.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.arabic,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.arabic(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? textColor : textMuted,
                          lineHeight: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.currentCount}/${item.target}',
                        style: AppTypography.sans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                              : textMuted,
                        ),
                      ),
                      if (isCycleDone) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF352B55) : AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '✓ x${item.cycleCount}',
                            style: AppTypography.sans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.primaryLight : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 3. Prominent Selected Dhikr Card ---
  Widget _buildCurrentDhikrCard(
    BuildContext context,
    TasbeehProvider tasbeeh,
    bool isDark,
    Color textColor,
    Color textMuted,
    Color borderColor,
  ) {
    final item = tasbeeh.currentItem;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card(isDark),
        borderRadius: BorderRadius.circular(20),
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
        children: [
          // Arabic Text Prominently Displayed
          Text(
            item.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppTypography.arabic(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: textColor,
              lineHeight: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category and Transliteration
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E2748) : AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.transliteration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sans(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // "Beddel" (Change Dhikr) Button
              GestureDetector(
                onTap: () => _showDhikrPickerSheet(context, tasbeeh, isDark),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252538) : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 15,
                        color: isDark ? AppTheme.primaryLight : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Beddel',
                        style: AppTypography.sans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 4. Target Selector Pill ---
  Widget _buildTargetSelectorPill(
    BuildContext context,
    TasbeehProvider tasbeeh,
    bool isDark,
    Color textColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () => _showTargetPickerSheet(context, tasbeeh, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF221F35) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isDark ? const Color(0xFF3E3560) : AppColors.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.track_changes_rounded,
              size: 16,
              color: isDark ? AppTheme.primaryLight : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Tirada: ${tasbeeh.currentTarget}',
              style: AppTypography.sans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.tune_rounded,
              size: 15,
              color: isDark ? AppTheme.primaryLight : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. Main Circular Tasbeeh Counter with Beads ---
  Widget _buildCircularTasbeehCounter(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    final count = tasbeeh.currentCount;
    final target = tasbeeh.currentTarget;

    // Calculate active illuminated beads (out of 33 physical beads on the misbaha)
    int activeBeads;
    if (target <= 33) {
      activeBeads = count.clamp(0, target);
    } else if (target % 33 == 0) {
      final rem = count % 33;
      activeBeads = (rem == 0 && count > 0) ? 33 : rem;
    } else {
      activeBeads = count >= target ? 33 : ((count / target) * 33).floor().clamp(0, 33);
    }

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final availableWidth = constraints.maxWidth;
        final size = min(availableWidth, 310.0);
        final innerDialSize = size * 0.68;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. The Ring of 33 Beads (Custom Painted)
              Positioned.fill(
                child: CustomPaint(
                  painter: _TasbeehBeadsPainter(
                    activeBeads: activeBeads,
                    totalBeads: 33,
                    isDark: isDark,
                  ),
                ),
              ),

              // 2. Central Tap Dial with Spring Scale Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  key: const Key('tasbeeh_counter_dial'),
                  onTap: () => _handleTap(tasbeeh),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: innerDialSize,
                    height: innerDialSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark
                          ? const RadialGradient(
                              colors: [
                                Color(0xFF2D2250),
                                Color(0xFF1E1736),
                                Color(0xFF140F24),
                              ],
                              stops: [0.0, 0.7, 1.0],
                            )
                          : const RadialGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFF7F1FF),
                                Color(0xFFEBE5F9),
                              ],
                              stops: [0.0, 0.65, 1.0],
                            ),
                      border: Border.all(
                        color: isDark ? const Color(0xFF5A4496) : AppColors.primaryFixedDim,
                        width: 4.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(isDark ? 0.45 : 0.22),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glossy Highlight Reflection (Conforming to Islamic bead dial look)
                        Positioned(
                          top: 10,
                          child: Container(
                            width: innerDialSize * 0.65,
                            height: innerDialSize * 0.32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(isDark ? 0.15 : 0.65),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Count and Target Display
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$count',
                              style: AppTypography.sans(
                                fontSize: count > 999 ? 42 : (count > 99 ? 48 : 56),
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF34265C).withOpacity(0.85)
                                    : AppColors.primaryFixed.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '/ $target',
                                style: AppTypography.sans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.primaryLight : AppColors.onPrimaryFixed,
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
            ],
          ),
        );
      },
    );
  }

  // --- 6. Statistics Section (Today, Yesterday, Total) ---
  Widget _buildStatisticsSection(
    BuildContext context,
    TasbeehProvider tasbeeh,
    bool isDark,
    Color textColor,
    Color textMuted,
    Color borderColor,
  ) {
    return Row(
      children: [
        // 1. Today (Maanta)
        Expanded(
          child: _buildStatCard(
            title: 'Maanta',
            subtitle: 'Today',
            value: '${tasbeeh.todayCount}',
            isDark: isDark,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 10),

        // 2. Yesterday (Shalay)
        Expanded(
          child: _buildStatCard(
            title: 'Shalay',
            subtitle: 'Yesterday',
            value: '${tasbeeh.yesterdayCount}',
            isDark: isDark,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 10),

        // 3. Total (Guud)
        Expanded(
          child: _buildStatCard(
            title: 'Wadarta',
            subtitle: 'Total',
            value: '${tasbeeh.totalCount}',
            isDark: isDark,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color textMuted,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.sans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.primaryLight : AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.sans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.sans(
              fontSize: 10,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Bottom Controls (Undo, Reset) ---
  Widget _buildBottomControls(
    BuildContext context,
    TasbeehProvider tasbeeh,
    bool isDark,
    Color textColor,
    Color borderColor,
  ) {
    return Row(
      children: [
        // Undo Button ("Ka noqo")
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final undone = tasbeeh.undo();
                if (!undone) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tiradu mar hore ayay eber tahay.',
                        style: AppTypography.sans(fontSize: 13, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF382E55),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.undo_rounded,
                      size: 18,
                      color: isDark ? AppTheme.primaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ka noqo',
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Reset Button ("Eber")
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showResetConfirmation(context, tasbeeh, isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: isDark ? AppTheme.primaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Eber',
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Modals & Sheets ---

  /// Settings & Customization Modal ("Qaabka / Habaynta")
  void _showSettingsModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer<TasbeehProvider>(
          builder: (context, tasbeeh, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: AppTheme.card(isDark),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppTheme.border(isDark)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider(isDark),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Habaynta Tasbiixda',
                    style: AppTypography.serif(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text(isDark),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vibration Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Gariirka (Vibration)',
                      style: AppTypography.sans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text(isDark),
                      ),
                    ),
                    subtitle: Text(
                      'Dareen gariir fudud markaad riixdo',
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: AppTheme.textSub(isDark),
                      ),
                    ),
                    activeColor: isDark ? AppTheme.primaryLight : AppColors.primary,
                    value: tasbeeh.vibrationEnabled,
                    onChanged: (val) => tasbeeh.setVibration(val),
                  ),
                  Divider(color: AppTheme.divider(isDark), height: 16),

                  // Sound Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Dhawaaqa (Sound)',
                      style: AppTypography.sans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text(isDark),
                      ),
                    ),
                    subtitle: Text(
                      'Dhawaaq fudud markaad riixdo',
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: AppTheme.textSub(isDark),
                      ),
                    ),
                    activeColor: isDark ? AppTheme.primaryLight : AppColors.primary,
                    value: tasbeeh.soundEnabled,
                    onChanged: (val) => tasbeeh.setSound(val),
                  ),
                  Divider(color: AppTheme.divider(isDark), height: 16),

                  // Clear all statistics button
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
                    ),
                    title: Text(
                      'Eber ka dhig Tirada Guud',
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
                      ),
                    ),
                    subtitle: Text(
                      'Nadiifi xogta maanta iyo ta guud',
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: AppTheme.textSub(isDark),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showResetAllStatsDialog(context, tasbeeh, isDark);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showResetAllStatsDialog(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.card(isDark),
          title: Text(
            'Eber dhig Xogta Dhammaan?',
            style: AppTypography.serif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text(isDark),
            ),
          ),
          content: Text(
            'Ma hubtaa inaad tirtirto dhammaan xogta tirada (Maanta, Shalay iyo Guud)? Tani dib looma soo celin karo.',
            style: AppTypography.sans(
              fontSize: 13.5,
              color: AppTheme.textSub(isDark),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Ka noqo',
                style: AppTypography.sans(color: AppTheme.textSub(isDark)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                tasbeeh.resetAllStats();
                Navigator.pop(ctx);
              },
              child: Text('Haa, Nadiifi', style: AppTypography.sans(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Target Picker Bottom Sheet (33, 100, 1000, Custom)
  void _showTargetPickerSheet(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    final customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.card(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppTheme.border(isDark)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider(isDark),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Dooro Hadafka Tirada',
                  style: AppTypography.serif(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text(isDark),
                  ),
                ),
                const SizedBox(height: 16),

                // Standard Presets: 33, 100, 1000
                Row(
                  children: [33, 100, 1000].map((t) {
                    final isSelected = tasbeeh.currentTarget == t;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            tasbeeh.setTarget(t);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF352B55) : AppColors.primaryFixed)
                                  : (isDark ? const Color(0xFF252538) : AppColors.surfaceContainerLow),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                    : AppTheme.border(isDark),
                                width: isSelected ? 1.6 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$t',
                                style: AppTypography.sans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                                      : AppTheme.text(isDark),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Custom Target Input
                Text(
                  'Gali Tirsi Gaar ah:',
                  style: AppTypography.sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSub(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E2E) : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border(isDark)),
                        ),
                        child: TextField(
                          controller: customController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: AppTypography.sans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text(isDark),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tusaale: 50, 500...',
                            hintStyle: AppTypography.sans(
                              fontSize: 13.5,
                              color: AppTheme.textSub(isDark).withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.primaryLight : AppColors.primary,
                        foregroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: () {
                        final val = int.tryParse(customController.text.trim());
                        if (val != null && val > 0) {
                          tasbeeh.setTarget(val);
                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(
                        'Xaqiiji',
                        style: AppTypography.sans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Dhikr Picker Bottom Sheet ("Beddel Dhikr")
  void _showDhikrPickerSheet(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.72,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: AppTheme.card(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppTheme.border(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider(isDark),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dooro Adkaarta',
                    style: AppTypography.serif(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text(isDark),
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      size: 18,
                      color: isDark ? AppTheme.primaryLight : AppColors.primary,
                    ),
                    label: Text(
                      'Ku Dar Dhikr',
                      style: AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.primaryLight : AppColors.primary,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddCustomDhikrModal(context, tasbeeh, isDark);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: tasbeeh.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final item = tasbeeh.items[idx];
                    final isSelected = item.id == tasbeeh.selectedId;

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF2B2349) : AppColors.primaryFixed.withOpacity(0.5))
                            : (isDark ? const Color(0xFF1E1E2E) : AppColors.surfaceContainerLow),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.primaryLight : AppColors.primary)
                              : AppTheme.border(isDark),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          tasbeeh.selectDhikr(item.id);
                          Navigator.pop(ctx);
                        },
                        title: Text(
                          item.arabic,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.arabic(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text(isDark),
                            lineHeight: 1.4,
                          ),
                        ),
                        subtitle: Text(
                          '${item.transliteration} • Hadafka: ${item.target} jeer',
                          style: AppTypography.sans(
                            fontSize: 12,
                            color: AppTheme.textSub(isDark),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.isCustom)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                onPressed: () => tasbeeh.deleteCustomDhikr(item.id),
                              ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark ? AppTheme.primaryLight : AppColors.primary,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Add Custom Dhikr Modal Dialog
  void _showAddCustomDhikrModal(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    final arabicCtrl = TextEditingController();
    final transCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '33');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.card(isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppTheme.border(isDark)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider(isDark),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ku Dar Dhikr Cusub',
                    style: AppTypography.serif(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text(isDark),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Arabic input
                  Text(
                    'Qoraalka Carabiga:',
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSub(isDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border(isDark)),
                    ),
                    child: TextField(
                      controller: arabicCtrl,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.arabic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text(isDark),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tusaale: لا إِلَهَ إِلَّا الله',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: AppTypography.arabic(
                          fontSize: 15,
                          color: AppTheme.textSub(isDark).withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Transliteration / Meaning
                  Text(
                    'Magaca ama Macnaha (Soomaali):',
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSub(isDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border(isDark)),
                    ),
                    child: TextField(
                      controller: transCtrl,
                      style: AppTypography.sans(
                        fontSize: 14,
                        color: AppTheme.text(isDark),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tusaale: Towxiidka',
                        hintStyle: AppTypography.sans(
                          fontSize: 13,
                          color: AppTheme.textSub(isDark).withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Target
                  Text(
                    'Hadafka Tirada:',
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSub(isDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border(isDark)),
                    ),
                    child: TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text(isDark),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.primaryLight : AppColors.primary,
                        foregroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final arabic = arabicCtrl.text.trim();
                        if (arabic.isEmpty) return;
                        final trans = transCtrl.text.trim();
                        final target = int.tryParse(targetCtrl.text.trim()) ?? 33;

                        tasbeeh.addCustomDhikr(
                          arabic: arabic,
                          transliteration: trans.isEmpty ? 'Dhikr Gaar ah' : trans,
                          target: target,
                        );

                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Keydi Dhikr-ka',
                        style: AppTypography.sans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom Painter that renders the 33 beads in a circular ring around the central dial.
/// Completed beads have a luminous 3D sphere gradient with specular highlight,
/// while inactive beads have a subtle translucent sphere appearance.
class _TasbeehBeadsPainter extends CustomPainter {
  final int activeBeads;
  final int totalBeads;
  final bool isDark;

  _TasbeehBeadsPainter({
    required this.activeBeads,
    required this.totalBeads,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = (size.width / 2) - 12;

    // Draw connecting thread/ring
    final threadPaint = Paint()
      ..color = (isDark ? const Color(0xFF3B3058) : AppColors.outlineVariant.withOpacity(0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, ringRadius, threadPaint);

    for (int i = 0; i < totalBeads; i++) {
      // Angle starts from top (-pi / 2) and rotates clockwise
      final angle = (-pi / 2) + (i * 2 * pi / totalBeads);
      final beadCenter = Offset(
        center.dx + ringRadius * cos(angle),
        center.dy + ringRadius * sin(angle),
      );

      final isImamBead = (i == 0); // Top Imam marker bead
      final isCompleted = i < activeBeads;

      if (isCompleted) {
        _drawLuminousBead(canvas, beadCenter, isImamBead);
      } else {
        _drawInactiveBead(canvas, beadCenter, isImamBead);
      }
    }
  }

  void _drawLuminousBead(Canvas canvas, Offset center, bool isImam) {
    final double radius = isImam ? 8.5 : 6.8;

    // 1. Soft Outer Glow
    final glowPaint = Paint()
      ..color = (isDark ? AppTheme.primaryLight : AppColors.primary).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(center, radius + 2, glowPaint);

    // 2. Spherical Bead Body (Radial Gradient for 3D depth)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final beadPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: isDark
            ? [
                const Color(0xFFE2D6FF),
                const Color(0xFFB49EFF),
                const Color(0xFF6B42D6),
              ]
            : [
                const Color(0xFFFFFFFF),
                const Color(0xFF8C66F7),
                const Color(0xFF4A1BC4),
              ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    if (isImam) {
      // Slightly elongated Imam marker bead
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: radius * 1.8, height: radius * 2.3),
        Radius.circular(radius),
      );
      canvas.drawRRect(rrect, beadPaint);
    } else {
      canvas.drawCircle(center, radius, beadPaint);
    }

    // 3. Specular Glint Highlight on upper left
    final glintPaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.35), radius * 0.28, glintPaint);
  }

  void _drawInactiveBead(Canvas canvas, Offset center, bool isImam) {
    final double radius = isImam ? 7.5 : 5.8;

    // Subtle translucent sphere
    final fillPaint = Paint()
      ..color = isDark
          ? const Color(0xFF28233C).withOpacity(0.65)
          : AppColors.surfaceContainerHighest.withOpacity(0.5);

    final borderPaint = Paint()
      ..color = isDark
          ? const Color(0xFF443862).withOpacity(0.55)
          : AppColors.outlineVariant.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (isImam) {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: radius * 1.8, height: radius * 2.2),
        Radius.circular(radius),
      );
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, borderPaint);
    } else {
      canvas.drawCircle(center, radius, fillPaint);
      canvas.drawCircle(center, radius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TasbeehBeadsPainter oldDelegate) {
    return oldDelegate.activeBeads != activeBeads ||
        oldDelegate.totalBeads != totalBeads ||
        oldDelegate.isDark != isDark;
  }
}

/// Custom Background Painter for subtle Islamic geometric stars
class _TasbeehBackgroundPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _TasbeehBackgroundPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 110.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawEightPointedStar(canvas, Offset(x, y), 24, paint);
      }
    }
  }

  void _drawEightPointedStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 16;
    for (int i = 0; i < points; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.45;
      final angle = (i * 2 * pi / points) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TasbeehBackgroundPainter oldDelegate) => false;
}
