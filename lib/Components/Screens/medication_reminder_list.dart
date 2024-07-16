import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'medication_verification_page.dart';

class MedicationReminderList extends StatelessWidget {
  final List<Medication> medications;
  final String patientName;

  MedicationReminderList({
    required this.medications,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Reminders'),
      ),
      body: medications.isNotEmpty
          ? ListView.builder(
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
                          patientId: '', // Pass the appropriate patientId
                          patientName: patientName,
                          patientGender:
                              'Gender', // Replace with actual patient gender
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
            )
          : Center(
              child: Text('No medication reminders set.'),
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
