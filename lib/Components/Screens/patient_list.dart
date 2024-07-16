import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'edit_patient.dart';
import 'patient_summary_page.dart';
import 'patient_detail.dart';

class PatientListPage extends StatelessWidget {
  final FirestoreService _firebaseService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // Define onSave function to update patient
    void onSave(Patient updatedPatient) {
      _firebaseService.updatePatient(updatedPatient).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient updated successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update patient: $error')),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Patient>>(
        stream: _firebaseService.getPatients(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final patients = snapshot.data!;
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    patient.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Location: ${patient.location}'),
                      SizedBox(height: 4),
                      Text('Doctor: ${patient.doctor}'),
                    ],
                  ),
                  onTap: () {
                    // Navigate to patient summary page with patientId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientSummaryPage(
                          patientId: patient.id,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to edit patient page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPatientPage(
                                patient: patient,
                                onSave: onSave,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Implement delete functionality
                          _showDeleteConfirmationDialog(context, patient);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailPage(patient: Patient.empty()),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Patient'),
          content: Text('Are you sure you want to delete ${patient.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _firebaseService.deletePatient(patient.id).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Patient deleted successfully'),
                    ),
                  );
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete patient: $error'),
                    ),
                  );
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
