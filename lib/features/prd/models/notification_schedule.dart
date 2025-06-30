class NotificationSchedule {
  final int? id;
  final int hour;
  final int minute;
  final bool isEnabled;
  final DateTime lastUpdated;

  NotificationSchedule({
    this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Convert a NotificationSchedule into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'is_enabled': isEnabled ? 1 : 0,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Create a NotificationSchedule from a Map
  factory NotificationSchedule.fromMap(Map<String, dynamic> map) {
    return NotificationSchedule(
      id: map['id'],
      hour: map['hour'],
      minute: map['minute'],
      isEnabled: map['is_enabled'] == 1,
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
