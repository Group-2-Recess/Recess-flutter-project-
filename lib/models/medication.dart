import 'package:cloud_firestore/cloud_firestore.dart';
import 'alarm_model.dart'; // Ensure to import your Alarm model
import 'reminder.dart'; // Ensure to import your Reminder model

class Medication {
  String id;
  final String name;
  final String diagnosis;
  final String prescription;
  final String dosage;
  final String frequency;
  final String instructions;
  final List<Alarm> alarms;
  final List<Reminder> reminders; // Changed to List<Reminder>
  final bool verificationStatus;
  final DateTime verificationDate;

  Medication({
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.prescription,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.alarms,
    required this.reminders,
    required this.verificationStatus,
    required this.verificationDate,
  });

  // Factory constructor to create a Medication instance from a JSON object
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      diagnosis: json['diagnosis'] as String,
      prescription: json['prescription'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      instructions: json['instructions'] as String,
      alarms: (json['alarms'] as List<dynamic>?)
              ?.map((alarm) => Alarm.fromMap(alarm as Map<String, dynamic>))
              .toList() ??
          [], // Handle null case
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((reminder) =>
                  Reminder.fromJson(reminder as Map<String, dynamic>))
              .toList() ??
          [], // Handle null case
      verificationStatus: json['verificationStatus'] as bool? ?? false,
      verificationDate:
          (json['verificationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert a Medication instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'alarms': alarms.map((alarm) => alarm.toMap()).toList(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'verificationStatus': verificationStatus,
      'verificationDate': verificationDate,
    };
  }

  // Create a copy of this Medication instance with optional new values
  Medication copyWith({
    String? id,
    String? name,
    String? diagnosis,
    String? prescription,
    String? dosage,
    String? frequency,
    String? instructions,
    List<Alarm>? alarms,
    List<Reminder>? reminders, // Updated to List<Reminder>
    bool? verificationStatus,
    DateTime? verificationDate,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      alarms: alarms ?? this.alarms,
      reminders: reminders ?? this.reminders, // Updated to reminders
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDate: verificationDate ?? this.verificationDate,
    );
  }
}
