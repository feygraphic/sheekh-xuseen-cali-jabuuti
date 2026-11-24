import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_colors.dart';
import '../models/adhkar_category_model.dart';
import '../providers/adhkar_provider.dart';
import '../screens/adhkar_category_screen.dart';

/// Notification Service for Sheikh Xuseen Cali Jabuuti App.
/// Handles fully functional Daily Morning and Evening Adhkar reminders.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static const String channelId = 'com.sheekhxuseen.app.adhkar_reminders';
  static const String channelName = 'Daily Adhkar Reminders';
  static const String channelDescription =
      'Daily reminders for Morning and Evening Adhkar remembrance';

  static const int morningNotificationId = 1001;
  static const int eveningNotificationId = 1002;
  static const int testNotificationId = 1003;

  bool _isInitialized = false;
  String? _pendingPayload;
  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    if (_pendingPayload != null) {
      final payload = _pendingPayload;
      _pendingPayload = null;
      Future.delayed(const Duration(milliseconds: 600), () {
        handleNotificationPayload(payload);
      });
    }
  }

  /// Initialize local notifications and local timezone
  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    if (_isInitialized) return;
    if (navigatorKey != null) _navigatorKey = navigatorKey;

    try {
      // 1. Timezone Setup
      tz.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        final String currentTimeZone = timezoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
      } catch (tzError) {
        debugPrint('FlutterTimezone lookup error, using UTC fallback: $tzError');
      }

      // 2. Android Initialization Settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('drawable/ic_notification');

      // 3. Darwin (iOS) Initialization Settings
      const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            handleNotificationPayload(payload);
          }
        },
      );

      // Create Notification Channel explicitly for Android
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }

      // 4. Check if the app was launched by tapping a notification
      final launchDetails = await _notifications.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _pendingPayload = launchDetails?.notificationResponse?.payload;
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Request Android 13+ Notification Permission
  Future<bool> requestNotificationPermission() async {
    try {
      if (kIsWeb) return false;
      final status = await Permission.notification.status;
      if (status.isGranted) return true;

      final result = await Permission.notification.request();
      return result.isGranted;
    } catch (e) {
      // Fallback for tests or unsupported environments
      return false;
    }
  }

  NotificationDetails _buildNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: 'drawable/ic_notification',
        color: AppColors.primary,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Ensures timezone data is initialized
  void _ensureTimezone() {
    try {
      tz.local;
    } catch (_) {
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
  }

  /// Calculates the next TZDateTime instance for the given hour and minute
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    _ensureTimezone();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedule Morning Adhkar Reminder (Default 06:30 AM)
  Future<void> scheduleMorningAdhkar({required int hour, required int minute}) async {
    await cancelMorningAdhkar();

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    const title = '🌅 Morning Adhkar Reminder';
    const body =
        'It is time for your morning remembrance. Take a few minutes to remember Allah.';
    const payload = 'category:morning';

    await _zonedScheduleWithFallback(
      id: morningNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
    debugPrint('Morning Adhkar scheduled at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} (Next: $scheduledDate)');
  }

  /// Schedule Evening Adhkar Reminder (Default 05:30 PM / 17:30)
  Future<void> scheduleEveningAdhkar({required int hour, required int minute}) async {
    await cancelEveningAdhkar();

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    const title = '🌙 Evening Adhkar Reminder';
    const body =
        'It is time for your evening remembrance. Do not forget your daily Adhkar.';
    const payload = 'category:evening';

    await _zonedScheduleWithFallback(
      id: eveningNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
    debugPrint('Evening Adhkar scheduled at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} (Next: $scheduledDate)');
  }

  /// Helper to safely schedule exact alarms with fallback to inexact when restricted
  Future<void> _zonedScheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String payload,
  }) async {
    final details = _buildNotificationDetails();
    try {
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      if (!e.toString().contains('LateInitializationError')) {
        debugPrint('Exact alarm scheduling failed: $e. Retrying with inexactAllowWhileIdle.');
      }
      try {
        await _notifications.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (inner) {
        if (!inner.toString().contains('LateInitializationError')) {
          debugPrint('Inexact alarm scheduling error: $inner');
        }
      }
    }
  }

  /// Cancel Morning Adhkar
  Future<void> cancelMorningAdhkar() async {
    try {
      await _notifications.cancel(id: morningNotificationId);
    } catch (_) {
      // Safe catch for uninitialized platform channels in tests
    }
  }

  /// Cancel Evening Adhkar
  Future<void> cancelEveningAdhkar() async {
    try {
      await _notifications.cancel(id: eveningNotificationId);
    } catch (_) {
      // Safe catch for uninitialized platform channels in tests
    }
  }

  /// Cancel all scheduled Adhkar notifications
  Future<void> cancelAllAdhkar() async {
    await cancelMorningAdhkar();
    await cancelEveningAdhkar();
  }

  /// Send immediate Test Notification
  Future<void> showTestNotification({bool isMorning = true}) async {
    await requestNotificationPermission();
    final details = _buildNotificationDetails();

    final title = isMorning ? '🌅 Morning Adhkar Reminder' : '🌙 Evening Adhkar Reminder';
    final body = isMorning
        ? 'It is time for your morning remembrance. Take a few minutes to remember Allah.'
        : 'It is time for your evening remembrance. Do not forget your daily Adhkar.';
    final payload = isMorning ? 'category:morning' : 'category:evening';

    try {
      await _notifications.show(
        id: testNotificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
      debugPrint('Test notification displayed successfully.');
    } catch (e) {
      debugPrint('Error displaying test notification: $e');
    }
  }

  /// Sync all scheduled reminders with current SettingsProvider state
  Future<void> syncWithSettings({
    required bool masterEnabled,
    required bool morningEnabled,
    required bool eveningEnabled,
    required String morningTimeStr,
    required String eveningTimeStr,
  }) async {
    if (!masterEnabled) {
      await cancelAllAdhkar();
      debugPrint('Master Adhkar Reminders disabled. Cancelled all reminders.');
      return;
    }

    await requestNotificationPermission();

    // 1. Morning Adhkar
    if (morningEnabled) {
      final parts = morningTimeStr.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 6 : 6;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 30 : 30;
      await scheduleMorningAdhkar(hour: hour, minute: minute);
    } else {
      await cancelMorningAdhkar();
    }

    // 2. Evening Adhkar
    if (eveningEnabled) {
      final parts = eveningTimeStr.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 17 : 17;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 30 : 30;
      await scheduleEveningAdhkar(hour: hour, minute: minute);
    } else {
      await cancelEveningAdhkar();
    }
  }

  /// Handles notification tap and navigates directly to the Morning or Evening Adhkar section
  void handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    debugPrint('Handling notification payload: $payload');

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      _pendingPayload = payload;
      return;
    }

    String categoryId = 'morning';
    if (payload.contains('evening') || payload.contains('galab')) {
      categoryId = 'evening';
    } else if (payload.contains('morning') || payload.contains('subax')) {
      categoryId = 'morning';
    }

    _navigateToCategory(context, categoryId);
  }

  /// Open Morning or Evening Adhkar section dynamically
  void _navigateToCategory(BuildContext context, String categoryId) {
    try {
      final adhkarProv = Provider.of<AdhkarProvider>(context, listen: false);
      AdhkarCategoryModel? cat = adhkarProv.getCategoryById(categoryId);

      if (cat == null) {
        if (categoryId == 'morning') {
          cat = const AdhkarCategoryModel(
            id: 'morning',
            arabicTitle: 'أذكار الصباح',
            somaliTitle: 'Adkaar Subax',
            englishTitle: 'Morning Adhkar',
            description: 'Xuska iyo dhowrsoonaanta bilowga maalinta cusub.',
            icon: 'wb_sunny_rounded',
            duaCount: 23,
            jsonFile: 'morning.json',
          );
        } else {
          cat = const AdhkarCategoryModel(
            id: 'evening',
            arabicTitle: 'أذكار المساء',
            somaliTitle: 'Adkaar Galab',
            englishTitle: 'Evening Adhkar',
            description: 'Xuska iyo ilaalinta nafta xilliga gabbalka.',
            icon: 'wb_twilight_rounded',
            duaCount: 22,
            jsonFile: 'evening.json',
          );
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => AdhkarCategoryScreen(category: cat!),
        ),
      );
    } catch (e) {
      debugPrint('Navigation error from notification payload: $e');
    }
  }

  /// Process any pending notification payload that opened the app
  void checkPendingNotificationLaunch(BuildContext context) {
    if (_pendingPayload != null) {
      final payload = _pendingPayload;
      _pendingPayload = null;
      Future.delayed(const Duration(milliseconds: 500), () {
        handleNotificationPayload(payload);
      });
    }
  }
}
