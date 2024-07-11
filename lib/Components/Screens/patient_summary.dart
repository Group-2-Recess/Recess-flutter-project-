// patient_summary_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_reminder/models/patient.dart';
import 'record_page.dart';
import 'medication_verification_page.dart';

class PatientSummaryPage extends StatelessWidget {
  final Patient patient;

  PatientSummaryPage({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Summary'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.receipt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordPage(
                    patientName: patient.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSectionTitle('Patient Details', Icons.person),
              _buildCard([
                _buildDetailRow('Name:', patient.name),
                _buildDetailRow('Location:', patient.location),
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
                          'Sickness Name:',
                          medication.sicknessName,
                        ),
                        _buildDetailRow(
                          'Medication Name:',
                          medication.medicationName,
                        ),
                        _buildDetailRow(
                          'Prescription:',
                          medication.prescription,
                        ),
                      ]),
                      SizedBox(height: 16),
                      _buildSectionTitle(
                        'Alarms for ${medication.medicationName}',
                        Icons.alarm,
                      ),
                      _buildCard([
                        if (medication.alarms.isEmpty)
                          Text('No alarms set for this medication.')
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: medication.alarms.map((time) {
                              return ListTile(
                                leading: Icon(
                                  Icons.alarm,
                                  color: Colors.teal,
                                ),
                                title: Text(
                                  'Verify alarm at ${_formatTimeOfDay(time)}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () {
                                    _showVerificationDialog(
                                      context,
                                      patient.name,
                                      patient.gender,
                                      medication.medicationName,
                                      time,
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                      ]),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList(),
            ],
          ),
        ),
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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

  void _showVerificationDialog(BuildContext context, String patientName,
      String patientGender, String medicationName, TimeOfDay time) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Medication'),
          content: Text(
              'Did you take your medication at ${_formatTimeOfDay(time)}?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationVerificationPage(
                      patientName: patientName,
                      patientGender: patientGender,
                      medicationName: medicationName,
                      time: time,
                      taken: false,
                    ),
                  ),
                ).then((_) =>
                    _refreshRecords(context, patientName)); // Refresh records
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationVerificationPage(
                      patientName: patientName,
                      patientGender: patientGender,
                      medicationName: medicationName,
                      time: time,
                      taken: true,
                    ),
                  ),
                ).then((_) =>
                    _refreshRecords(context, patientName)); // Refresh records
              },
            ),
          ],
        );
      },
    );
  }

  void _refreshRecords(BuildContext context, String patientName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RecordPage(patientName: patientName),
      ),
    );
  }
}
