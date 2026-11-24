import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../data/sample_data.dart';
import '../models/lecture_model.dart';
import '../models/surah_model.dart';
import '../models/adkhar_model.dart';
import 'dua_reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioPlayerProvider>(context);

    final cleanQ = _query.toLowerCase().trim();

    final matchedLectures = cleanQ.isEmpty
        ? <LectureModel>[]
        : SampleData.lectures.where((l) {
            return l.somaliTitle.toLowerCase().contains(cleanQ) ||
                l.arabicTitle.toLowerCase().contains(cleanQ) ||
                l.category.toLowerCase().contains(cleanQ);
          }).toList();

    final matchedSurahs = cleanQ.isEmpty
        ? <SurahModel>[]
        : SampleData.surahs.where((s) {
            return s.somaliName.toLowerCase().contains(cleanQ) ||
                s.arabicName.contains(cleanQ) ||
                s.number.toString() == cleanQ;
          }).toList();

    final matchedAdhkar = cleanQ.isEmpty
        ? <AdkharModel>[]
        : SampleData.adhkarList.where((d) {
            return d.title.toLowerCase().contains(cleanQ) ||
                d.somaliTranslation.toLowerCase().contains(cleanQ) ||
                d.arabicText.contains(cleanQ);
          }).toList();

    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.bg(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(isDark),
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.text(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: AppTypography.sans(fontSize: 15, color: AppTheme.text(isDark)),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'Raadi Muxaadaro, Suurad ama Adkaar...',
            hintStyle: AppTypography.sans(fontSize: 14, color: AppTheme.textSub(isDark)),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: AppTheme.textSub(isDark)),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _query = '';
                });
              },
            ),
        ],
      ),
      body: cleanQ.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: isDark ? const Color(0xFF3F3D56) : AppColors.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Gali erey aad raadinayso',
                    style: AppTypography.serif(fontSize: 16, color: AppTheme.textSub(isDark)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tusaale: "Iimaan", "Al-Baqarah", "Waalidiinta", "Qiyaamaha"',
                    style: AppTypography.sans(fontSize: 12, color: AppTheme.textSub(isDark)),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (matchedLectures.isNotEmpty) ...[
                  Text(
                    'Muxaadarooyinka (${matchedLectures.length})',
                    style: AppTypography.serif(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...matchedLectures.map((l) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0.5,
                        color: AppTheme.card(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.border(isDark)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDark ? AppTheme.darkBadgeBg : AppColors.primaryFixed,
                            child: Icon(Icons.podcasts, color: isDark ? AppTheme.primaryLight : AppColors.primary, size: 20),
                          ),
                          title: Text(
                            l.somaliTitle,
                            style: AppTypography.sans(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.text(isDark)),
                          ),
                          subtitle: Text(
                            l.arabicTitle,
                            style: AppTypography.arabic(fontSize: 12, color: AppTheme.textSub(isDark)),
                          ),
                          trailing: Icon(
                            Icons.play_circle_fill,
                            color: isDark ? AppTheme.primaryLight : AppColors.primary,
                            size: 30,
                          ),
                          onTap: () {
                            audio.playLecture(l);
                            Navigator.pop(context);
                          },
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                if (matchedSurahs.isNotEmpty) ...[
                  Text(
                    'Suuradaha Qur\'aanka (${matchedSurahs.length})',
                    style: AppTypography.serif(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...matchedSurahs.map((s) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0.5,
                        color: AppTheme.card(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.border(isDark)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDark ? AppTheme.darkSecondary : AppColors.secondaryContainer,
                            child: Text(
                              '${s.number}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppColors.onSecondaryContainer),
                            ),
                          ),
                          title: Text(
                            s.somaliName,
                            style: AppTypography.sans(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.text(isDark)),
                          ),
                          subtitle: Text(
                            '${s.versesCount} Aayadood • ${s.revelationType}',
                            style: AppTypography.sans(fontSize: 11.5, color: AppTheme.textSub(isDark)),
                          ),
                          trailing: Text(
                            s.arabicName,
                            style: AppTypography.arabic(fontSize: 16, color: isDark ? AppTheme.primaryLight : AppColors.primary),
                          ),
                          onTap: () {
                            audio.playSurahTafsiir(s);
                            Navigator.pop(context);
                          },
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                if (matchedAdhkar.isNotEmpty) ...[
                  Text(
                    'Adkaarta (${matchedAdhkar.length})',
                    style: AppTypography.serif(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF86EFAC) : AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...matchedAdhkar.map((d) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0.5,
                        color: AppTheme.card(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.border(isDark)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isDark ? const Color(0xFF14532D).withOpacity(0.4) : AppColors.tertiaryFixed,
                            child: Icon(Icons.spa, color: isDark ? const Color(0xFF86EFAC) : AppColors.tertiary, size: 20),
                          ),
                          title: Text(
                            d.title,
                            style: AppTypography.sans(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.text(isDark)),
                          ),
                          subtitle: Text(
                            d.somaliTranslation,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(fontSize: 11.5, color: AppTheme.textSub(isDark)),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => DuaReadingScreen(
                                  initialDua: d,
                                  categoryDuas: [d],
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                ],
                if (matchedLectures.isEmpty && matchedSurahs.isEmpty && matchedAdhkar.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Wax natiijo ah lagama helin "$_query".',
                        style: AppTypography.sans(fontSize: 14, color: AppTheme.textSub(isDark)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
