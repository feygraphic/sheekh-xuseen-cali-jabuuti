import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheekh_xuseen_cali_jabuuti/constants/app_colors.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/quran_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/sample_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/lecture_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/surah_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/adkhar_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/reciter_model.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/quran_audio_service.dart';

void main() {
  test('Complete Quran contains exactly 114 Surahs and 6,236 Ayahs', () {
    // 1. All 114 Surahs are present in order
    expect(QuranData.allSurahs.length, 114);
    for (int i = 0; i < 114; i++) {
      expect(QuranData.allSurahs[i].number, i + 1);
    }

    // 2. Sum of all verses across 114 Surahs equals 6,236
    final totalVerses = QuranData.allSurahs.fold<int>(0, (sum, s) => sum + s.versesCount);
    expect(totalVerses, 6236);

    // 3. Pre-cached Surah 1 (Al-Faatixa) has all 7 verified verses
    final fatiha = QuranData.getCachedAyahs(1);
    expect(fatiha.length, 7);
    expect(fatiha.first.arabicText.contains('بِسۡمِ ٱللَّهِ'), true);
    expect(fatiha.last.somaliTranslation.contains('Jidka kuwa aad u Nicmaysay'), true);
  });

  test('QuranTheme provides unified color identity between Page 1 and Page 2', () {
    // 1. Primary color matches Page 1 (Purple/Blue)
    expect(QuranTheme.primary, const Color(0xFF623EDC));
    expect(QuranTheme.primary, AppColors.primary);

    // 2. Arabic calligraphy color uses signature primary purple
    expect(QuranTheme.arabicCalligraphy, QuranTheme.primary);

    // 3. Centralized badge tokens
    expect(QuranTheme.badgeBackground, AppColors.primaryFixed);
    expect(QuranTheme.badgeText, QuranTheme.primary);

    // 4. Reader serene palette matches QuranTheme exactly
    expect(QuranReaderPalette.serene.accent, QuranTheme.primary);
    expect(QuranReaderPalette.serene.background, QuranTheme.background);
    expect(QuranReaderPalette.serene.badgeBackground, QuranTheme.badgeBackground);
    expect(QuranReaderPalette.serene.badgeText, QuranTheme.badgeText);
    expect(QuranReaderPalette.serene.arabicText, QuranTheme.textDark);
    expect(QuranReaderPalette.serene.somaliText, QuranTheme.textMuted);

    // 5. Light and Night palettes also maintain purple accent (no brown/gold)
    expect(QuranReaderPalette.light.accent, QuranTheme.primary);
    expect(QuranReaderPalette.night.accent, const Color(0xFF9D84F7));
  });

  test('SampleData contains all required lectures, surahs and adhkar', () {
    expect(SampleData.lectures.isNotEmpty, true);
    expect(SampleData.surahs.isNotEmpty, true);
    expect(SampleData.adhkarList.isNotEmpty, true);

    // Verify Lecture 4
    final lec4 = SampleData.lectures.firstWhere((l) => l.trackNumber == 4);
    expect(lec4.arabicTitle.contains('محاضرة الشيخ حسين'), true);
    expect(lec4.duration.inMinutes > 0, true);

    // Verify Surah Al-Baqarah
    final baqarah = SampleData.surahs.firstWhere((s) => s.number == 2);
    expect(baqarah.somaliName, 'Al-Baqarah');
    expect(baqarah.versesCount, 286);

    // Verify Adhkar (45 authentic items across 10 categories)
    expect(SampleData.adhkarList.length >= 40, true);
    final dhikr1 = SampleData.adhkarList.firstWhere((d) => d.id == 'galab_1' || d.id == 'dhikr_1');
    expect(dhikr1.targetCount, 1);
    expect(dhikr1.arabicText.isNotEmpty, true);
    expect(dhikr1.somaliTranslation.isNotEmpty, true);

    // Verify all 10 categories are represented
    final categories = SampleData.adhkarList.map((d) => d.category).toSet();
    expect(categories.contains('Adkaarta Subaxda'), true);
    expect(categories.contains('Adkaarta Galabta'), true);
    expect(categories.contains('Salaadda Kadib'), true);
    expect(categories.contains('Adkaarta Hurdada'), true);
    expect(categories.contains('Adkaarta Soo Toosidda'), true);
    expect(categories.contains('Gelidda & Ka-bixidda Guriga'), true);
    expect(categories.contains('Gelidda & Ka-bixidda Masaajidka'), true);
    expect(categories.contains('Adkaarta Safarka'), true);
    expect(categories.contains('Cuntada & Cabitaanka'), true);
    expect(categories.contains('Adkaar Kale oo Maalinle ah'), true);
  });

  test('Lecture model serialization works', () {
    final lecture = SampleData.heroLecture;
    final json = lecture.toJson();
    final reconstructed = LectureModel.fromJson(json);

    expect(reconstructed.id, lecture.id);
    expect(reconstructed.arabicTitle, lecture.arabicTitle);
    expect(reconstructed.duration, lecture.duration);
  });

  test('Surah and Adhkar models serialization works', () {
    final surah = SampleData.surahs.first;
    final sJson = surah.toJson();
    final reconstructedS = SurahModel.fromJson(sJson);
    expect(reconstructedS.number, surah.number);

    final dhikr = SampleData.adhkarList.first;
    final dJson = dhikr.toJson();
    final reconstructedD = AdkharModel.fromJson(dJson);
    expect(reconstructedD.id, dhikr.id);
  });

  test('Quran Audio Streaming & MP3Quran Reciter Model works', () {
    final service = QuranAudioService();
    final reciters = service.cachedReciters;

    // 1. Reciters list has popular reciters (Mishary, Maher, Abdul Basit, etc.)
    expect(reciters.isNotEmpty, true);
    expect(reciters.length >= 10, true);

    final defaultReciter = service.defaultReciter;
    expect(defaultReciter.nameEn.contains('Mishary') || defaultReciter.nameEn.contains('Alafasy'), true);

    // 2. Audio URL generation correctly formats 3-digit surahs
    final url001 = defaultReciter.getSurahAudioUrl(1);
    expect(url001.endsWith('001.mp3'), true);
    expect(url001.startsWith('https://'), true);

    final url002 = defaultReciter.getSurahAudioUrl(2);
    expect(url002.endsWith('002.mp3'), true);

    final url114 = defaultReciter.getSurahAudioUrl(114);
    expect(url114.endsWith('114.mp3'), true);

    // 3. All 114 Surahs generate valid non-empty URLs
    for (int i = 1; i <= 114; i++) {
      final surahUrl = defaultReciter.getSurahAudioUrl(i);
      final pad = i.toString().padLeft(3, '0');
      expect(surahUrl.endsWith('$pad.mp3'), true);
    }

    // 4. Reciter serialization works
    final json = defaultReciter.toJson();
    final reconstructed = ReciterModel.fromJson(json);
    expect(reconstructed.id, defaultReciter.id);
    expect(reconstructed.server, defaultReciter.server);
    expect(reconstructed.displayImage.contains('mishary_alafasy.jpg'), true);
  });

  test('Audio artwork separation: Quran reciter vs Sheikh lecture', () {
    final service = QuranAudioService();
    final mishary = service.defaultReciter;
    expect(mishary.displayImage, 'assets/images/mishary_alafasy.jpg');

    // Abdul Basit reciter
    final abdulBasit = service.getReciterById(51);
    expect(abdulBasit.displayImage, 'assets/images/abdul_basit.jpg');

    // Lecture artwork
    final lecture = SampleData.heroLecture;
    expect(lecture.imageUrl.contains('sheikh'), true);
  });
}
