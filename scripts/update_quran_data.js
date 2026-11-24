const fs = require('fs');
const path = require('path');

const targetFile = path.join(__dirname, '..', 'lib', 'data', 'quran_data.dart');
let content = fs.readFileSync(targetFile, 'utf8');

const startMarker = '  /// Verified Quran Verses with accurate standard Somali translation ONLY';
const endMarker = '  static SurahModel getSurahByNumber(int number) {';

const startIndex = content.indexOf(startMarker);
const endIndex = content.indexOf(endMarker);

if (startIndex === -1 || endIndex === -1) {
  console.error('Could not find markers:', { startIndex, endIndex });
  process.exit(1);
}

const replacement = `  /// In-memory cache for loaded Surah verses to ensure instantaneous navigation.
  static final Map<int, List<AyahModel>> _surahAyahsCache = {
    // Pre-cache Surah 1 Al-Faatixa for immediate synchronous availability
    1: [
      const AyahModel(
        surahNumber: 1,
        ayahNumber: 1,
        arabicText: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        somaliTranslation: 'In the name of Allāh [1], the Most Compassionate, the Most Merciful.',
        juzNumber: 1,
        hizbNumber: 1,
      ),
      const AyahModel(
        surahNumber: 1,
        ayahNumber: 2,
        arabicText: 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ',
        somaliTranslation: 'Ammaan idilkeed iyo mahad waxaa leh Allaah, Rabbiga uumanka.',
        juzNumber: 1,
        hizbNumber: 1,
      ),
      const AyahModel(
        surahNumber: 1,
        ayahNumber: 3,
        arabicText: 'ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        somaliTranslation: 'Naxariistaha (Naxariis guud ahaaneed), Naxariista Badan [1].',
        juzNumber: 1,
        hizbNumber: 1,
      ),
      const AyahModel(
        surahNumber: 1,
        ayahNumber: 4,
        arabicText: 'مَٰلِكِ يَوۡمِ ٱلدِّينِ',
        somaliTranslation: 'Boqorka Maalinta Jaazeynta [1].',
        juzNumber: 1,
        hizbNumber: 1,
      ),
      const AyahModel(
        surahNumber: 1,
        ayahNumber: 5,
        arabicText: 'إِيَّاكَ نَعۡبُدُ وَإِيَّاكَ نَسۡتَعِينُ',
        somaliTranslation: 'Adigoo Keliya baynu (Allow) ku caabudi, oo Adigoo Keliya baynu ku weydiisan kaalmo.',
        juzNumber: 1,
        hizbNumber: 1,
      ),
      const AyahModel(
        surahNumber: 1,
        ayahNumber: 6,
        arabicText: 'ٱهۡدِنَا ٱلصِّرَٰطَ ٱلۡمُسۡتَقِيمَ',
        somaliTranslation: 'Nagu hanuuni (oo sug) Jidka Toosan.',
        juzNumber: 1,
        hizbNumber: 1,
      ),
      const AyahModel(
        surahNumber: 1,
        ayahNumber: 7,
        arabicText: 'صِرَٰطَ ٱلَّذِينَ أَنۡعَمۡتَ عَلَيۡهِمۡ غَيۡرِ ٱلۡمَغۡضُوبِ عَلَيۡهِمۡ وَلَا ٱلضَّآلِّينَ',
        somaliTranslation: 'Jidka kuwa aad u Nicmaysay [1], aan aheyn (jidka) kuwa loo cadhooday [2] iyo (jidka) kuwa lunsan midna [3].',
        juzNumber: 1,
        hizbNumber: 1,
      ),
    ],
  };

  /// Asynchronously loads all verses for a Surah from the offline JSON asset.
  /// Works 100% offline without requiring any internet connection.
  static Future<List<AyahModel>> loadAyahsForSurah(int surahNumber) async {
    if (_surahAyahsCache.containsKey(surahNumber) && _surahAyahsCache[surahNumber]!.isNotEmpty) {
      return _surahAyahsCache[surahNumber]!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/quran/surah_\$surahNumber.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final ayahsRaw = data['ayahs'] as List<dynamic>? ?? [];
      final surah = getSurahByNumber(surahNumber);

      final list = ayahsRaw.map((item) {
        final map = item as Map<String, dynamic>;
        return AyahModel.fromJson(map, defaultJuz: surah.juzNumber, defaultHizb: surah.hizbNumber);
      }).toList();

      _surahAyahsCache[surahNumber] = list;
      return list;
    } catch (e) {
      debugPrint('Error loading surah \$surahNumber from local assets: \$e');
      return _surahAyahsCache[surahNumber] ?? [];
    }
  }

  /// Synchronous check whether verses for this Surah are already in cache
  static bool hasCachedAyahs(int surahNumber) {
    return _surahAyahsCache.containsKey(surahNumber) && _surahAyahsCache[surahNumber]!.isNotEmpty;
  }

  /// Returns cached ayahs if available, or empty list
  static List<AyahModel> getCachedAyahs(int surahNumber) {
    return _surahAyahsCache[surahNumber] ?? [];
  }

  /// Synchronously returns ayahs if already cached, or empty list
  static List<AyahModel> getAyahsForSurah(int surahNumber) {
    return _surahAyahsCache[surahNumber] ?? [];
  }

`;

content = content.substring(0, startIndex) + replacement + content.substring(endIndex);
fs.writeFileSync(targetFile, content, 'utf8');
console.log('Successfully updated quran_data.dart!');
