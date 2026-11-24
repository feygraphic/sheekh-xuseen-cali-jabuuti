import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final StorageService _storage;
  List<String> _bookmarkedLectures = [];
  List<String> _bookmarkedSurahs = [];
  List<String> _bookmarkedAyahs = [];
  List<String> _bookmarkedAdhkar = [];
  List<String> _bookmarkedWisdom = [];
  List<String> _recentlyPlayed = [];
  int _lastReadSurah = 2;
  int _lastReadAyah = 152;
  final Set<String> _downloadedIds = {'lec_04', 'lec_02'}; // preloaded offline items

  FavoritesProvider(this._storage) {
    _load();
  }

  List<String> get bookmarkedLectures => _bookmarkedLectures;
  List<String> get bookmarkedSurahs => _bookmarkedSurahs;
  List<String> get bookmarkedAyahs => _bookmarkedAyahs;
  List<String> get bookmarkedAdhkar => _bookmarkedAdhkar;
  List<String> get bookmarkedWisdom => _bookmarkedWisdom;
  List<String> get recentlyPlayed => _recentlyPlayed;
  int get lastReadSurah => _lastReadSurah;
  int get lastReadAyah => _lastReadAyah;

  void _load() {
    _bookmarkedLectures = _storage.getBookmarkedLectures();
    _bookmarkedSurahs = _storage.getBookmarkedSurahs();
    _bookmarkedAyahs = _storage.getBookmarkedAyahs();
    _bookmarkedAdhkar = _storage.getBookmarkedAdhkar();
    _bookmarkedWisdom = _storage.getBookmarkedWisdom();
    _recentlyPlayed = _storage.getRecentlyPlayed();
    _lastReadSurah = _storage.getLastReadSurah();
    _lastReadAyah = _storage.getLastReadAyah();
    notifyListeners();
  }

  bool isLectureBookmarked(String id) => _bookmarkedLectures.contains(id);
  bool isSurahBookmarked(int number) => _bookmarkedSurahs.contains(number.toString());
  bool isAyahBookmarked(int surah, int ayah) => _bookmarkedAyahs.contains('$surah:$ayah');
  bool isAdhkarBookmarked(String id) => _bookmarkedAdhkar.contains(id);
  bool isWisdomBookmarked(String id) => _bookmarkedWisdom.contains(id);
  bool isDownloaded(String id) => _downloadedIds.contains(id);

  Future<void> toggleLectureBookmark(String id) async {
    await _storage.toggleBookmarkLecture(id);
    _bookmarkedLectures = _storage.getBookmarkedLectures();
    notifyListeners();
  }

  Future<void> toggleSurahBookmark(int number) async {
    await _storage.toggleBookmarkSurah(number);
    _bookmarkedSurahs = _storage.getBookmarkedSurahs();
    notifyListeners();
  }

  Future<void> toggleAyahBookmark(int surah, int ayah) async {
    await _storage.toggleBookmarkAyah(surah, ayah);
    _bookmarkedAyahs = _storage.getBookmarkedAyahs();
    notifyListeners();
  }

  Future<void> toggleAdhkarBookmark(String id) async {
    await _storage.toggleBookmarkAdhkar(id);
    _bookmarkedAdhkar = _storage.getBookmarkedAdhkar();
    notifyListeners();
  }

  Future<void> toggleWisdomBookmark(String id) async {
    await _storage.toggleBookmarkWisdom(id);
    _bookmarkedWisdom = _storage.getBookmarkedWisdom();
    notifyListeners();
  }

  Future<void> setLastRead(int surah, int ayah) async {
    _lastReadSurah = surah;
    _lastReadAyah = ayah;
    await _storage.setLastRead(surah, ayah);
    notifyListeners();
  }

  void toggleDownload(String id) {
    if (_downloadedIds.contains(id)) {
      _downloadedIds.remove(id);
    } else {
      _downloadedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> clearRecentlyPlayed() async {
    await _storage.clearRecentlyPlayed();
    _recentlyPlayed.clear();
    notifyListeners();
  }
}
