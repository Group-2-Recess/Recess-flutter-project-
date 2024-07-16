import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to generate a new unique ID
  String generateId() {
    return _firestore.collection('dummy').doc().id;
  }

  Future<void> savePatient(Patient patient) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patient.id)
          .set(patient.toJson());
      print("Patient saved");
    } catch (e) {
      throw Exception('Error saving patient: $e');
    }
  }

  Future<void> addMedicationWithAutoId(
      String patientId, Medication medication) async {
    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .add(medication.toJson())
        .then((value) => print("Medication added"))
        .catchError((error) => print("Failed to add medication: $error"));
  }

  Future<void> addMedicationWithCustomId(String patientId,
      String customMedicationId, Medication medication) async {
    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .doc(customMedicationId)
        .set(medication.toJson())
        .then((value) => print("Medication added"))
        .catchError((error) => print("Failed to add medication: $error"));
  }

  Future<void> updatePatient(Patient patient) async {
    await _firestore
        .collection('patients')
        .doc(patient.id)
        .update(patient.toJson())
        .then((value) => print("Patient updated"))
        .catchError((error) => print("Failed to update patient: $error"));
  }

  Future<void> deletePatient(String patientId) async {
    await _firestore
        .collection('patients')
        .doc(patientId)
        .delete()
        .then((value) => print("Patient deleted"))
        .catchError((error) => print("Failed to delete patient: $error"));
  }

  Stream<List<Patient>> getPatients() {
    return _firestore.collection('patients').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Patient.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  Future<void> addMedication(String patientId, Medication medication) async {
    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .add(medication.toJson())
        .then((value) => print("Medication added"))
        .catchError((error) => print("Failed to add medication: $error"));
  }

  Future<void> updateMedication(String patientId, Medication medication) async {
    final patientDoc = _firestore.collection('patients').doc(patientId);
    final patientSnapshot = await patientDoc.get();

    if (patientSnapshot.exists) {
      final medications = patientSnapshot.data()?['medications'] ?? [];

      // Find the index of the medication to update
      final index = medications.indexWhere((med) => med['id'] == medication.id);

      if (index != -1) {
        medications[index] = medication.toJson();
        await patientDoc
            .update({'medications': medications})
            .then((value) => print("Medication updated"))
            .catchError(
                (error) => print("Failed to update medication: $error"));
      } else {
        throw Exception('Medication not found');
      }
    } else {
      throw Exception('Patient not found');
    }
  }

  Future<void> saveVerificationRecord(
      String patientId, Map<String, String> data) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('verificationRecords')
          .add(data)
          .then((value) => print("Verification record saved"))
          .catchError(
              (error) => print("Failed to save verification record: $error"));
    } catch (e) {
      print('Error saving verification record: $e');
      throw Exception('Failed to save verification record');
    }
  }

  Future<List<Medication>> fetchMedicationsForPatient(String patientId) async {
    List<Medication> medications = [];

    try {
      var medicationsSnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .get();

      medicationsSnapshot.docs.forEach((medDoc) {
        var medication = Medication.fromJson(medDoc.data());
        medications.add(medication);
      });

      return medications;
    } catch (e) {
      print('Error fetching medications: $e');
      throw e; // Ensure to throw the error to handle in calling code
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Patient> getPatient(String patientId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('patients').doc(patientId).get();

      if (doc.exists) {
        return Patient.fromDocumentSnapshot(doc);
      } else {
        return Future.error('Patient not found');
      }
    } catch (e) {
      print('Error fetching patient: $e');
      throw Exception('Failed to fetch patient');
    }
  }

  Future<List<Medication>> getMedications(String patientId) async {
    try {
      QuerySnapshot medsSnapshot = await _db
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .get();

      return medsSnapshot.docs
          .map((doc) => Medication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching medications: $e');
      throw Exception('Failed to fetch medications');
    }
  }

  Future<void> saveMedicationVerification(
      String patientId, Map<String, String> verificationData) async {
    try {
      await _db
          .collection('patients')
          .doc(patientId)
          .collection('verifications')
          .add(verificationData);
    } catch (e) {
      throw Exception('Error saving verification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPatientRecords(String patientId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('patients')
          .doc(patientId)
          .collection('verifications')
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching records: $e');
    }
  }
}
