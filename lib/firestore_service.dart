import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medical_reminder/models/profilemodel.dart';
import 'package:medical_reminder/caregiver.dart';
import 'package:medical_reminder/models/verification.dart';
import 'package:medical_reminder/models/reminder.dart';

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

  // Add the new methods

  // Prescription Methods

  // Verification Methods

  // Get a Patient by ID

  // Save a Medication for a specific Patient

  // Get Medications for a specific Patient

  // Save a VerificationRecord for a specific Medication of a specific Patient

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

  Future<void> addPatient(String caregiverId, Patient patient) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .add(patient.toFirestore());
      patient.id = docRef.id; // Assign generated ID to patient object
    } catch (e) {
      // Handle error
      print('Error adding patient: $e');
      rethrow; // Rethrow to propagate the error
    }
  }

  Future<void> updatePatient(
      String caregiverId, String patientId, Patient patient) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .update(patient.toFirestore());
    } catch (e) {
      // Handle error
      print('Error updating patient: $e');
      rethrow;
    }
  }

  Future<List<Medication>> getMedications(
      String caregiverId, String patientId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      final medicationsSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .get();

      final medicationList = medicationsSnapshot.docs
          .map((doc) => Medication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return medicationList;
    } catch (e) {
      print('Error fetching medications: $e');
      return [];
    }
  }

  Future<List<Verification>> getVerifications(
      String caregiverId, String patientId, String medicationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .collection('verifications')
          .get();

      return querySnapshot.docs
          .map((doc) => Verification.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Handle error
      print('Error getting verifications: $e');
      rethrow;
    }
  }

  Future<void> addReminder(String userId, String caregiverId, String patientId,
      Map<String, dynamic> reminderData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection(
              'reminders') // You can change the collection name if needed
          .add(reminderData);
    } catch (e) {
      print('Error adding reminder: $e');
      rethrow;
    }
  }

  Future<void> saveVerification(
    String caregiverId,
    String patientId,
    String medicationId,
    Verification verification,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    // Print statements for debugging
    print('Caregiver ID: $caregiverId');
    print('Patient ID: $patientId');
    print('Medication ID: $medicationId');

    try {
      // Add a new document with an auto-generated ID
      final verificationRef = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .collection('verifications')
          .add(verification.toJson());

      print('Verification saved with ID: ${verificationRef.id}');
    } catch (e) {
      print('Error saving verification: $e');
      rethrow;
    }
  }

  // Fetch patient data by caregiverId and patientId

  Future<Patient?> getPatientById(String patientId) async {
    try {
      final docSnapshot = await _db.collection('patients').doc(patientId).get();

      if (docSnapshot.exists) {
        return Patient.fromFirestore(docSnapshot);
      } else {
        print('Patient not found');
        return null;
      }
    } catch (e) {
      print('Error fetching patient: $e');
      rethrow;
    }
  }

  Future<List<Patient>> getPatients(String caregiverId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      // Fetch the patients from the specific caregiver's collection
      final patientsSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .get();

      // Convert the fetched documents into a list of Patient objects
      final patientList = patientsSnapshot.docs
          .map((doc) => Patient.fromFirestore(doc))
          .toList();

      return patientList;
    } catch (e) {
      print('Error fetching patients: $e');
      return [];
    }
  }

  // Get Patient details (bio data) by Patient ID

  Future<Patient> getPatientDetails(
      String caregiverId, String patientId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      final patientSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .get();

      if (!patientSnapshot.exists) {
        throw Exception('Patient not found');
      }

      final patientData = patientSnapshot.data()!;
      final medications = await getMedications(caregiverId, patientId);

      return Patient(
        id: patientSnapshot.id,
        name: patientData['name'] ?? '',
        address: patientData['address'] ?? '',
        gender: patientData['gender'] ?? '',
        doctor: patientData['doctor'] ?? '',
        medications: medications,
      );
    } catch (e) {
      print('Error fetching patient details: $e');
      rethrow;
    }
  }

  Future<String> addMedication(
      String caregiverId, String patientId, Medication medication) async {
    try {
      final medicationMap = medication.toJson();
      medicationMap['reminders'] =
          medication.reminders.map((reminder) => reminder.toJson()).toList();

      print('Medication Map: $medicationMap'); // Debugging line

      final docRef = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .add(medicationMap);

      print('Medication added successfully with ID: ${docRef.id}');
      return docRef.id; // Return the newly created document ID
    } catch (e) {
      print('Error adding medication: $e');
      throw e; // Rethrow the error for further handling if necessary
    }
  }

  Future<List<Reminder>> getReminders(
      String caregiverId, String patientId, String medicationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      // Debug logs
      print(
          'Fetching reminders for caregiverId: $caregiverId, patientId: $patientId, medicationId: $medicationId');

      if (caregiverId.isEmpty || patientId.isEmpty || medicationId.isEmpty) {
        throw Exception('Caregiver ID, Patient ID, or Medication ID is empty');
      }

      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .collection('reminders')
          .get();

      return remindersSnapshot.docs
          .map((doc) => Reminder.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
    }
  }

  Future<Patient?> getPatient(String caregiverId, String patientId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .get();

      if (docSnapshot.exists) {
        return Patient.fromFirestore(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching patient: $e');
      return null;
    }
  }

  Future<void> updateMedication(
      String caregiverId, String patientId, Medication medication) async {
    try {
      // Convert reminders to maps before saving
      final medicationMap = medication.toJson();
      medicationMap['reminders'] =
          medication.reminders.map((reminder) => reminder.toJson()).toList();

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medication.id)
          .set(
              medicationMap,
              SetOptions(
                  merge:
                      true)); // Use merge to avoid overwriting existing fields

      print('Medication updated successfully.');
    } catch (e) {
      print('Error updating medication: $e');
      throw e; // Rethrow the error for further handling if necessary
    }
  }

  Future<void> addVerification(
    String caregiverId,
    String patientId,
    String medicationId,
    Verification verification,
  ) async {
    try {
      final verificationMap = verification.toJson();

      // Add the verification record to the Firestore collection
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .doc(medicationId)
          .collection('verifications')
          .add(verificationMap);

      print('Verification added successfully.');
    } catch (e) {
      print('Error adding verification: $e');
      throw e; // Re-throw the exception for further handling
    }
  }

  Future<void> saveMedication(
      String caregiverId, String patientId, Medication medication) async {
    try {
      // Show loading indicator in UI
      final docRef = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .collection('medications')
          .add(medication.toJson());

      // Handle successful save, e.g., show success message
      print('Medication added successfully with ID: ${docRef.id}');
    } catch (e) {
      // Handle error, e.g., show error message
      print('Error adding medication: $e');
    } finally {
      // Hide loading indicator
    }
  }

  Future<void> deletePatient(String caregiverId, String patientId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('caregiverProfiles')
          .doc(caregiverId)
          .collection('patients')
          .doc(patientId)
          .delete();
    } catch (e) {
      // Handle error
      print('Error deleting patient: $e');
      rethrow;
    }
  }
}



  
   



// Generate a new ID for medication

// Other existing methods

// Method to add or update a patient under a caregiver profile
