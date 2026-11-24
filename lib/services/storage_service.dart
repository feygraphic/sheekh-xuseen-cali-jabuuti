import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static void resetForTesting() {
    _instance = null;
    _prefs = null;
  }

  static StorageService fallback() {
    _instance ??= StorageService._();
    return _instance!;
  }

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        // Fallback gracefully so an isolated storage failure never crashes app startup
      }
    }
    return _instance!;
  }

  // Bookmarks (Lectures)
  List<String> getBookmarkedLectures() {
    return _prefs?.getStringList('bookmarked_lectures') ?? [];
  }

  Future<void> toggleBookmarkLecture(String id) async {
    final list = getBookmarkedLectures();
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await _prefs?.setStringList('bookmarked_lectures', list);
  }

  bool isLectureBookmarked(String id) {
    return getBookmarkedLectures().contains(id);
  }

  // Bookmarks (Surahs)
  List<String> getBookmarkedSurahs() {
    return _prefs?.getStringList('bookmarked_surahs') ?? [];
  }

  Future<void> toggleBookmarkSurah(int number) async {
    final list = getBookmarkedSurahs();
    final key = number.toString();
    if (list.contains(key)) {
      list.remove(key);
    } else {
      list.add(key);
    }
    await _prefs?.setStringList('bookmarked_surahs', list);
  }

  bool isSurahBookmarked(int number) {
    return getBookmarkedSurahs().contains(number.toString());
  }

  // Bookmarks (Adhkar)
  List<String> getBookmarkedAdhkar() {
    return _prefs?.getStringList('bookmarked_adhkar') ?? [];
  }

  Future<void> toggleBookmarkAdhkar(String id) async {
    final list = getBookmarkedAdhkar();
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await _prefs?.setStringList('bookmarked_adhkar', list);
  }

  bool isAdhkarBookmarked(String id) {
    return getBookmarkedAdhkar().contains(id);
  }

  // Bookmarks (Islamic Wisdom & Sayings)
  List<String> getBookmarkedWisdom() {
    return _prefs?.getStringList('bookmarked_wisdom') ?? [];
  }

  Future<void> toggleBookmarkWisdom(String id) async {
    final list = getBookmarkedWisdom();
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await _prefs?.setStringList('bookmarked_wisdom', list);
  }

  bool isWisdomBookmarked(String id) {
    return getBookmarkedWisdom().contains(id);
  }

  // Recently Played History
  List<String> getRecentlyPlayed() {
    return _prefs?.getStringList('recent_history') ?? [];
  }

  Future<void> addRecentlyPlayed(String lectureId) async {
    final list = getRecentlyPlayed();
    list.remove(lectureId);
    list.insert(0, lectureId);
    if (list.length > 20) {
      list.removeRange(20, list.length);
    }
    await _prefs?.setStringList('recent_history', list);
  }

  Future<void> clearRecentlyPlayed() async {
    await _prefs?.remove('recent_history');
  }

  // Tasbih Counter & Standalone Tasbeeh System
  int getTasbihCount() {
    return _prefs?.getInt('tasbih_count') ?? 0;
  }

  Future<void> setTasbihCount(int count) async {
    await _prefs?.setInt('tasbih_count', count);
  }

  // Selected Dhikr ID
  String getTasbeehSelectedId() {
    return _prefs?.getString('tasbeeh_selected_id') ?? 'subhanallah';
  }

  Future<void> setTasbeehSelectedId(String id) async {
    await _prefs?.setString('tasbeeh_selected_id', id);
  }

  // Custom Dhikrs (JSON string list)
  List<String> getTasbeehCustomDhikrs() {
    return _prefs?.getStringList('tasbeeh_custom_dhikrs') ?? [];
  }

  Future<void> setTasbeehCustomDhikrs(List<String> jsonList) async {
    await _prefs?.setStringList('tasbeeh_custom_dhikrs', jsonList);
  }

  // Dhikr specific count
  int getTasbeehItemCount(String id) {
    return _prefs?.getInt('tasbeeh_item_count_$id') ?? 0;
  }

  Future<void> setTasbeehItemCount(String id, int count) async {
    await _prefs?.setInt('tasbeeh_item_count_$id', count);
  }

  // Dhikr specific target
  int getTasbeehItemTarget(String id, int defaultTarget) {
    return _prefs?.getInt('tasbeeh_item_target_$id') ?? defaultTarget;
  }

  Future<void> setTasbeehItemTarget(String id, int target) async {
    await _prefs?.setInt('tasbeeh_item_target_$id', target);
  }

  // Dhikr specific completed cycles/rounds
  int getTasbeehItemCycles(String id) {
    return _prefs?.getInt('tasbeeh_item_cycles_$id') ?? 0;
  }

  Future<void> setTasbeehItemCycles(String id, int cycles) async {
    await _prefs?.setInt('tasbeeh_item_cycles_$id', cycles);
  }

  // Tasbeeh Vibration Setting
  bool getTasbeehVibrationEnabled() {
    return _prefs?.getBool('tasbeeh_vibration_enabled') ?? true;
  }

  Future<void> setTasbeehVibrationEnabled(bool enabled) async {
    await _prefs?.setBool('tasbeeh_vibration_enabled', enabled);
  }

  // Tasbeeh Sound Setting
  bool getTasbeehSoundEnabled() {
    return _prefs?.getBool('tasbeeh_sound_enabled') ?? false;
  }

  Future<void> setTasbeehSoundEnabled(bool enabled) async {
    await _prefs?.setBool('tasbeeh_sound_enabled', enabled);
  }

  // Daily Statistics
  int getTasbeehDateCount(String dateStr) {
    return _prefs?.getInt('tasbeeh_stat_date_$dateStr') ?? 0;
  }

  Future<void> setTasbeehDateCount(String dateStr, int count) async {
    await _prefs?.setInt('tasbeeh_stat_date_$dateStr', count);
  }

  // Lifetime Total Statistics
  int getTasbeehTotalCount() {
    return _prefs?.getInt('tasbeeh_stat_total_lifetime') ?? 0;
  }

  Future<void> setTasbeehTotalCount(int count) async {
    await _prefs?.setInt('tasbeeh_stat_total_lifetime', count);
  }

  // Reset all Tasbeeh statistics
  Future<void> resetAllTasbeehStats() async {
    await _prefs?.remove('tasbeeh_stat_total_lifetime');
    final keys = _prefs?.getKeys() ?? {};
    for (final k in keys) {
      if (k.startsWith('tasbeeh_stat_date_')) {
        await _prefs?.remove(k);
      }
    }
  }

  // Adhkar completion for today
  List<String> getTodayCompletedAdhkar() {
    return _prefs?.getStringList('today_completed_adhkar') ?? [];
  }

  Future<void> setTodayCompletedAdhkar(List<String> ids) async {
    await _prefs?.setStringList('today_completed_adhkar', ids);
  }

  // Individual Dhikr Progress Count
  int getDhikrCount(String id) {
    return _prefs?.getInt('dhikr_count_$id') ?? 0;
  }

  Future<void> setDhikrCount(String id, int count) async {
    await _prefs?.setInt('dhikr_count_$id', count);
  }

  // Playback Speed
  double getPlaybackSpeed() {
    return _prefs?.getDouble('playback_speed') ?? 1.0;
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _prefs?.setDouble('playback_speed', speed);
  }

  // Theme Mode ('serene_purple', 'noor_blue', 'dark')
  String getAppTheme() {
    return _prefs?.getString('app_theme') ?? 'serene_purple';
  }

  Future<void> setAppTheme(String theme) async {
    await _prefs?.setString('app_theme', theme);
  }

  // Arabic Font Size Scale
  double getArabicFontSize() {
    return _prefs?.getDouble('arabic_font_size') ?? 20.0;
  }

  Future<void> setArabicFontSize(double size) async {
    await _prefs?.setDouble('arabic_font_size', size);
  }

  // Quran Reader Preferences
  double getQuranArabicFontSize() {
    return _prefs?.getDouble('quran_arabic_font_size') ?? 26.0;
  }

  Future<void> setQuranArabicFontSize(double size) async {
    await _prefs?.setDouble('quran_arabic_font_size', size);
  }

  double getQuranSomaliFontSize() {
    return _prefs?.getDouble('quran_somali_font_size') ?? 15.0;
  }

  Future<void> setQuranSomaliFontSize(double size) async {
    await _prefs?.setDouble('quran_somali_font_size', size);
  }

  String getQuranReaderTheme() {
    final theme = _prefs?.getString('quran_reader_theme') ?? 'serene';
    if (theme == 'sepia') return 'serene';
    return theme;
  }

  Future<void> setQuranReaderTheme(String theme) async {
    await _prefs?.setString('quran_reader_theme', theme);
  }

  int getLastReadSurah() {
    return _prefs?.getInt('last_read_surah') ?? 2;
  }

  int getLastReadAyah() {
    return _prefs?.getInt('last_read_ayah') ?? 152;
  }

  Future<void> setLastRead(int surah, int ayah) async {
    await _prefs?.setInt('last_read_surah', surah);
    await _prefs?.setInt('last_read_ayah', ayah);
  }

  List<String> getBookmarkedAyahs() {
    return _prefs?.getStringList('bookmarked_ayahs') ?? [];
  }

  Future<void> toggleBookmarkAyah(int surah, int ayah) async {
    final list = getBookmarkedAyahs();
    final key = '$surah:$ayah';
    if (list.contains(key)) {
      list.remove(key);
    } else {
      list.add(key);
    }
    await _prefs?.setStringList('bookmarked_ayahs', list);
  }

  bool isAyahBookmarked(int surah, int ayah) {
    return getBookmarkedAyahs().contains('$surah:$ayah');
  }

  // 2. Prayer Notifications
  bool getPrayerNotificationsEnabled() {
    return _prefs?.getBool('prayer_notifications_enabled') ?? true;
  }

  Future<void> setPrayerNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool('prayer_notifications_enabled', enabled);
  }

  bool getPrayerItemEnabled(String prayerKey) {
    return _prefs?.getBool('prayer_enabled_$prayerKey') ?? true;
  }

  Future<void> setPrayerItemEnabled(String prayerKey, bool enabled) async {
    await _prefs?.setBool('prayer_enabled_$prayerKey', enabled);
  }

  String getPrayerTime(String prayerKey, String defaultTime) {
    return _prefs?.getString('prayer_time_$prayerKey') ?? defaultTime;
  }

  Future<void> setPrayerTime(String prayerKey, String time) async {
    await _prefs?.setString('prayer_time_$prayerKey', time);
  }

  // 3. Adhkar Reminders
  bool getAdhkarReminderEnabled() {
    return _prefs?.getBool('adhkar_reminder_enabled') ?? true;
  }

  Future<void> setAdhkarReminderEnabled(bool enabled) async {
    await _prefs?.setBool('adhkar_reminder_enabled', enabled);
  }

  bool getMorningAdhkarEnabled() {
    return _prefs?.getBool('adhkar_morning_enabled') ?? true;
  }

  Future<void> setMorningAdhkarEnabled(bool enabled) async {
    await _prefs?.setBool('adhkar_morning_enabled', enabled);
  }

  bool getEveningAdhkarEnabled() {
    return _prefs?.getBool('adhkar_evening_enabled') ?? true;
  }

  Future<void> setEveningAdhkarEnabled(bool enabled) async {
    await _prefs?.setBool('adhkar_evening_enabled', enabled);
  }

  String getMorningAdhkarTime() {
    return _prefs?.getString('adhkar_morning_time') ?? '06:30';
  }

  Future<void> setMorningAdhkarTime(String time) async {
    await _prefs?.setString('adhkar_morning_time', time);
  }

  String getEveningAdhkarTime() {
    return _prefs?.getString('adhkar_evening_time') ?? '17:30';
  }

  Future<void> setEveningAdhkarTime(String time) async {
    await _prefs?.setString('adhkar_evening_time', time);
  }

  // 4. Quran Online Audio Streaming Preferences
  int getSelectedReciterId() {
    return _prefs?.getInt('selected_reciter_id') ?? 123; // Default: Mishary Alafasy (id 123)
  }

  Future<void> setSelectedReciterId(int id) async {
    await _prefs?.setInt('selected_reciter_id', id);
  }

  bool getAutoPlayNextSurah() {
    return _prefs?.getBool('auto_play_next_surah') ?? true;
  }

  Future<void> setAutoPlayNextSurah(bool value) async {
    await _prefs?.setBool('auto_play_next_surah', value);
  }

  int getLastPlayedSurah() {
    return _prefs?.getInt('last_played_surah') ?? 1;
  }

  Future<void> setLastPlayedSurah(int surahNumber) async {
    await _prefs?.setInt('last_played_surah', surahNumber);
  }

  int getPlaybackPosition(String mediaId) {
    return _prefs?.getInt('playback_pos_$mediaId') ?? 0;
  }

  Future<void> setPlaybackPosition(String mediaId, int seconds) async {
    await _prefs?.setInt('playback_pos_$mediaId', seconds);
  }

  String? getCustomSetting(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setCustomSetting(String key, String value) async {
    await _prefs?.setString(key, value);
  }
}
