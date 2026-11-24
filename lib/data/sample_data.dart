import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lecture_model.dart';
import '../models/surah_model.dart';
import '../models/adkhar_model.dart';
import '../models/quote_model.dart';
import 'quran_data.dart';
import 'lectures_catalog.dart';
import 'adhkar_data.dart';

class SampleData {
  // Complete Lectures Collection initialized with all 131 lectures
  static List<LectureModel> lectures = List.from(allSheekhXuseenLectures);

  // Track 1
  static LectureModel track01Lecture = allSheekhXuseenLectures.isNotEmpty
      ? allSheekhXuseenLectures[0]
      : const LectureModel(
          id: 'lec_001',
          trackNumber: 1,
          arabicTitle: 'محاضرة الشيخ حسين علي - الدعوة والتبليغ',
          somaliTitle: 'Dacwada iyo Tabliiqa (Sheekh Tabliq)',
          seriesNumber: 1,
          seriesName: 'Qaybta 1aad: Muxaadarooyinka Guud',
          category: 'Muxaadaro',
          duration: Duration(minutes: 45),
          audioUrl: 'https://sheekhxuseen.s3.us-east-005.backblazeb2.com/0004sheik+tabliq.mp3',
          isLocalAsset: false,
          imageUrl: 'assets/images/sheikh_player.jpg',
          description: 'Muxaadaro qiimo badan oo ka mid ah taxanaha muxaadarooyinka Sheekh Xuseen Cali Jabuuti.',
        );

  // Track 2
  static LectureModel track02Lecture = allSheekhXuseenLectures.length > 1
      ? allSheekhXuseenLectures[1]
      : track01Lecture;

  // Hero and Featured Lectures
  static LectureModel heroLecture = track01Lecture;
  static LectureModel nowPlayingLecture = track01Lecture;
  static LectureModel recentPlayedTrack = track02Lecture;

  static Future<void> loadLecturesFromAsset() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/lectures.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List && decoded.isNotEmpty) {
        final List<LectureModel> jsonLectures = [];
        for (int i = 0; i < decoded.length; i++) {
          final item = decoded[i];
          if (item is Map<String, dynamic>) {
            jsonLectures.add(LectureModel.fromJson(item, defaultIndex: i + 1));
          }
        }
        if (jsonLectures.isNotEmpty) {
          lectures = jsonLectures;
          track01Lecture = jsonLectures[0];
          heroLecture = jsonLectures[0];
          nowPlayingLecture = jsonLectures[0];
          recentPlayedTrack = jsonLectures.length > 1 ? jsonLectures[1] : jsonLectures[0];
        }
      }
    } catch (_) {}
  }

  static LectureModel getLectureAt(int index) {
    if (lectures.isEmpty) return track01Lecture;
    return lectures[index % lectures.length];
  }

  // Up Next Playlist for Audio Player
  static List<LectureModel> get queueLectures => lectures;

  // Surahs Data (All 114 Surahs from QuranData)
  static List<SurahModel> get surahs => QuranData.allSurahs;

  // Adhkar Data (All 45 Adhkar across 10 categories from AdhkarData)
  static List<AdkharModel> get adhkarList => AdhkarData.allAdhkar;

  // Daily Quotes and Reminders
  static final QuoteModel dailyAyahQuote = QuoteModel(
    id: 'quote_daily_ayah',
    category: 'Aayadda & Xikmadda Maalinta',
    arabic: 'قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ',
    somali: 'Dheh: Ma siman yihiin kuwa wax og iyo kuwa aan waxba ogayn?',
    source: 'Suuradda Al-Zumar : 9',
  );

  static final QuoteModel hadithOfTheDay = QuoteModel(
    id: 'quote_hadith_day',
    category: 'Dardaaranka Maanta',
    arabic: '« مَنْ سَلَكَ طَرِيقاً يَلْتَمِسُ فِيهِ عِلْماً سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقاً إِلَى الْجَنَّةِ »',
    somali: 'Qofkii qaada waddo uu ku doonayo cilmi, Alle wuxuu ugu fududeeyaa waddada Jannada.',
    source: 'Xadiis Saxiix ah • Muslim',
    subSource: 'Riyaadu Saalixiina',
  );

  static final QuoteModel quranVirtueHadith = QuoteModel(
    id: 'quote_quran_virtue',
    category: 'Fadliga Akhriska & Barashada Qur\'aanka',
    arabic: '« خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ »',
    somali: 'Waxa idiinku khayr badan qofka Qur\'aanka barta, dadkana bara.',
    source: 'Riyaadu Saalixiina (Xadiis 993)',
    subSource: 'Saxnuul Bukhaari',
  );
}
