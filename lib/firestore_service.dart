import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medical_reminder/models/profilemodel.dart';
import 'package:medical_reminder/caregiver.dart';
import 'package:medical_reminder/models/verification_record.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> savePatientProfile(PatientProfile profile) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('patient_profiles')
            .doc(profile.id)
            .set(profile.toMap());
        print('Patient profile saved successfully.');
      } catch (e) {
        print('Failed to save patient profile: $e');
      }
    } else {
      print('No user is signed in.');
    }
  }

  Future<void> updateMedicationReminders(String patientId, String medicationId,
      List<MedicationTime> alarms) async {
    try {
      await _db
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .update({
        'alarms': alarms
            .map((alarm) => {
                  'hour': alarm.hour,
                  'minute': alarm.minute,
                })
            .toList(),
      });
    } catch (e) {
      print('Error updating medication reminders: $e');
    }
  }

  Future<void> saveCaregiverProfile(
      String userId, Map<String, dynamic> caregiverData) async {
    try {
      // Save the caregiver profile to Firestore
      await _db
          .collection('users')
          .doc(userId)
          .collection('caregiver_profiles')
          .add(caregiverData);
    } catch (e) {
      throw Exception('Failed to save caregiver profile: $e');
    }
  }

  // Get all caregiver profiles for a specific user
  Future<List<Map<String, dynamic>>> getCaregiverProfiles(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('caregiver_profiles')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error fetching caregiver profiles: $e');
    }
  }

  // Get a specific caregiver profile by ID
  Future<Map<String, dynamic>> getCaregiverProfileById(
      String userId, String profileId) async {
    try {
      final docSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('caregiver_profiles')
          .doc(profileId)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot.data()!;
      } else {
        throw Exception('Caregiver profile not found');
      }
    } catch (e) {
      throw Exception('Error fetching caregiver profile: $e');
    }
  }

  Future<void> registerCaregiver(String email, String password) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Optional: You can save additional info in Firestore here
    } catch (e) {
      // Handle registration errors
      print('Registration error: $e');
    }
  }

  // Update a caregiver profile
  Future<void> updateCaregiverProfile(
      String userId, String profileId, Map<String, dynamic> updatedData) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('caregiver_profiles')
          .doc(profileId)
          .update(updatedData);
    } catch (e) {
      throw Exception('Error updating caregiver profile: $e');
    }
  }

  // Delete a caregiver profile
  Future<void> deleteCaregiverProfile(String userId, String profileId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('caregiver_profiles')
          .doc(profileId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting caregiver profile: $e');
    }
  }

  Future<void> savePatient(
      Patient patient, String userId, String profileId) async {
    if (userId.isEmpty || profileId.isEmpty) {
      throw Exception('User ID or Profile ID is empty');
    }
    await _db
        .collection('users')
        .doc(userId)
        .collection('caregiver_profiles')
        .doc(profileId)
        .collection('patients')
        .doc(patient.id)
        .set(patient.toJson());
  }

  // Method to delete a patient by ID under a caregiver profile

  // Method to fetch patients for a specific caregiver profile

  // Example method to get patients

  // Delete patient

  // Fetch medications for a specific patient

  // Delete medication

  // Generate unique ID (e.g., using Firestore auto-id)
  String generateId() {
    return _db.collection('patients').doc().id;
  }

  // Delete patient

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

  // Add the new methods

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

  // Get a Patient by ID

  // Save a Medication for a specific Patient

  // Get Medications for a specific Patient

  // Save a VerificationRecord for a specific Medication of a specific Patient
  Future<void> verifyMedication(
      String patientId, String recordId, bool taken) async {
    try {
      await _db
          .collection('patients')
          .doc(patientId)
          .collection('records')
          .doc(recordId)
          .update({'taken': taken, 'verificationDate': Timestamp.now()});
    } catch (e) {
      throw Exception('Error verifying medication: $e');
    }
  }

  Future<List<VerificationRecord>> getVerificationRecords(
      String patientId, String medicationId) async {
    QuerySnapshot snapshot = await _db
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .doc(medicationId)
        .collection('verification_records')
        .get();

    return snapshot.docs
        .map((doc) => VerificationRecord.fromJson(doc as Map<String, dynamic>))
        .toList();
  }

  Future<Patient> getPatientById(String patientId) async {
    final doc = await _db.collection('patients').doc(patientId).get();
    return Patient.fromDocumentSnapshot(doc);
  }

  Future<void> updateMedicationVerification(
      String patientId, String medicationId, bool verificationStatus) async {
    final ref = _db
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .doc(medicationId);

    return ref.update({'verificationStatus': verificationStatus});
  }

  //

  Future<String?> getCaregiverId(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Assuming caregiverId is a field in the user's document
      return userDoc['caregiverId'] as String?;
    } catch (e) {
      print('Failed to retrieve caregiverId: $e');
      return null;
    }
  }

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<String> getProfileId(String userId) async {
    final caregiverCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('caregiver_profiles');
    final QuerySnapshot querySnapshot = await caregiverCollection.get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot
          .docs.first.id; // Assuming you need the first caregiver ID
    } else {
      throw Exception('Caregiver profile not found');
    }
  }

  Future<void> addPatient(
    String userId,
    String caregiverId,
    Map<String, dynamic> patientData,
  ) async {
    final patientsCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('caregiver_profiles')
        .doc(caregiverId)
        .collection('patients');

    await patientsCollection.add(patientData);
  }

  Future<List<Patient>> getPatients(
    String userId,
    String caregiverId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('caregiver_profiles')
          .doc(caregiverId)
          .collection('patients')
          .get();

      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if no documents are found
      }

      return snapshot.docs
          .map((doc) => Patient.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error in getPatients: $e');
      throw e;
    }
  }

  Future<void> deletePatient(
    String userId,
    String caregiverId,
    String patientId,
  ) async {
    final patientDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('caregiver_profiles')
        .doc(caregiverId)
        .collection('patients')
        .doc(patientId);

    await patientDoc.delete();
  }

  Future<List<Medication>> fetchMedicationsForPatient(
    String userId,
    String caregiverId,
    String patientId,
  ) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('caregiver_profiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .get();

      if (snapshot.docs.isEmpty) {
        return []; // Return an empty list if no documents are found
      }

      return snapshot.docs
          .map((doc) =>
              Medication.fromFirestore(doc)) // Pass DocumentSnapshot directly
          .toList();
    } catch (e) {
      print('Error in fetchMedicationsForPatient: $e');
      throw Exception('Failed to fetch medications: $e');
    }
  }

  Future<void> addMedication(
    String userId,
    String caregiverId,
    String patientId,
    Medication medication,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('caregiver_profiles')
        .doc(caregiverId)
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .doc(medication.id)
        .set(medication.toJson());
  }

// Update an existing medication
  Future<void> updateMedication(
    String userId,
    String caregiverId,
    String patientId,
    Medication medication,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('caregiver_profiles')
        .doc(caregiverId)
        .collection('patients')
        .doc(patientId)
        .collection('medications')
        .doc(medication.id)
        .update(medication.toJson());
  }

  // Delete a medication
  Future<void> deleteMedication(
      String patientId, String caregiverId, String medicationId) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .delete();
    } catch (e) {
      print('Error in deleteMedication: $e');
      throw e;
    }
  }

  Future<void> saveMedication(
      String patientId, String caregiverId, Medication medication) async {
    try {
      await _db
          .collection('users')
          .doc(caregiverId) // Reference to the caregiver document
          .collection('caregiverProfiles')
          .doc(caregiverId) // Reference to the caregiver profile document
          .collection('patients')
          .doc(patientId) // Reference to the patient document
          .collection('medications')
          .doc(medication.id) // Reference to the medication document
          .set(medication.toJson()); // Save the medication details
    } catch (e) {
      throw Exception('Failed to save medication: $e');
    }
  }

  Future<void> updatePatient(
      String userId, String caregiverProfileId, Patient patient) async {
    // Check for non-empty paths
    if (userId.isEmpty || caregiverProfileId.isEmpty || patient.id.isEmpty) {
      throw ArgumentError(
          'User ID, caregiver profile ID, and patient ID must not be empty');
    }

    try {
      await _db.collection('patients').doc(patient.id).update({
        'name': patient.name,
        'location': patient.location,
        'gender': patient.gender,
        // Add other fields here
      });
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  Future<void> addReminder(String userId, String caregiverId, String patientId,
      Map<String, dynamic> reminderData) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('caregivers')
        .doc(caregiverId)
        .collection('patients')
        .doc(patientId)
        .collection('reminders')
        .add(reminderData);
  }

  Future<void> saveVerificationRecord(
      String userId, String patientId, VerificationRecord record) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('patients')
        .doc(patientId)
        .collection('verificationRecords')
        .add(record.toJson());
  }
}
// Generate a new ID for medication

// Other existing methods

// Method to add or update a patient under a caregiver profile
