import 'package:cloud_firestore/cloud_firestore.dart';
import 'medication.dart';
import 'verification_record.dart';

class Patient {
  String id;
  String userId; // Added userId
  String profileId; // Added profileId
  String caregiverId; // Added caregiverId
  String name;
  String location;
  String gender;
  String doctor;
  List<Medication> medications;
  List<VerificationRecord> verificationRecords;

  Patient({
    required this.id,
    required this.userId, // Added userId
    required this.profileId, // Added profileId
    required this.caregiverId, // Added caregiverId
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
      userId: data['userId'] ?? '',
      profileId: data['profileId'] ?? '',
      caregiverId: data['caregiverId'] ?? '', // Added caregiverId
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      gender: data['gender'] ?? '',
      doctor: data['doctor'] ?? '',
      medications: (data['medications'] as List<dynamic>?)
              ?.map((e) => Medication.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      verificationRecords: (data['verificationRecords'] as List<dynamic>?)
              ?.map(
                  (e) => VerificationRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // Added userId
      'profileId': profileId, // Added profileId
      'caregiverId': caregiverId, // Added caregiverId
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
      userId: '', // Added userId
      profileId: '', // Added profileId
      caregiverId: '', // Added caregiverId
      name: '',
      location: '',
      gender: '',
      doctor: '',
      medications: [],
      verificationRecords: [],
    );
  }

  // CopyWith method
  Patient copyWith({
    String? id,
    String? userId,
    String? profileId,
    String? caregiverId,
    String? name,
    String? location,
    String? gender,
    String? doctor,
    List<Medication>? medications,
    List<VerificationRecord>? verificationRecords,
  }) {
    return Patient(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      caregiverId: caregiverId ?? this.caregiverId,
      name: name ?? this.name,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      doctor: doctor ?? this.doctor,
      medications: medications ?? this.medications,
      verificationRecords: verificationRecords ?? this.verificationRecords,
    );
  }
}
