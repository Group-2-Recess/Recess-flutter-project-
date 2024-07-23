import 'package:flutter/material.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:intl/intl.dart';

class MedicationVerificationPage extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String patientGender;
  final String medicationId; // Ensure this is defined
  final String medicationName;
  final TimeOfDay time;
  final bool taken;

  MedicationVerificationPage({
    required this.patientId,
    required this.patientName,
    required this.patientGender,
    required this.medicationId, // Add this parameter
    required this.medicationName,
    required this.time,
    required this.taken,
  });

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Verification'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Verification for $patientName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '$medicationName at ${_formatTimeOfDay(time)} on ${_formatDate(DateTime.now())} was ${taken ? 'taken' : 'not taken'}.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _saveVerification(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dateTime);
  }

  Future<void> _saveVerification(BuildContext context) async {
    try {
      String formattedTime = _formatTimeOfDay(time);
      String formattedDate = _formatDate(DateTime.now());

      // Constructing the verification record data as Map<String, String>
      Map<String, String> verificationData = {
        'patientName': patientName,
        'gender': patientGender,
        'medicationName': medicationName,
        'time': formattedTime,
        'date': DateTime.now().toIso8601String(), // Save date in ISO format
        'taken': taken.toString(),
      };

      // Example of the updated method call
      await _firestoreService.saveMedicationVerification(
        patientId, // Pass the patient ID
        medicationId, // Pass the medication ID
        verificationData, // Pass the verification data as a Map<String, dynamic>
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      print('Error saving verification: $e');
      Navigator.pop(context, false); // Return false to indicate failure
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
