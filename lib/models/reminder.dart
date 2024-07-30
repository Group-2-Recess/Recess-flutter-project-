import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String time;
  final List<bool> days;
  final bool enabled;
  final String sound;
  final bool vibration;
  final int snoozeDuration;
  final String medicationName;

  Reminder({
    required this.id,
    required this.time,
    required this.days,
    this.enabled = true,
    this.sound = '',
    this.vibration = true,
    this.snoozeDuration = 5 * 60,
    required this.medicationName,
  });

  // Convert Reminder object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'days': days,
      'enabled': enabled,
      'sound': sound,
      'vibration': vibration,
      'snoozeDuration': snoozeDuration,
      'medicationName': medicationName,
    };
  }

  // Create Reminder object from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      time: json['time'],
      days: List<bool>.from(json['days']),
      enabled: json['enabled'],
      sound: json['sound'],
      vibration: json['vibration'],
      snoozeDuration: json['snoozeDuration'],
      medicationName: json['medicationName'],
    );
  }

  // Create Reminder object from Firestore document
  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reminder.fromJson(data);
  }
}
