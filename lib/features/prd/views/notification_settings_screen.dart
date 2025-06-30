import 'package:flutter/material.dart';
import 'package:genprd/features/prd/services/deadline_notification_service.dart';
import 'package:genprd/features/prd/services/notification_schedule_service.dart';
import 'package:genprd/features/prd/models/notification_schedule.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _loading = true;
  final _scheduleService = NotificationScheduleService();

  @override
  void initState() {
    super.initState();
    _loadTime();
  }

  Future<void> _loadTime() async {
    try {
      debugPrint('[NotificationSettings] Loading saved notification time...');
      final schedule = await _scheduleService.getSchedule();

      if (schedule != null) {
        debugPrint(
          '[NotificationSettings] Loaded time - Hour: ${schedule.hour}, Minute: ${schedule.minute}',
        );

        setState(() {
          _selectedTime = TimeOfDay(
            hour: schedule.hour,
            minute: schedule.minute,
          );
          _loading = false;
        });
      } else {
        debugPrint(
          '[NotificationSettings] No saved schedule found, using default',
        );
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[NotificationSettings] Error loading time: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickTime() async {
    try {
      debugPrint('[NotificationSettings] Opening time picker...');
      final picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (picked != null && mounted) {
        debugPrint(
          '[NotificationSettings] New time selected: ${picked.format(context)}',
        );
        setState(() {
          _selectedTime = picked;
        });
      }
    } catch (e) {
      debugPrint('[NotificationSettings] Error picking time: $e');
    }
  }

  Future<void> _saveTime() async {
    try {
      debugPrint('[NotificationSettings] Saving notification time...');

      // Create and save schedule to SQLite
      final schedule = NotificationSchedule(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );

      final savedSchedule = await _scheduleService.saveSchedule(schedule);
      debugPrint(
        '[NotificationSettings] Schedule saved with ID: ${savedSchedule.id}',
      );

      // Initialize notification service
      final notificationService = DeadlineNotificationService();
      await notificationService.init();
      debugPrint('[NotificationSettings] Notification service initialized');

      // Verify permissions and schedule test notification
      final hasPermissions =
          await notificationService.checkAndRequestPermissions();
      debugPrint(
        '[NotificationSettings] Permission check result: $hasPermissions',
      );

      if (hasPermissions) {
        await notificationService.testScheduledTimeNotification();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification time set to ${_selectedTime.format(context)}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[NotificationSettings] Error saving time: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save notification time'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set the time for PRD deadline notifications:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'Notification Time:',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _pickTime,
                          child: Text(_selectedTime.format(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _saveTime,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        debugPrint(
                          '[NotificationSettings] Testing notification...',
                        );
                        await DeadlineNotificationService()
                            .showTestNotification();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test notification sent!'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Test Notification'),
                    ),
                  ],
                ),
              ),
    );
  }
}
