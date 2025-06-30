import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class DeadlineNotificationService {
  static final DeadlineNotificationService _instance =
      DeadlineNotificationService._internal();
  factory DeadlineNotificationService() => _instance;
  DeadlineNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<void> scheduleDeadlineNotification({
    required int prdId,
    required DateTime deadline,
    required String prdName,
  }) async {
    await init();
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(deadline, tz.local);
    await _notifications.zonedSchedule(
      prdId, // Use PRD ID as notification ID
      'PRD Deadline Reminder',
      'The deadline for "$prdName" is today!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prd_deadline_channel',
          'PRD Deadlines',
          channelDescription: 'Notifications for PRD deadlines',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancelDeadlineNotification(int prdId) async {
    await init();
    await _notifications.cancel(prdId);
  }
}
