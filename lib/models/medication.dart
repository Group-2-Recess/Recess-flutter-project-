import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus {
  pending,
  completed,
  failed,
}

class Medication {
  String id;
  String sicknessName;
  String medicationName;
  String prescription;
  List<MedicationTime> alarms;
  bool isVerified;
  DateTime verificationDate;

  Medication({
    required this.id,
    required this.sicknessName,
    required this.medicationName,
    required this.prescription,
    required this.alarms,
    required this.isVerified,
    required this.verificationDate,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      sicknessName: json['sicknessName'],
      medicationName: json['medicationName'],
      prescription: json['prescription'],
      alarms: (json['alarms'] as List<dynamic>)
          .map((e) => MedicationTime.fromJson(e))
          .toList(),
      isVerified: json['isVerified'],
      verificationDate: DateTime.parse(json['verificationDate']),
    );
  }

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      sicknessName: json['sicknessName'],
      medicationName: json['medicationName'],
      prescription: json['prescription'],
      alarms: (json['alarms'] as List<dynamic>)
          .map((e) => MedicationTime.fromJson(e))
          .toList(),
      isVerified: json['isVerified'],
      verificationDate: DateTime.parse(json['verificationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sicknessName': sicknessName,
      'medicationName': medicationName,
      'prescription': prescription,
      'alarms': alarms.map((e) => e.toJson()).toList(),
      'isVerified': isVerified,
      'verificationDate': verificationDate.toIso8601String(),
    };
  }

  static VerificationStatus _parseVerificationStatus(String status) {
    switch (status) {
      case 'pending':
        return VerificationStatus.pending;
      case 'completed':
        return VerificationStatus.completed;
      case 'failed':
        return VerificationStatus.failed;
      default:
        throw ArgumentError('Invalid verification status: $status');
    }
  }

  static String _verificationStatusToString(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.completed:
        return 'completed';
      case VerificationStatus.failed:
        return 'failed';
    }
  }
}

class MedicationTime {
  int hour;
  int minute;

  MedicationTime({required this.hour, required this.minute});

  factory MedicationTime.fromJson(Map<String, dynamic> json) {
    return MedicationTime(
      hour: json['hour'],
      minute: json['minute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  String format(BuildContext context) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }
}
