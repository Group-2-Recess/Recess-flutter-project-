import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'patient_detail.dart';
import 'patient_summary.dart';
import 'edit_patient.dart';
import 'side_navigation_drawer.dart';

class PatientListPage extends StatefulWidget {
  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<Patient> patients = []; // Initialize with your patient data

  void _addNewPatient(Patient patient) {
    setState(() {
      patients.add(patient);
    });
  }

  void _deletePatient(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Patient'),
          content:
              Text('Are you sure you want to delete ${patients[index].name}?'),
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
                setState(() {
                  patients.removeAt(index);
                });
                Navigator.of(context).pop();
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
        title: Text('Patient List'),
        backgroundColor: Colors.teal,
      ),
      drawer: SideNavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: patients.isEmpty
            ? Center(
                child: Text(
                  'No patients added yet.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      title: Text(
                        patient.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(patient.location),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPatientPage(
                                    patient: patient,
                                    onSave: (updatedPatient) {
                                      setState(() {
                                        patients[index] = updatedPatient;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePatient(index),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientSummaryPage(
                              patient: patient,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final newPatient = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailPage(),
                ),
              );
              if (newPatient != null) {
                _addNewPatient(newPatient);
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.teal,
            tooltip: 'Add Patient',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              if (patients.isNotEmpty) {
                // Your existing code for navigating to verification page
              }
            },
            child: Icon(Icons.receipt),
            backgroundColor: Colors.teal,
            tooltip: 'View Records',
          ),
        ],
      ),
    );
  }
}
