// patient.dart
import 'medication.dart';
import 'verification_record.dart';

class Patient {
  final int? id;
  final String name;
  final String location;
  final String gender;
  final String doctor;
  final List<Medication> medications;
  List<VerificationRecord> verificationRecords;

  Patient({
    this.id,
    required this.name,
    required this.location,
    required this.gender,
    required this.doctor,
    required this.medications,
    List<VerificationRecord>? verificationRecords,
  }) : verificationRecords = verificationRecords ?? [];
}
