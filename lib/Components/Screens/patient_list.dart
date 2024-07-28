import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'patient_detail.dart'; // Import PatientDetailPage
import 'update_patient.dart'; // Import UpdatePatientPage

class PatientListPage extends StatefulWidget {
  final String userId;
  final String caregiverId;

  PatientListPage({required this.userId, required this.caregiverId});

  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<Patient> patients = [];
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      List<Patient> fetchedPatients = await FirestoreService()
          .getPatients(widget.userId, widget.caregiverId);
      setState(() {
        patients = fetchedPatients;
        _isLoading = false; // Set loading state to false when data is fetched
      });
    } catch (e) {
      print('Error fetching patients: $e');
      setState(() {
        _isLoading =
            false; // Set loading state to false even if there is an error
      });
    }
  }

  Future<void> _deletePatient(BuildContext context, String patientId) async {
    try {
      await FirestoreService()
          .deletePatient(widget.userId, widget.caregiverId, patientId);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Patient deleted')));
      _fetchPatients(); // Refresh the patients list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete patient: $e')));
    }
  }

  void _navigateToAddPatientPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailPage(
          patient: Patient
              .empty(), // Provide a default empty patient or handle null case
          profileId: widget
              .userId, // Assuming profileId is userId for now; adjust if needed
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : patients.isEmpty
              ? Center(child: Text('No patients found'))
              : ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return ListTile(
                      title: Text(patient.name),
                      subtitle: Text(patient.location),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientDetailPage(
                              patient: patient,
                              profileId: widget.userId,
                            ),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdatePatientPage(
                                    userId: widget.userId,
                                    caregiverId: widget.caregiverId,
                                    patient: patient,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                _deletePatient(context, patient.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPatientPage,
        child: Icon(Icons.add), // Plus sign icon
        backgroundColor: Colors.teal,
        tooltip: 'Add Patient', // Tooltip text when hovering over the button
      ),
    );
  }
}
