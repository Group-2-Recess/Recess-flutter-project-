class Alarm {
  final String time; // e.g., "09:00 AM"
  final List<bool>
      days; // e.g., [true, false, true, false, false, false, false]

  Alarm({
    required this.time,
    required this.days,
  });

  factory Alarm.fromMap(Map<String, dynamic> data) {
    return Alarm(
      time: data['time'] ?? '',
      days: List<bool>.from(data['days'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'days': days,
    };
  }
}
