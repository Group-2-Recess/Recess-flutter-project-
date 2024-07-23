import 'package:cloud_firestore/cloud_firestore.dart';
import 'medication.dart';
import 'verification_record.dart';

class Patient {
  String id;
  String name;
  String location;
  String gender;
  String doctor;
  List<Medication> medications;
  List<VerificationRecord> verificationRecords;

  Patient({
    required this.id,
    required this.name,
    required this.location,
    required this.gender,
    required this.doctor,
    required this.medications,
    required this.verificationRecords,
  });

  factory Patient.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      gender: data['gender'] ?? '',
      doctor: data['doctor'] ?? '',
      medications: (data['medications'] as List<dynamic>)
          .map((e) => Medication.fromJson(e))
          .toList(),
      verificationRecords: (data['verificationRecords'] as List<dynamic>)
          .map((e) => VerificationRecord.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'gender': gender,
      'doctor': doctor,
      'medications': medications.map((e) => e.toJson()).toList(),
      'verificationRecords':
          verificationRecords.map((e) => e.toJson()).toList(),
    };
  }

  static Patient empty() {
    return Patient(
      id: '',
      name: '',
      location: '',
      gender: '',
      doctor: '',
      medications: [],
      verificationRecords: [],
    );
  }
}
