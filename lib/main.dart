import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medical_reminder/firebase_options.dart';
import 'package:medical_reminder/Components/Screens/login.dart';
import 'package:medical_reminder/Components/Screens/signup.dart';
import 'package:medical_reminder/selection_page.dart';
import 'package:medical_reminder/patient_page.dart';
import 'package:medical_reminder/caregiver.dart';
import 'package:medical_reminder/Components/Screens/user_details_form.dart';
import 'package:medical_reminder/Components/Screens/prescription_details_page.dart';
import 'package:medical_reminder/Components/Screens/set_reminder.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/notification_service.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/models/verification_record.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCMeU0NysPEF_zf09VXRCKifZWOMNhhc1U",
      authDomain: "medical-reminder-app-8ce9e.firebaseapp.com",
      projectId: "medical-reminder-app-8ce9e",
      storageBucket: "medical-reminder-app-8ce9e.appspot.com",
      messagingSenderId: "564875037088",
      appId: "1:564875037088:web:6aa8a55d90c535b12abcc5",
      measurementId: "G-W8LTEGW3DR",

    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/patient': (context) => const PatientPage(),
        '/selection': (context) => const SelectionPage(),
        '/caregiver': (context) => const CaregiverPage(),
        '/user-details-form': (context) => UserDetailsForm(),
        '/prescription-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PrescriptionDetailsPage(patientId: args['patientId']);
        },
        '/set-reminder': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SetReminderPage(
            patient: args['patient'] as Patient,
            medication: args['medication'] as Medication,
          );
        },
      },
    );
  }
}

class MedicationDetailPage extends StatefulWidget {
  final Patient patient;

  MedicationDetailPage({required this.patient});

  @override
  _MedicationDetailPageState createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  final _formKey = GlobalKey<FormState>();
  List<Medication> medications = [];
  String _sicknessName = '';
  String _medicationName = '';
  String _prescription = '';

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    medications = widget.patient.medications;
    _notificationService.initialize();
  }

  void _updatePatient(Patient updatedPatient) {
    setState(() {
      medications = updatedPatient.medications;
    });
  }

  void _saveMedicationsAndSetReminders() {
    if (medications.isEmpty || medications.any((med) => med.alarms.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please set reminders for each medication')),
      );
      return;
    }

    Patient updatedPatient = Patient(
      name: widget.patient.name,
      location: widget.patient.location,
      gender: widget.patient.gender,
      doctor: widget.patient.doctor,
      medications: medications,
      id: '',
      verificationRecords: [],
    );

    Navigator.pop(context, updatedPatient);

    medications.forEach((medication) {
      medication.alarms.forEach((alarm) {
        DateTime medicationTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          alarm.hour,
          alarm.minute,
        );
        DateTime reminderDateTime = medicationTime.subtract(Duration(hours: 1));

        _scheduleMedicationReminder(
          medication.medicationName,
          TimeOfDay.fromDateTime(reminderDateTime),
        );
      });
    });
  }

  Future<void> _scheduleMedicationReminder(String medicationName, TimeOfDay time) async {
    final hour = time.hour.toString();
    final minute = time.minute.toString();
    final title = 'Medication Reminder';
    final body = 'Time to take $medicationName!';

    await _notificationService.scheduleNotification(hour, minute, title, body);
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
          child: ListView(
            children: <Widget>[
              Text(
                'Add Medication',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 16),
              _buildTextField('Sickness Name', (value) {
                _sicknessName = value!;
              }),
              SizedBox(height: 16),
              _buildTextField('Medication Name', (value) {
                _medicationName = value!;
              }),
              SizedBox(height: 16),
              _buildTextField('Prescription', (value) {
                _prescription = value!;
              }),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Medication newMedication = Medication(
                      sicknessName: _sicknessName,
                      medicationName: _medicationName,
                      prescription: _prescription,
                      alarms: [],
                      isVerified: false,
                      verificationDate: DateTime.now(),
                      id: Uuid().v4(),
                    );
                    setState(() {
                      medications.add(newMedication);
                    });
                  }
                },
                icon: Icon(Icons.add),
                label: Text('Add Medication'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildMedicationList(),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveMedicationsAndSetReminders,
                icon: Icon(Icons.save),
                label: Text('Save Medications and Set Reminders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, FormFieldSetter<String> onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the $label';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  Widget _buildMedicationList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return ListTile(
          title: Text(medication.medicationName),
          subtitle: Text(medication.sicknessName),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/set-reminder',
                arguments: {
                  'patient': widget.patient,
                  'medication': medication,
                },
              ).then((updatedMedication) {
                if (updatedMedication != null) {
                  setState(() {
                    medications[index] = updatedMedication as Medication;
                  });
                }
              });
            },
          ),
        );
      },
    );
  }
}
