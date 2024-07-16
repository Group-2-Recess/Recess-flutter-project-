import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'record_page.dart';
import 'medication_verification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientSummaryPage extends StatefulWidget {
  final String patientId;

  PatientSummaryPage({required this.patientId});

  @override
  _PatientSummaryPageState createState() => _PatientSummaryPageState();
}

class _PatientSummaryPageState extends State<PatientSummaryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<Patient> _patientFuture;

  @override
  void initState() {
    super.initState();
    _patientFuture = _fetchPatientData();
  }

  Future<Patient> _fetchPatientData() async {
    try {
      var patient = await _firestoreService.getPatient(widget.patientId);
      if (patient.medications.isEmpty) {
        var meds = await _firestoreService.getMedications(widget.patientId);
        patient.medications.addAll(meds);
      }
      print('Fetched patient data: $patient');
      return patient;
    } catch (e) {
      print('Error fetching patient data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Summary'),
        backgroundColor: Colors.teal,
        actions: [
          FutureBuilder<Patient>(
            future: _patientFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Text('No data');
              } else {
                var patient = snapshot.data!;
                return IconButton(
                  icon: Icon(Icons.receipt),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordPage(
                          patientId: patient.id,
                          patientName: patient.name,
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Patient>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching patient data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No patient data available'));
          } else {
            var patient = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Patient Details', Icons.person),
                  _buildCard([
                    _buildDetailRow('Name:', patient.name),
                    _buildDetailRow('Location:', patient.location),
                    _buildDetailRow('Gender:', patient.gender),
                    _buildDetailRow('Doctor:', patient.doctor),
                  ]),
                  SizedBox(height: 16),
                  _buildSectionTitle('Medications', Icons.local_hospital),
                  if (patient.medications.isEmpty)
                    Text('No medications added yet.')
                  else
                    ...patient.medications.map((medication) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCard([
                            _buildDetailRow(
                                'Sickness Name:', medication.sicknessName),
                            _buildDetailRow(
                                'Medication Name:', medication.medicationName),
                            _buildDetailRow(
                                'Prescription:', medication.prescription),
                          ]),
                          SizedBox(height: 16),
                          _buildSectionTitle(
                              'Alarms for ${medication.medicationName}',
                              Icons.alarm),
                          _buildCard([
                            if (medication.alarms.isEmpty)
                              Text('No alarms set for this medication.')
                            else
                              ...medication.alarms.map((time) {
                                return ListTile(
                                  leading:
                                      Icon(Icons.alarm, color: Colors.teal),
                                  title: Text(
                                      'Verify alarm at ${_formatTimeOfDay(time.toTimeOfDay())}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.check_circle_outline,
                                        color: Colors.teal),
                                    onPressed: () {
                                      _showVerificationDialog(
                                        context,
                                        patient.id,
                                        patient.name,
                                        patient.gender,
                                        medication.medicationName,
                                        time.toTimeOfDay(),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                          ]),
                          SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dateTime);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _showVerificationDialog(
    BuildContext context,
    String patientId,
    String patientName,
    String patientGender,
    String medicationName,
    TimeOfDay alarmTime,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Medication Intake'),
          content: Text(
              'Did $patientName take $medicationName at ${alarmTime.format(context)}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationVerificationPage(
                      patientId: patientId,
                      patientName: patientName,
                      patientGender: patientGender,
                      medicationName: medicationName,
                      time: alarmTime,
                      taken: true, // Assuming verification means taken
                    ),
                  ),
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
