import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/models/patient.dart';
import 'medication_reminder_list.dart'; // Adjust the import path as per your actual structure
import 'patient_list.dart'; // Adjust the import path as per your actual structure

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
              // Navigate to PatientListPage
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
              // Sample data for testing
              List<Medication> sampleMedications = [
                Medication(
                  id: '',
                  medicationName: '',
                  sicknessName: '',
                  prescription: '',
                  alarms: [],
                  isVerified: false,
                  verificationDate: DateTime.now(),

                  // Initialize as an empty map
                ),
              ];

              // Example patient data
              // Example patient data
              Patient selectedPatient = Patient(
                id: '',
                name: '',
                location: '',
                gender: '',
                doctor: '',
                medications: sampleMedications,
                verificationRecords: [], // Assuming it's an empty list for now
              );

              // Navigate to the MedicationReminderList
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicationReminderList(
                    medications: selectedPatient.medications,
                    patientName: selectedPatient.name,
                  ),
                ),
              );
            },
          ),
          // Add more items as needed
        ],
      ),
    );
  }
}
