import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:intl/intl.dart';
import 'medication_verification_page.dart';
import 'patient_list.dart';
import 'set_reminder.dart'; // Import the verification page

class MedicationDetailPage extends StatefulWidget {
  final Patient patient;

  MedicationDetailPage({required this.patient});

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
        widget.patient.medications =
            medications; // Update patient's medications as well
      });

      // Print retrieved data
      print('Retrieved medications for patient ${widget.patient.id}:');
      for (var med in medications) {
        print('Medication Name: ${med.medicationName}');
        print('Sickness Name: ${med.sicknessName}');
        print('Prescription: ${med.prescription}');
        print('Alarms: ${med.alarms}');
        print('Is Verified: ${med.isVerified}');
        print('Verification Date: ${med.verificationDate}');
        print('---------------');
      }
    } catch (e) {
      print('Error fetching medications: $e');
      // Handle error as needed
    }
  }

  void _navigateToSetReminder(Medication medication) async {
    final newAlarms = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetReminderPage(
          patient: widget.patient,
          medication: medication,
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
      ));
    });
  }

  void _saveMedications() {
    if (_formKey.currentState!.validate() &&
        _medications.every((m) => m.alarms.isNotEmpty)) {
      _formKey.currentState!.save();
      widget.patient.medications = _medications;

      _firestoreService.savePatient(widget.patient).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medications saved successfully')),
        );

        // Navigate to PatientListPage after saving
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientListPage()),
        );
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

  void _navigateToVerification(Medication medication) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationVerificationPage(
          patientId: widget.patient.id,
          patientName: widget.patient.name,
          patientGender: widget.patient.gender,
          medicationName: medication.medicationName,
          time: TimeOfDay
              .now(), // You may need to adjust this based on how you get the time
          taken: true, // Set this based on user input or logic
        ),
      ),
    );

    if (result != null && result) {
      // Update medication verification status or perform other actions as needed
      medication.isVerified = true;
      medication.verificationDate = DateTime.now(); // Update verification date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medications'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._medications.map((medication) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Medication Name'),
                          initialValue: medication.medicationName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medication name';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              medication.medicationName = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Sickness Name'),
                          initialValue: medication.sicknessName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter sickness name';
                            }
                            return null;
                          },
                          onSaved: (value) => medication.sicknessName = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Dosage Instructions'),
                          initialValue: medication.prescription,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage instructions';
                            }
                            return null;
                          },
                          onSaved: (value) => medication.prescription = value!,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text('Reminder Time:'),
                            TextButton(
                              onPressed: () =>
                                  _navigateToSetReminder(medication),
                              child: Text(
                                medication.alarms.isEmpty
                                    ? 'Add Reminder'
                                    : 'Change Reminder',
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                        if (medication.alarms.isNotEmpty) ...[
                          Text('Reminders:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: medication.alarms.length,
                            itemBuilder: (context, index) {
                              MedicationTime alarm = medication.alarms[index];
                              return Text(
                                '- ${alarm.hour}:${alarm.minute.toString().padLeft(2, '0')}',
                              );
                            },
                          ),
                        ],
                        SizedBox(height: 16),
                        Divider(),
                        ElevatedButton(
                          onPressed: () => _navigateToVerification(medication),
                          child: Text('Verify Medication'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addMedication,
                child: Text('Add Another Medication'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMedications,
                child: Text('Save Medications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
