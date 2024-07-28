import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus {
  pending,
  completed,
  failed,
}

class Medication {
  String id;
  final String caregiverId; // Used instead of profileId
  String userId;
  String patientId; // New field added
  String sicknessName;
  String medicationName;
  String prescription;
  List<MedicationTime> alarms;
  bool isVerified;
  DateTime verificationDate;

  Medication({
    required this.id,
    required this.userId,
    required this.caregiverId, // Used instead of profileId
    required this.patientId, // New field added
    required this.sicknessName,
    required this.medicationName,
    required this.prescription,
    required this.alarms,
    required this.isVerified,
    required this.verificationDate,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      caregiverId: json['caregiverId'] ?? '', // Used instead of profileId
      patientId: json['patientId'] ?? '', // New field added
      sicknessName: json['sicknessName'] ?? '',
      medicationName: json['medicationName'] ?? '',
      prescription: json['prescription'] ?? '',
      alarms: (json['alarms'] as List<dynamic>?)
              ?.map((e) => MedicationTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isVerified: json['isVerified'] ?? false,
      verificationDate: json['verificationDate'] != null
          ? DateTime.parse(json['verificationDate'])
          : DateTime.now(), // Default to now if date is null
    );
  }

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
    return Medication(
      id: doc.id,
      userId: data['userId'] ?? '',
      caregiverId: data['caregiverId'] ?? '', // Used instead of profileId
      patientId: data['patientId'] ?? '', // New field added
      sicknessName: data['sicknessName'] ?? '',
      medicationName: data['medicationName'] ?? '',
      prescription: data['prescription'] ?? '',
      alarms: (data['alarms'] as List<dynamic>?)
              ?.map((e) => MedicationTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isVerified: data['isVerified'] ?? false,
      verificationDate: data['verificationDate'] != null
          ? DateTime.parse(data['verificationDate'])
          : DateTime.now(), // Default to now if date is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'caregiverId': caregiverId, // Used instead of profileId
      'patientId': patientId, // New field added
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
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
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
