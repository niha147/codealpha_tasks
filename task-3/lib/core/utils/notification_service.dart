import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  bool get isSupported {
    if (kIsWeb) return false;
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return true;
    return false; // Disable local notifications on Windows/Linux
  }

  Future<void> init() async {
    if (!isSupported) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
    await _flutterLocalNotificationsPlugin!.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    tz.initializeTimeZones();
    // Coach Engine now takes over scheduling in main.dart
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (_flutterLocalNotificationsPlugin == null) return;
    try {
      await _flutterLocalNotificationsPlugin!.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel',
            'Daily Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Notification scheduling failed: \$e");
    }
  }

  Future<void> sendDailyCoachMessage(int streak, String workout) async {
    final message =
        "Coach says: \$workout\nStay consistent and level up today 💯";
    await scheduleDailyNotification(
      id: 2,
      title: "Your Fitness Coach 🧠",
      body: message,
      hour: 8,
      minute: 0,
    );
  }

  Future<void> sendWeeklySummary(int streak, int workoutsCompleted) async {
    if (_flutterLocalNotificationsPlugin == null) return;
    String message;
    if (streak >= 5) {
      message = "🔥 Excellent week! You're building a strong habit!";
    } else if (streak >= 3) {
      message = "💪 Good job! Keep pushing to build consistency!";
    } else {
      message = "🚀 New week, new start! Let's stay consistent!";
    }

    try {
      await _flutterLocalNotificationsPlugin!.show(
        id: 100,
        title: "Weekly Fitness Report",
        body: message,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_channel',
            'Weekly Summary',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Weekly summary notification failed: \$e");
    }
  }

  Future<void> sendBadgeUnlockNotification(
    int id,
    String title,
    String body,
  ) async {
    if (_flutterLocalNotificationsPlugin == null) return;
    try {
      await _flutterLocalNotificationsPlugin!.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'badge_channel',
            'Achievements',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Badge unlock notification failed: \$e");
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
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

  Future<void> showWaterReminder() async {
    if (!isSupported || _flutterLocalNotificationsPlugin == null) return;

    await _flutterLocalNotificationsPlugin!.show(
      id: 3,
      title: '💧 Time to hydrate!',
      body: 'You\'re behind your water goal. Have a glass of water.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_alerts',
          'Water Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showGoalCelebration(String title, String body) async {
    if (!isSupported || _flutterLocalNotificationsPlugin == null) return;

    await _flutterLocalNotificationsPlugin!.show(
      id: 4,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'celebrations',
          'Celebrations',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showSedentaryAlert() async {
    if (!isSupported || _flutterLocalNotificationsPlugin == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'sedentary_channel',
          'Sedentary Alerts',
          channelDescription: 'Reminders to move',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin!.show(
      id: 0,
      title: 'Time to move!',
      body: 'You\'ve been inactive for a while. Take a short walk.',
      notificationDetails: platformChannelSpecifics,
    );
  }
}
