import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'set_reminder.dart';

class MedicationDetailPage extends StatefulWidget {
  final Patient patient;
  final String userId;

  MedicationDetailPage({required this.patient, required this.userId});

  @override
  _MedicationDetailPageState createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  final _formKey = GlobalKey<FormState>();
  List<Medication> _medications = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    try {
      List<Medication> medications =
          await _firestoreService.fetchMedicationsForPatient(widget.patient.id);
      setState(() {
        _medications = medications;
      });
    } catch (e) {
      print('Error fetching medications: $e');
    }
  }

  void _navigateToSetReminder(Medication medication) async {
    final newAlarms = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminderPage(
          medication: medication,
          userId: widget.userId,
          patientId: widget.patient.id,
        ),
      ),
    );

    if (newAlarms != null) {
      setState(() {
        medication.alarms = newAlarms;
      });
    }
  }

  void _addMedication() {
    setState(() {
      _medications.add(Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sicknessName: '',
        medicationName: '',
        prescription: '',
        alarms: [],
        isVerified: false,
        verificationDate: DateTime.now(),
        userId: widget.userId,
      ));
    });
  }

  void _saveMedications() {
    if (_formKey.currentState!.validate() &&
        _medications.every((med) => med.alarms.isNotEmpty)) {
      _formKey.currentState!.save();

      widget.patient.medications = _medications;

      _firestoreService.savePatient(widget.patient).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medications saved successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save medications: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please set reminders for all medications and ensure all fields are filled'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Enter Medication Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              ..._medications.map((medication) => Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: medication.medicationName,
                            decoration:
                                InputDecoration(labelText: 'Medication Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the medication name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              medication.medicationName = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            initialValue: medication.sicknessName,
                            decoration:
                                InputDecoration(labelText: 'Sickness Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the sickness name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              medication.sicknessName = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            initialValue: medication.prescription,
                            decoration:
                                InputDecoration(labelText: 'Prescription'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the prescription';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              medication.prescription = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _navigateToSetReminder(medication),
                            child: Text('Set Reminders'),
                          ),
                        ],
                      ),
                    ),
                  )),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addMedication,
                  child: Text('Add Medication'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveMedications,
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
