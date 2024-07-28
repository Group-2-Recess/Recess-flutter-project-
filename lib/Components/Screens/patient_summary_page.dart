import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/Components/Screens/medication_detail.dart';

class PatientSummaryPage extends StatelessWidget {
  final String userId;
  final String caregiverId;
  final Patient patient;

  PatientSummaryPage({
    required this.userId,
    required this.caregiverId,
    required this.patient,
  });

  Future<void> _updatePatient(BuildContext context) async {
    try {
      await FirestoreService().updatePatient(
        userId,
        caregiverId,
        patient, // Use patient directly if updating details
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Patient updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update patient: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Summary'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _updatePatient(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Patient Summary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            Text('Name: ${patient.name}'),
            Text('Location: ${patient.location}'),
            Text('Gender: ${patient.gender}'),
            Text('Doctor: ${patient.doctor}'),
            SizedBox(height: 20),
            Text(
              'Medications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: patient.medications.length,
              itemBuilder: (context, index) {
                final medication = patient.medications[index];
                return ListTile(
                  title: Text(medication.medicationName),
                  subtitle: Text('Dose: ${medication.prescription}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicationDetailPage(
                            patientId: patient.id, // Use patient.id here
                            userId: userId,
                            caregiverId: caregiverId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
