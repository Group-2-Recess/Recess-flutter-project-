import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/models/patient.dart';
import 'medication_reminder_list.dart'; // Adjust the import path as per your actual structure
import 'patient_list.dart'; // Adjust the import path as per your actual structure
import 'set_reminder.dart'; // Import SetReminderPage

class SideNavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Navigation Drawer',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Patients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientListPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.alarm),
            title: Text('Medication Reminders'),
            onTap: () {
              Navigator.pop(context);

              // Example patient data
              Patient selectedPatient = Patient(
                id: 'example-id',
                name: 'Example Patient',
                location: 'Example Location',
                gender: 'Example Gender',
                doctor: 'Example Doctor',
                medications: [
                  Medication(
                    id: 'example-medication-id',
                    medicationName: 'Example Medication',
                    sicknessName: 'Example Sickness',
                    prescription: 'Example Prescription',
                    alarms: [], // Example alarms
                    isVerified: false,
                    verificationDate: DateTime.now(),
                  ),
                ],
                verificationRecords: [],
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicationReminderList(
                    medications: selectedPatient.medications,
                    patientId: selectedPatient.id,
                    patientName: selectedPatient.name,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add_alarm),
            title: Text('Set Reminder'),
            onTap: () {
              Navigator.pop(context);

              // Use actual data or example data
              Patient selectedPatient = Patient(
                id: 'example-id',
                name: 'Example Patient',
                location: 'Example Location',
                gender: 'Example Gender',
                doctor: 'Example Doctor',
                medications: [],
                verificationRecords: [],
              );

              Medication selectedMedication = selectedPatient.medications.isNotEmpty
                  ? selectedPatient.medications[0]
                  : Medication(
                      id: 'example-medication-id',
                      medicationName: 'Example Medication',
                      sicknessName: 'Example Sickness',
                      prescription: 'Example Prescription',
                      alarms: [],
                      isVerified: false,
                      verificationDate: DateTime.now(),
                    );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SetReminderPage(
                    patient: selectedPatient,
                    medication: selectedMedication,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
