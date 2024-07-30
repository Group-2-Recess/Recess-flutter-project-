import 'package:cloud_firestore/cloud_firestore.dart';
import 'medication.dart';

class Patient {
  String id;
  final String name;
  final String address;
  final String? gender;
  final String doctor;
  final List<Medication> medications;

  Patient({
    required this.id,
    required this.name,
    required this.address,
    this.gender,
    required this.doctor,
    this.medications = const [],
  });

  factory Patient.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Patient(
      id: snapshot.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'] ?? '',
      doctor: data['doctor'] ?? '',
      medications: _convertMedications(data['medications'] ?? []),
    );
  }

  static List<Medication> _convertMedications(List<dynamic> data) {
    return data
        .map((medicationData) => Medication.fromJson(medicationData))
        .toList();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'gender': gender,
      'doctor': doctor,
      'medications':
          medications.map((medication) => medication.toJson()).toList(),
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    String? address,
    String? gender,
    String? doctor,
    List<Medication>? medications,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      doctor: doctor ?? this.doctor,
      medications: medications ?? this.medications,
    );
  }
}
