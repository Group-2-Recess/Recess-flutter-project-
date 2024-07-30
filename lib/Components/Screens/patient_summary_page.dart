import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'verification.dart'; // Import Verification model
import 'record_page.dart'; // Import RecordPage

class PatientSummaryPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final Patient patient;

  const PatientSummaryPage({
    super.key,
    required this.userId,
    required this.caregiverId,
    required this.patient,
  });

  @override
  _PatientSummaryPageState createState() => _PatientSummaryPageState();
}

class _PatientSummaryPageState extends State<PatientSummaryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Patient? patientDetails;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
      final patient = await _firestoreService.getPatientDetails(
        widget.caregiverId,
        widget.patient.id,
      );
      setState(() {
        patientDetails = patient;
      });
    } catch (e) {
      // Handle error
      print('Error fetching patient details: $e');
    }
  }

  Future<void> _showMedicationDialog(
      BuildContext context, Medication medication) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismiss by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Medication Verification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to verify ${medication.name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Verify'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerificationPage(
                      userId: widget.userId,
                      caregiverId: widget.caregiverId,
                      patientId: widget.patient.id,
                      patientName: widget.patient.name,
                      medicationName: medication.name, // Pass medication name
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Summary'),
        backgroundColor: Colors.green, // Green color for the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            onPressed: () {
              if (patientDetails != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordPage(
                      patientId: patientDetails!.id, // Pass the patientId
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No patient details available')),
                );
              }
            },
          ),
        ],
      ),
      body: patientDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Information',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Name: ${patientDetails!.name}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Address: ${patientDetails!.address}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Gender: ${patientDetails!.gender ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Doctor: ${patientDetails!.doctor}',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Medications:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  ...patientDetails!.medications
                      .map((medication) => Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      medication.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Dosage: ${medication.dosage}\n'
                                      'Frequency: ${medication.frequency}\n'
                                      'Diagnosis: ${medication.diagnosis}\n'
                                      'Prescription: ${medication.prescription}\n'
                                      'Instructions: ${medication.instructions}\n'
                                      'Verification Status: ${medication.verificationStatus ? 'Verified' : 'Not Verified'}\n'
                                      'Verification Date: ${medication.verificationDate != null ? DateFormat('yyyy-MM-dd').format(medication.verificationDate!) : 'N/A'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green, // Green background
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      _showMedicationDialog(
                                          context, medication);
                                    },
                                    child: Text('Verify ${medication.name}'),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
