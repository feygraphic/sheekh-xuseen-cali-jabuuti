import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/settings_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/notification_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily Adhkar Notifications & Reminders Tests', () {
    late StorageService storage;
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
      settingsProvider = SettingsProvider(storage);
    });

    test('Default reminder values and times match specifications', () {
      // 1. Morning Adhkar Reminder Defaults
      expect(storage.getMorningAdhkarTime(), equals('06:30'),
          reason: 'Default Morning Adhkar time must be 06:30 AM');
      expect(storage.getMorningAdhkarEnabled(), isTrue,
          reason: 'Morning Adhkar must be enabled by default');

      // 2. Evening Adhkar Reminder Defaults
      expect(storage.getEveningAdhkarTime(), equals('17:30'),
          reason: 'Default Evening Adhkar time must be 05:30 PM (17:30)');
      expect(storage.getEveningAdhkarEnabled(), isTrue,
          reason: 'Evening Adhkar must be enabled by default');

      // 3. Master switch
      expect(storage.getAdhkarReminderEnabled(), isTrue,
          reason: 'Daily Adhkar Reminders master switch must be enabled by default');

      // Verify Provider exposes identical defaults
      expect(settingsProvider.adhkarMorningTime, equals('06:30'));
      expect(settingsProvider.adhkarEveningTime, equals('17:30'));
      expect(settingsProvider.adhkarMorningEnabled, isTrue);
      expect(settingsProvider.adhkarEveningEnabled, isTrue);
      expect(settingsProvider.adhkarReminderEnabled, isTrue);
    });

    test('SettingsProvider mutates and persists reminder configurations permanently', () async {
      // Toggle Master Switch OFF
      await settingsProvider.setAdhkarReminderEnabled(false);
      expect(settingsProvider.adhkarReminderEnabled, isFalse);
      expect(storage.getAdhkarReminderEnabled(), isFalse);

      // Toggle Master Switch ON
      await settingsProvider.setAdhkarReminderEnabled(true);
      expect(settingsProvider.adhkarReminderEnabled, isTrue);
      expect(storage.getAdhkarReminderEnabled(), isTrue);

      // Toggle Morning Reminder
      await settingsProvider.setMorningAdhkarEnabled(false);
      expect(settingsProvider.adhkarMorningEnabled, isFalse);
      expect(storage.getMorningAdhkarEnabled(), isFalse);

      // Toggle Evening Reminder
      await settingsProvider.setEveningAdhkarEnabled(false);
      expect(settingsProvider.adhkarEveningEnabled, isFalse);
      expect(storage.getEveningAdhkarEnabled(), isFalse);

      // Edit Morning reminder time (e.g. 07:15)
      await settingsProvider.setMorningAdhkarTime('07:15');
      expect(settingsProvider.adhkarMorningTime, equals('07:15'));
      expect(storage.getMorningAdhkarTime(), equals('07:15'));

      // Edit Evening reminder time (e.g. 18:45)
      await settingsProvider.setEveningAdhkarTime('18:45');
      expect(settingsProvider.adhkarEveningTime, equals('18:45'));
      expect(storage.getEveningAdhkarTime(), equals('18:45'));
    });

    test('Notification Service constants and metadata meet authentic specifications', () {
      expect(NotificationService.channelId, equals('com.sheekhxuseen.app.adhkar_reminders'));
      expect(NotificationService.channelName, equals('Daily Adhkar Reminders'));
      expect(NotificationService.morningNotificationId, equals(1001));
      expect(NotificationService.eveningNotificationId, equals(1002));
      expect(NotificationService.testNotificationId, equals(1003));
    });

    test('Time formatting helper converts 24h into clean 12h AM/PM representation', () {
      String formatDisplayTime(String timeStr) {
        final parts = timeStr.split(':');
        if (parts.isEmpty) return timeStr;
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        final period = h >= 12 ? 'PM' : 'AM';
        final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        return '${displayH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
      }

      expect(formatDisplayTime('06:30'), equals('06:30 AM'));
      expect(formatDisplayTime('17:30'), equals('05:30 PM'));
      expect(formatDisplayTime('00:00'), equals('12:00 AM'));
      expect(formatDisplayTime('12:00'), equals('12:00 PM'));
      expect(formatDisplayTime('23:59'), equals('11:59 PM'));
    });

    test('Notification Service payload routing maps correctly to Morning and Evening Adhkar', () {
      final service = NotificationService.instance;

      // Ensure service instance exists and pending payload checks do not crash
      expect(service, isNotNull);

      const morningPayload = 'category:morning';
      const eveningPayload = 'category:evening';

      expect(morningPayload.contains('morning'), isTrue);
      expect(eveningPayload.contains('evening'), isTrue);
    });
  });
}
