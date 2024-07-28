import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'set_reminder.dart';
import 'package:medical_reminder/models/patient.dart';

class MedicationDetailPage extends StatefulWidget {
  final String patientId; // Changed to String
  final String userId;
  final String caregiverId;

  MedicationDetailPage({
    required this.patientId,
    required this.userId,
    required this.caregiverId,
  });

  @override
  _MedicationDetailPageState createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late List<Medication> _medications;

  // Form fields
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _medicationDoseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _medications = [];
    _loadMedications();
  }

  void _loadMedications() {
    _firestoreService
        .fetchMedicationsForPatient(
      widget.userId, // Pass userId
      widget.caregiverId, // Pass caregiverId
      widget.patientId, // Pass patientId
    )
        .then((medications) {
      setState(() {
        _medications = medications;
      });
    }).catchError((error) {
      print('Error loading medications: $error');
      // Handle the error appropriately
    });
  }

  void _saveMedication(Medication medication) {
    _firestoreService
        .saveMedication(widget.patientId, widget.caregiverId, medication)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication saved successfully')),
      );
      _loadMedications(); // Refresh medication list
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save medication: $error')),
      );
    });
  }

  void _navigateToSetReminder(Medication medication) async {
    final updatedAlarms = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminderPage(
          medication: medication,
          caregiverId: widget.caregiverId,
          patientId: widget.patientId,
          userId: widget.userId,
        ),
      ),
    );

    if (updatedAlarms != null) {
      setState(() {
        medication.alarms = updatedAlarms;
      });
    }
  }

  void _addMedication() {
    if (_formKey.currentState!.validate()) {
      final newMedication = Medication(
        id: _firestoreService.generateId(),
        userId: widget.userId,
        caregiverId: widget.caregiverId,
        patientId: widget.patientId,
        sicknessName: '', // Default or empty value
        medicationName: _medicationNameController.text,
        prescription: _medicationDoseController.text,
        alarms: [], // Initialize with an empty list of alarms
        isVerified: false, // Default value
        verificationDate: DateTime.now(), // Default value
      );
      _saveMedication(newMedication);

      // Clear form fields
      _medicationNameController.clear();
      _medicationDoseController.clear();
    }
  }

  void _deleteMedication(Medication medication) {
    _firestoreService
        .deleteMedication(widget.patientId, widget.caregiverId, medication.id)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication deleted successfully')),
      );
      setState(() {
        _medications.remove(medication);
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete medication: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Details'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Form to add new medication
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _medicationNameController,
                    decoration: InputDecoration(labelText: 'Medication Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter medication name' : null,
                  ),
                  TextFormField(
                    controller: _medicationDoseController,
                    decoration: InputDecoration(labelText: 'Dose'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter dose' : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addMedication,
                    child: Text('Add Medication'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List of existing medications
          Expanded(
            child: ListView(
              children: <Widget>[
                ..._medications.map((medication) => ListTile(
                      title: Text(medication.medicationName),
                      subtitle: Text('Dose: ${medication.prescription}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.alarm_add, color: Colors.blue),
                            onPressed: () => _navigateToSetReminder(medication),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMedication(medication),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
