import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:genprd/features/prd/services/notification_schedule_service.dart';

class DeadlineNotificationService {
  static final DeadlineNotificationService _instance =
      DeadlineNotificationService._internal();
  factory DeadlineNotificationService() => _instance;
  DeadlineNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final NotificationScheduleService _scheduleService =
      NotificationScheduleService();
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'prd_deadline_channel',
    'PRD Deadlines',
    description: 'Notifications for PRD deadlines',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  Future<void> init() async {
    if (_initialized) {
      debugPrint('[Notification] Already initialized, skipping...');
      return;
    }
    debugPrint('[Notification] Starting initialization...');

    try {
      // Initialize timezone
      debugPrint('[Notification] Initializing timezone...');
      tz.initializeTimeZones();
      try {
        // Try to set the local timezone using the device's timeZoneName
        final String deviceTimeZone = DateTime.now().timeZoneName;
        tz.setLocalLocation(tz.getLocation(deviceTimeZone));
        debugPrint('[Notification] Set timezone to: $deviceTimeZone');
      } catch (e) {
        debugPrint('[Notification] Failed to set timezone, defaulting to UTC');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
      debugPrint('[Notification] tz.local: ${tz.local.name}');

      // Initialize settings
      debugPrint('[Notification] Setting up notification settings...');
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      // Initialize with callback
      debugPrint('[Notification] Initializing notification plugin...');
      final bool? initResult = await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[Notification] Notification tapped: ${response.payload}');
        },
      );
      debugPrint('[Notification] Plugin initialization result: $initResult');

      _initialized = true;
      debugPrint('[Notification] Initialization complete');
    } catch (e, stackTrace) {
      debugPrint('[Notification] Error during initialization: $e');
      debugPrint('[Notification] Stack trace: $stackTrace');
      _initialized = false;
    }
  }

  Future<bool> checkAndRequestPermissions() async {
    debugPrint('[Notification] Checking all required permissions...');

    // Check notification permission
    final notificationStatus = await Permission.notification.status;
    debugPrint(
      '[Notification] Notification permission status: $notificationStatus',
    );

    if (!notificationStatus.isGranted) {
      debugPrint('[Notification] Requesting notification permission...');
      final notificationResult = await Permission.notification.request();
      if (!notificationResult.isGranted) {
        debugPrint('[Notification] Notification permission denied');
        return false;
      }
    }

    // Check exact alarm permission
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    debugPrint('[Notification] Exact alarm permission status: $alarmStatus');

    if (!alarmStatus.isGranted) {
      debugPrint('[Notification] Requesting exact alarm permission...');
      final alarmResult = await Permission.scheduleExactAlarm.request();
      if (!alarmResult.isGranted) {
        debugPrint('[Notification] Exact alarm permission denied');
        return false;
      }
    }

    // Get Android-specific plugin
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      debugPrint(
        '[Notification] Requesting Android notification permission...',
      );
      final androidPermission =
          await androidPlugin.requestNotificationsPermission();
      debugPrint(
        '[Notification] Android permission result: $androidPermission',
      );

      if (androidPermission == false) {
        debugPrint('[Notification] Android notification permission denied');
        return false;
      }

      // Ensure notification channel exists
      debugPrint('[Notification] Creating/updating notification channel...');
      await androidPlugin.createNotificationChannel(_channel);
    }

    debugPrint('[Notification] All permissions granted and channel created');
    return true;
  }

  Future<bool> _requestExactAlarmPermission() async {
    try {
      debugPrint('[Notification] Checking exact alarm permission...');
      final status = await Permission.scheduleExactAlarm.status;
      debugPrint(
        '[Notification] Current exact alarm permission status: $status',
      );

      if (status.isDenied) {
        debugPrint('[Notification] Requesting exact alarm permission...');
        final result = await Permission.scheduleExactAlarm.request();
        debugPrint('[Notification] Exact alarm permission result: $result');
        return result.isGranted;
      }
      return status.isGranted;
    } catch (e) {
      debugPrint(
        '[Notification] Error checking/requesting exact alarm permission: $e',
      );
      return false;
    }
  }

  Future<void> showTestNotification() async {
    debugPrint('[Notification] Starting test notification sequence...');

    try {
      await init();

      // Check permissions
      if (!await checkAndRequestPermissions()) {
        debugPrint('[Notification] Required permissions not granted');
        return;
      }

      // Show immediate notification
      debugPrint('[Notification] Attempting to show immediate notification...');
      await _notifications.show(
        99998,
        'Immediate Test Notification',
        'This is an immediate test notification!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
      );
      debugPrint('[Notification] Immediate notification sent successfully');

      // Schedule delayed notification
      debugPrint(
        '[Notification] Attempting to schedule delayed notification...',
      );
      final scheduledTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 10));
      await _notifications.zonedSchedule(
        99999,
        'Scheduled Test Notification',
        'This is a scheduled test notification (10 seconds)!',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
        '[Notification] Delayed notification scheduled for: $scheduledTime',
      );
    } catch (e, stackTrace) {
      debugPrint('[Notification] Error in test notification: $e');
      debugPrint('[Notification] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> scheduleDeadlineNotification({
    required int prdId,
    required DateTime deadline,
    required String prdName,
  }) async {
    debugPrint(
      '[Notification] Scheduling deadline notification for PRD: $prdName',
    );
    await init();

    // Check permissions
    if (!await checkAndRequestPermissions()) {
      debugPrint('[Notification] Required permissions not granted');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour') ?? 8;
    final minute = prefs.getInt('notification_minute') ?? 0;
    debugPrint(
      '[Notification] Using notification time - Hour: $hour, Minute: $minute',
    );

    // Schedule day-before notification
    final dayBeforeDate = deadline.subtract(const Duration(days: 1));
    final dayBeforeDateTime = DateTime(
      dayBeforeDate.year,
      dayBeforeDate.month,
      dayBeforeDate.day,
      hour,
      minute,
    );
    final dayBeforeTZDateTime = tz.TZDateTime.from(dayBeforeDateTime, tz.local);

    // Schedule deadline day notification
    final deadlineDateTime = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      hour,
      minute,
    );
    final deadlineTZDateTime = tz.TZDateTime.from(deadlineDateTime, tz.local);

    final now = tz.TZDateTime.now(tz.local);

    // Schedule day-before notification if it's in the future
    if (dayBeforeTZDateTime.isAfter(now)) {
      debugPrint(
        '[Notification] Scheduling day-before notification for: $dayBeforeTZDateTime',
      );
      await _notifications.zonedSchedule(
        prdId * 2, // Use even numbers for day-before notifications
        'PRD Deadline Tomorrow',
        'The deadline for "$prdName" is tomorrow!',
        dayBeforeTZDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
        '[Notification] Day-before notification scheduled successfully',
      );
    } else {
      debugPrint('[Notification] Day-before time is in the past, skipping.');
    }

    // Schedule deadline day notification if it's in the future
    if (deadlineTZDateTime.isAfter(now)) {
      debugPrint(
        '[Notification] Scheduling deadline day notification for: $deadlineTZDateTime',
      );
      await _notifications.zonedSchedule(
        prdId * 2 + 1, // Use odd numbers for deadline day notifications
        'PRD Deadline Today',
        'Today is the deadline for "$prdName"!',
        deadlineTZDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
        '[Notification] Deadline day notification scheduled successfully',
      );
    } else {
      debugPrint('[Notification] Deadline time is in the past, skipping.');
    }
  }

  Future<void> cancelDeadlineNotification(int prdId) async {
    await init();
    debugPrint('[Notification] Cancelling notifications for PRD ID: $prdId');
    // Cancel both day-before and deadline day notifications
    await _notifications.cancel(prdId * 2); // Cancel day-before notification
    await _notifications.cancel(
      prdId * 2 + 1,
    ); // Cancel deadline day notification
    debugPrint('[Notification] Notifications cancelled successfully');
  }

  Future<void> scheduleExactNotification({
    required int prdId,
    required DateTime dateTime,
    required String prdName,
  }) async {
    await init();

    if (!await _requestExactAlarmPermission()) {
      debugPrint('[Notification] Exact alarm permission denied');
      return;
    }

    final scheduledTZDateTime = tz.TZDateTime.from(dateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (scheduledTZDateTime.isBefore(now)) {
      debugPrint('[Notification] Not scheduling: time is in the past.');
      return;
    }
    await _notifications.zonedSchedule(
      prdId,
      'PRD Deadline Reminder',
      'This is a test notification for "$prdName"!',
      scheduledTZDateTime,
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
    );
    debugPrint('[Notification] Test notification scheduled successfully.');
  }

  Future<void> testScheduledTimeNotification() async {
    debugPrint('[Notification] Testing notification at saved time...');

    try {
      await init();

      // Check permissions
      if (!await checkAndRequestPermissions()) {
        debugPrint('[Notification] Required permissions not granted');
        return;
      }

      // Get saved notification time from SQLite
      final schedule = await _scheduleService.getSchedule();
      if (schedule == null) {
        debugPrint('[Notification] No schedule found in database');
        return;
      }

      final hour = schedule.hour;
      final minute = schedule.minute;
      debugPrint(
        '[Notification] Retrieved saved time - Hour: $hour, Minute: $minute',
      );

      // Get current time in local timezone
      final now = DateTime.now();
      final location = tz.local;
      debugPrint('[Notification] Local timezone: ${location.name}');
      debugPrint('[Notification] Current time: $now');

      // Schedule immediate test notification (5 seconds from now)
      final immediateTest = now.add(const Duration(seconds: 5));
      debugPrint(
        '[Notification] Scheduling immediate test for: $immediateTest',
      );

      await _notifications.zonedSchedule(
        99994,
        'Immediate Test',
        'This should appear in 5 seconds',
        tz.TZDateTime.from(immediateTest, location),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('[Notification] Immediate test scheduled');

      // Schedule short test (2 minutes from now)
      final shortTest = now.add(const Duration(minutes: 2));
      debugPrint('[Notification] Scheduling 2-minute test for: $shortTest');

      await _notifications.zonedSchedule(
        99995,
        '2-Minute Test',
        'This should appear in 2 minutes',
        tz.TZDateTime.from(shortTest, location),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('[Notification] 2-minute test scheduled');

      // Calculate next occurrence of daily notification
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint(
          '[Notification] Time passed, scheduling for tomorrow: $scheduledDate',
        );
      }

      debugPrint(
        '[Notification] Scheduling daily notification for: $scheduledDate',
      );

      // Schedule daily notification
      await _notifications.zonedSchedule(
        99997,
        'Daily Test',
        'This is your daily notification for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
        tz.TZDateTime.from(scheduledDate, location),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('[Notification] Daily notification scheduled');

      // Show confirmation with all scheduled times
      await _notifications.show(
        99996,
        'Test Notifications Scheduled',
        '5-second test at: ${immediateTest.toString()}\n'
            '2-minute test at: ${shortTest.toString()}\n'
            'Daily notification at: ${scheduledDate.toString()}',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: _channel.importance,
            priority: Priority.high,
            channelShowBadge: true,
            playSound: _channel.playSound,
            enableLights: _channel.enableLights,
            enableVibration: _channel.enableVibration,
            icon: '@mipmap/ic_launcher',
            ticker: 'GenPRD Notification',
          ),
        ),
      );
      debugPrint('[Notification] Confirmation notification sent');
    } catch (e, stackTrace) {
      debugPrint('[Notification] Error testing scheduled time: $e');
      debugPrint('[Notification] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
