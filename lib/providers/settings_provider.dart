import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  // 1. Theme Mode ('light' | 'dark')
  String _themeMode = 'light';

  // 2. Prayer Notifications
  bool _prayerNotificationsEnabled = true;
  final Map<String, bool> _prayerItemsEnabled = {
    'fajr': true,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
  };
  final Map<String, String> _prayerTimes = {
    'fajr': '05:15',
    'dhuhr': '12:30',
    'asr': '15:45',
    'maghrib': '18:15',
    'isha': '19:45',
  };

  // 3. Adhkar Reminders
  bool _adhkarReminderEnabled = true;
  bool _adhkarMorningEnabled = true;
  bool _adhkarEveningEnabled = true;
  String _adhkarMorningTime = '06:30';
  String _adhkarEveningTime = '17:30';

  // Legacy compatibility
  double _arabicFontSize = 20.0;
  bool _autoPlayNext = true;
  bool _downloadsWifiOnly = true;

  SettingsProvider(this._storage) {
    _load();
  }

  // 1. Theme Getters
  String get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == 'dark';
  String get themeName => _themeMode;
  bool get isNoorBlue => false;

  // 2. Prayer Notifications Getters
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool isPrayerEnabled(String key) => _prayerItemsEnabled[key] ?? true;
  String getPrayerTime(String key) => _prayerTimes[key] ?? '12:00';

  // 3. Adhkar Reminders Getters
  bool get adhkarReminderEnabled => _adhkarReminderEnabled;
  bool get adhkarMorningEnabled => _adhkarMorningEnabled;
  bool get adhkarEveningEnabled => _adhkarEveningEnabled;
  String get adhkarMorningTime => _adhkarMorningTime;
  String get adhkarEveningTime => _adhkarEveningTime;

  // Legacy getters
  double get arabicFontSize => _arabicFontSize;
  bool get notificationsEnabled => _prayerNotificationsEnabled;
  bool get autoPlayNext => _autoPlayNext;
  bool get downloadsWifiOnly => _downloadsWifiOnly;

  void _load() {
    final savedTheme = _storage.getAppTheme();
    _themeMode = (savedTheme == 'dark') ? 'dark' : 'light';

    // Load prayer settings
    _prayerNotificationsEnabled = _storage.getPrayerNotificationsEnabled();
    for (final key in _prayerTimes.keys.toList()) {
      _prayerItemsEnabled[key] = _storage.getPrayerItemEnabled(key);
      _prayerTimes[key] = _storage.getPrayerTime(key, _prayerTimes[key]!);
    }

    // Load adhkar reminder settings
    _adhkarReminderEnabled = _storage.getAdhkarReminderEnabled();
    _adhkarMorningEnabled = _storage.getMorningAdhkarEnabled();
    _adhkarEveningEnabled = _storage.getEveningAdhkarEnabled();
    _adhkarMorningTime = _storage.getMorningAdhkarTime();
    _adhkarEveningTime = _storage.getEveningAdhkarTime();

    _arabicFontSize = _storage.getArabicFontSize();
    notifyListeners();
    _syncAdhkarNotifications();
  }

  Future<void> _syncAdhkarNotifications() async {
    try {
      await NotificationService.instance.syncWithSettings(
        masterEnabled: _adhkarReminderEnabled,
        morningEnabled: _adhkarMorningEnabled,
        eveningEnabled: _adhkarEveningEnabled,
        morningTimeStr: _adhkarMorningTime,
        eveningTimeStr: _adhkarEveningTime,
      );
    } catch (e) {
      debugPrint('Error syncing Adhkar notifications in SettingsProvider: $e');
    }
  }

  // 1. Theme Action
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode == 'dark' ? 'dark' : 'light';
    await _storage.setAppTheme(_themeMode);
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    await setThemeMode(theme);
  }

  // 2. Prayer Actions
  Future<void> setPrayerNotificationsEnabled(bool enabled) async {
    _prayerNotificationsEnabled = enabled;
    await _storage.setPrayerNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> togglePrayerItem(String prayerKey, bool enabled) async {
    _prayerItemsEnabled[prayerKey] = enabled;
    await _storage.setPrayerItemEnabled(prayerKey, enabled);
    notifyListeners();
  }

  Future<void> setPrayerTime(String prayerKey, String time) async {
    _prayerTimes[prayerKey] = time;
    await _storage.setPrayerTime(prayerKey, time);
    notifyListeners();
  }

  // 3. Adhkar Actions
  Future<void> setAdhkarReminderEnabled(bool enabled) async {
    _adhkarReminderEnabled = enabled;
    await _storage.setAdhkarReminderEnabled(enabled);
    notifyListeners();
    await _syncAdhkarNotifications();
  }

  Future<void> setMorningAdhkarEnabled(bool enabled) async {
    _adhkarMorningEnabled = enabled;
    await _storage.setMorningAdhkarEnabled(enabled);
    notifyListeners();
    await _syncAdhkarNotifications();
  }

  Future<void> setEveningAdhkarEnabled(bool enabled) async {
    _adhkarEveningEnabled = enabled;
    await _storage.setEveningAdhkarEnabled(enabled);
    notifyListeners();
    await _syncAdhkarNotifications();
  }

  Future<void> setMorningAdhkarTime(String time) async {
    _adhkarMorningTime = time;
    await _storage.setMorningAdhkarTime(time);
    notifyListeners();
    await _syncAdhkarNotifications();
  }

  Future<void> setEveningAdhkarTime(String time) async {
    _adhkarEveningTime = time;
    await _storage.setEveningAdhkarTime(time);
    notifyListeners();
    await _syncAdhkarNotifications();
  }

  // Legacy actions
  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    await _storage.setArabicFontSize(size);
    notifyListeners();
  }

  void toggleNotifications(bool val) {
    setPrayerNotificationsEnabled(val);
  }

  void toggleAutoPlay(bool val) {
    _autoPlayNext = val;
    notifyListeners();
  }

  void toggleDownloadsWifiOnly(bool val) {
    _downloadsWifiOnly = val;
    notifyListeners();
  }
}
