import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical_reminder/models/verification.dart'; // Import Verification model

class VerificationPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final String patientId;
  final String patientName;
  final String medicationName;

  const VerificationPage({
    super.key,
    required this.userId,
    required this.caregiverId,
    required this.patientId,
    required this.patientName,
    required this.medicationName,
  });

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isVerified = false;

  Future<void> _verifyMedication(bool isVerified) async {
    final verificationStatement =
        '${widget.medicationName} for ${widget.patientName} has been ${isVerified ? 'verified' : 'has not been verified'} on ${DateTime.now().toLocal()}';

    final verification = Verification(
      medicationId: widget.patientId,
      patientId: widget.patientId,
      caregiverId: widget.caregiverId,
      verificationStatement: verificationStatement,
      timestamp: DateTime.now(),
      verified: isVerified,
    );

    // Save verification locally
    final prefs = await SharedPreferences.getInstance();
    final verificationJson = json.encode(verification.toJson());
    prefs.setString(
        'verification_${widget.patientId}_${verification.timestamp.toIso8601String()}',
        verificationJson);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Medication ${isVerified ? 'verified' : 'not verified'}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Medication'),
        backgroundColor: Colors.green, // Green color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Do you want to verify ${widget.medicationName} for ${widget.patientName}?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _verifyMedication(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(
                    255, 9, 143, 14), // Green color for the button
                padding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 24.0),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes, Verify'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _verifyMedication(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red color for the button
                padding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 24.0),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('No, Do Not Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
