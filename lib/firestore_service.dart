import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to generate a new unique ID
  String generateId() {
    return _firestore.collection('dummy').doc().id;
  }

  // Patient Methods
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

  Future<void> updatePatient(Patient patient) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patient.id)
          .update(patient.toJson());
      print("Patient updated");
    } catch (e) {
      throw Exception('Error updating patient: $e');
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      await _firestore.collection('patients').doc(patientId).delete();
      print("Patient deleted");
    } catch (e) {
      throw Exception('Error deleting patient: $e');
    }
  }

  Future<Patient> getPatient(String patientId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('patients').doc(patientId).get();
      if (doc.exists) {
        return Patient.fromDocumentSnapshot(doc);
      } else {
        throw Exception('Patient not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch patient: $e');
    }
  }

  Stream<List<Patient>> getPatients() {
    return _firestore.collection('patients').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Patient.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  // Medication Methods
  Future<void> addMedicationWithAutoId(
      String patientId, Medication medication) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .add(medication.toJson());
      print("Medication added with auto ID");
    } catch (e) {
      throw Exception('Error adding medication: $e');
    }
  }

  Future<void> addMedicationWithCustomId(String patientId,
      String customMedicationId, Medication medication) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(customMedicationId)
          .set(medication.toJson());
      print("Medication added with custom ID");
    } catch (e) {
      throw Exception('Error adding medication: $e');
    }
  }

  Future<void> updateMedication(
      String patientId, String medicationId, Medication medication) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .update(medication.toJson());
      print("Medication updated");
    } catch (e) {
      throw Exception('Error updating medication: $e');
    }
  }

  Future<void> deleteMedication(String patientId, String medicationId) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .delete();
      print("Medication deleted");
    } catch (e) {
      throw Exception('Error deleting medication: $e');
    }
  }

  Future<List<Medication>> fetchMedicationsForPatient(String patientId) async {
    try {
      var medicationsSnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .get();

      return medicationsSnapshot.docs
          .map((medDoc) => Medication.fromJson(medDoc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching medications: $e');
    }
  }

  // Add the new methods
  Future<void> updateMedicationReminders(String patientId, String medicationId,
      Map<String, dynamic> reminderData) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .update(reminderData);
      print("Medication reminders updated");
    } catch (e) {
      throw Exception('Error updating medication reminders: $e');
    }
  }

  Future<List<Medication>> getMedications(String patientId) async {
    try {
      var medicationsSnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .get();

      return medicationsSnapshot.docs
          .map((medDoc) => Medication.fromJson(medDoc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching medications: $e');
    }
  }

  Future<void> saveMedicationVerification(String patientId, String medicationId,
      Map<String, dynamic> verificationData) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .collection('verifications')
          .add(verificationData);
      print("Medication verification saved");
    } catch (e) {
      throw Exception('Error saving medication verification: $e');
    }
  }

  // Prescription Methods
  Future<void> savePrescription(
      String patientId, Map<String, dynamic> prescriptionData) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('prescriptions')
          .add(prescriptionData);
      print("Prescription saved");
    } catch (e) {
      throw Exception('Error saving prescription: $e');
    }
  }

  Future<void> updatePrescription(String patientId, String prescriptionId,
      Map<String, dynamic> prescriptionData) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('prescriptions')
          .doc(prescriptionId)
          .update(prescriptionData);
      print("Prescription updated");
    } catch (e) {
      throw Exception('Error updating prescription: $e');
    }
  }

  Future<void> deletePrescription(
      String patientId, String prescriptionId) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('prescriptions')
          .doc(prescriptionId)
          .delete();
      print("Prescription deleted");
    } catch (e) {
      throw Exception('Error deleting prescription: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPrescriptions(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('prescriptions')
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching prescriptions: $e');
    }
  }

  // Verification Methods
  Future<void> saveVerificationRecord(
      String patientId, Map<String, String> data) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('verificationRecords')
          .add(data);
      print("Verification record saved");
    } catch (e) {
      throw Exception('Error saving verification record: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPatientRecords(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('verificationRecords')
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Error fetching records: $e');
    }
  }
}
