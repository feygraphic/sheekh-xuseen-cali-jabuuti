import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../data/ramadan_data.dart';
import '../models/ramadan_lecture.dart';
import '../providers/settings_provider.dart';
import 'ramadan_player_screen.dart';

class RamadanLecturesScreen extends StatefulWidget {
  final RamadanScholar scholar;

  const RamadanLecturesScreen({
    super.key,
    required this.scholar,
  });

  @override
  State<RamadanLecturesScreen> createState() => _RamadanLecturesScreenState();
}

class _RamadanLecturesScreenState extends State<RamadanLecturesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<RamadanLecture> _allLectures;
  List<RamadanLecture> _filteredLectures = [];

  @override
  void initState() {
    super.initState();
    _allLectures = RamadanData.getLecturesByScholar(widget.scholar.id);
    _filteredLectures = _allLectures;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLectures = _allLectures;
      } else {
        _filteredLectures = _allLectures.where((l) {
          return l.title.toLowerCase().contains(query) ||
              l.sortOrder.toString() == query;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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

    return Scaffold(
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
              widget.scholar.name,
              style: AppTypography.sans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              '${_allLectures.length} Muxaadaro oo Ramadaan ah',
              style: AppTypography.sans(
                fontSize: 11.5,
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Scholar Header Banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  // Scholar Avatar / Image
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: widget.scholar.imageAsset != null
                        ? ClipOval(
                            child: Image.asset(
                              widget.scholar.imageAsset!,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          )
                        : _buildScholarMonogram(widget.scholar, accentColor),
                  ),
                  const SizedBox(width: 14),
                  // Scholar Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.scholar.name,
                          style: AppTypography.sans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.scholar.arabicTitle,
                          style: AppTypography.arabic(
                            fontSize: 13,
                            color: textSub,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Taxanaha Ramadaanka • ${_allLectures.length} Muuqaal',
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
                ],
              ),
            ),

            // 2. Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textColor, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Raadi cinwaanka muxaadarada...',
                  hintStyle: TextStyle(color: textSub.withOpacity(0.7), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: textSub, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: textSub, size: 18),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppTheme.darkInputFill : AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accentColor, width: 1.5),
                  ),
                ),
              ),
            ),

            // 3. Lectures List
            Expanded(
              child: _filteredLectures.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: textSub.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'Lama helin muxaadaro u dhiganta raadintaada.',
                            style: AppTypography.sans(fontSize: 13.5, color: textSub),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      itemCount: _filteredLectures.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final lecture = _filteredLectures[idx];
                        return _buildLectureCard(
                          lecture: lecture,
                          isDark: isDark,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textColor: textColor,
                          textSub: textSub,
                          accentColor: accentColor,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarMonogram(RamadanScholar scholar, Color accent) {
    // Generate 2 initials for the monogram
    final parts = scholar.name.split(' ');
    String initials = 'SX';
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}';
    }
    return Text(
      initials,
      style: AppTypography.sans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: accent,
      ),
    );
  }

  Widget _buildLectureCard({
    required RamadanLecture lecture,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color textSub,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => RamadanPlayerScreen(
              lecture: lecture,
              scholar: widget.scholar,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Order Pill
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282538) : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: Text(
                '${lecture.sortOrder}'.padLeft(2, '0'),
                style: AppTypography.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title and Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      lineHeight: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.video_library_outlined, size: 13, color: textSub),
                      const SizedBox(width: 4),
                      Text(
                        '${lecture.category} • ${lecture.language}',
                        style: AppTypography.sans(
                          fontSize: 11,
                          color: textSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Play Button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFFE50914),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
