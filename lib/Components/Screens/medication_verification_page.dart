import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_reminder/database_helper.dart';

class MedicationVerificationPage extends StatelessWidget {
  final String patientName;
  final String patientGender;
  final String medicationName;
  final TimeOfDay time;
  final bool taken;

  MedicationVerificationPage({
    required this.patientName,
    required this.patientGender,
    required this.medicationName,
    required this.time,
    required this.taken,
  });

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

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  Future<void> _saveVerification(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    try {
      await dbHelper.insertRecord({
        'patientName': patientName,
        'gender': patientGender,
        'medicationName': medicationName,
        'time': _formatTimeOfDay(time),
        'date': _formatDate(DateTime.now()),
        'taken': taken ? 1 : 0,
      });

      // If the insert is successful, print a message
      print('Verification record saved successfully');

      Navigator.pop(context); // Close the verification page after saving
    } catch (e) {
      print('Error inserting record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save verification. Please try again.'),
        ),
      );
    }
  }
}
