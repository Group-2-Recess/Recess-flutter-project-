import 'package:flutter/material.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/models/patient.dart';
import 'patient_summary_page.dart';
import 'patient_detail.dart'; // Import PatientDetailPage

class PatientListPage extends StatefulWidget {
  final String userId;
  final String caregiverId;

  const PatientListPage({
    super.key,
    required this.userId,
    required this.caregiverId,
  });

  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      // Fetch patients for the specific caregiver ID
      final fetchedPatients =
          await _firestoreService.getPatients(widget.caregiverId);
      setState(() {
        patients = fetchedPatients;
      });
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  void _navigateToPatientSummary(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientSummaryPage(
          userId: widget.userId,
          caregiverId: widget.caregiverId,
          patient: patient, // Pass Patient object
        ),
      ),
    );
  }

  void _navigateToEditPatient(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailPage(
          userId: widget.userId,
          caregiverId: widget.caregiverId,
          patient: patient, // Pass Patient object for editing
        ),
      ),
    );
  }

  Future<void> _deletePatient(Patient patient) async {
    try {
      await _firestoreService.deletePatient(
        widget.caregiverId,
        patient.id,
      );
      setState(() {
        patients.remove(patient);
      });
    } catch (e) {
      print('Error deleting patient: $e');
    }
  }

  void _navigateToAddPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailPage(
          userId: widget.userId,
          caregiverId: widget.caregiverId,
          // No patient object for adding a new patient
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
        backgroundColor: Colors.green[800], // Dark green color for AppBar
      ),
      body: patients.isEmpty
          ? Center(
              child: Text('No patients available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600])))
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      patient.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[700],
                      ),
                    ),
                    subtitle: Text(patient.address,
                        style: TextStyle(color: Colors.grey[600])),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEditPatient(patient);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(patient);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToPatientSummary(patient),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPatient,
        backgroundColor: Colors.green[600], // Green color for FAB
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Patient patient) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Patient'),
          content: Text('Are you sure you want to delete ${patient.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deletePatient(patient);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
