import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:genprd/features/prd/models/notification_schedule.dart';

class NotificationScheduleService {
  static final NotificationScheduleService _instance =
      NotificationScheduleService._internal();
  factory NotificationScheduleService() => _instance;
  NotificationScheduleService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    debugPrint('[NotificationDB] Initializing database...');
    String path = await getDatabasesPath();
    String dbPath = join(path, 'notification_schedules.db');

    debugPrint('[NotificationDB] Opening database at: $dbPath');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        debugPrint('[NotificationDB] Creating notification_schedules table...');
        await db.execute('''
          CREATE TABLE notification_schedules(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hour INTEGER NOT NULL,
            minute INTEGER NOT NULL,
            is_enabled INTEGER NOT NULL,
            last_updated TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<NotificationSchedule> saveSchedule(
    NotificationSchedule schedule,
  ) async {
    debugPrint('[NotificationDB] Saving notification schedule...');
    final db = await database;

    // Delete any existing schedules (we only want one active schedule)
    await db.delete('notification_schedules');

    // Insert the new schedule
    final id = await db.insert(
      'notification_schedules',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('[NotificationDB] Schedule saved with ID: $id');
    return NotificationSchedule(
      id: id,
      hour: schedule.hour,
      minute: schedule.minute,
      isEnabled: schedule.isEnabled,
      lastUpdated: schedule.lastUpdated,
    );
  }

  Future<NotificationSchedule?> getSchedule() async {
    debugPrint('[NotificationDB] Getting notification schedule...');
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'notification_schedules',
    );

    if (maps.isEmpty) {
      debugPrint('[NotificationDB] No schedule found');
      return null;
    }

    debugPrint('[NotificationDB] Schedule found: ${maps.first}');
    return NotificationSchedule.fromMap(maps.first);
  }

  Future<void> deleteSchedule(int id) async {
    debugPrint('[NotificationDB] Deleting schedule with ID: $id');
    final db = await database;
    await db.delete('notification_schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateScheduleStatus(int id, bool isEnabled) async {
    debugPrint(
      '[NotificationDB] Updating schedule status - ID: $id, Enabled: $isEnabled',
    );
    final db = await database;
    await db.update(
      'notification_schedules',
      {'is_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
