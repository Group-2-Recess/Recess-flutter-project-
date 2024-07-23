import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/firestore_service.dart'; // Import necessary for future use
import 'medication_verification_page.dart';

class MedicationReminderList extends StatelessWidget {
  final List<Medication> medications;
  final String patientName;
  final String patientId;
  final String patientGender; // Added this parameter

  MedicationReminderList({
    required this.medications,
    required this.patientName,
    required this.patientId,
    required this.patientGender, // Initialize this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Reminders'),
        backgroundColor: Colors.teal,
      ),
      body: medications.isEmpty
          ? Center(child: Text('No medication reminders set.'))
          : ListView.builder(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                Medication medication = medications[index];
                return ListTile(
                  title: Text(medication.medicationName),
                  subtitle: Text(
                      'Time: ${_formatMedicationTime(medication.alarms[0], context)}'), // Displaying the first alarm time
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicationVerificationPage(
                          patientId: patientId,
                          patientName: patientName,
                          medicationId: medication.id, // Fixed this reference
                          patientGender:
                              patientGender, // Use the actual patient gender
                          medicationName: medication.medicationName,
                          time: _convertToTimeOfDay(
                              medication.alarms[0]), // Use the first alarm time
                          taken: false, // Replace with the actual taken status
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatMedicationTime(
      MedicationTime medicationTime, BuildContext context) {
    final timeOfDay =
        TimeOfDay(hour: medicationTime.hour, minute: medicationTime.minute);
    return timeOfDay.format(context);
  }

  TimeOfDay _convertToTimeOfDay(MedicationTime medicationTime) {
    return TimeOfDay(hour: medicationTime.hour, minute: medicationTime.minute);
  }
}
