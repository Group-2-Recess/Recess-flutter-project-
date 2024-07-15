import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medical_reminder/Components/Screens/forgotPassword.dart';
import 'package:medical_reminder/Components/Screens/login.dart';
import 'package:medical_reminder/Components/Screens/signup.dart';
import 'package:medical_reminder/selection_page.dart';
import 'package:medical_reminder/patient_page.dart';
import 'package:medical_reminder/caregiver.dart';
import 'package:medical_reminder/Components/Screens/patient_profile.dart';
import 'package:medical_reminder/Components/Screens/user_details_form.dart';
import 'package:medical_reminder/Components/Screens/prescription_details_page.dart';
import 'package:medical_reminder/Components/Screens/reminder_page.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/notification_service.dart';
import 'set_reminder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      appId: "YOUR_APP_ID",
      messagingSenderId: "YOUR_SENDER_ID",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_STORAGE_BUCKET",
    ),
  );
  await _initializePathProvider(); // Initialize path_provider
  runApp(const MyApp());
}

Future<void> _initializePathProvider() async {
  try {
    await getApplicationDocumentsDirectory(); // Initialize path_provider
  } catch (e) {
    print('Error initializing path provider: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Login(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/patient': (context) => const PatientPage(),
        '/selection': (context) => const SelectionPage(),
        '/caregiver': (context) => const CaregiverPage(),
        '/user-details-form': (context) => UserDetailsForm(),
        '/prescription-details': (context) => PrescriptionDetailsPage(),
        '/reminder': (context) => ReminderPage(),
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
    _notificationService.initialize(); // Initialize notification service
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
    );

    // Save patient data and navigate back
    Navigator.pop(context, updatedPatient);

    // Schedule reminders for each medication
    medications.forEach((medication) {
      // Schedule reminder for each alarm
      medication.alarms.forEach((alarm) {
        // Calculate reminder time (1 hour before medication time)
        DateTime medicationTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          alarm.hour,
          alarm.minute,
        );
        DateTime reminderDateTime = medicationTime.subtract(Duration(hours: 1));

        // Schedule reminder
        _scheduleMedicationReminder(
          medication.medicationName,
          TimeOfDay.fromDateTime(reminderDateTime),
        );
      });
    });
  }

  Future<void> _scheduleMedicationReminder(
      String medicationName, TimeOfDay time) async {
    final hour = time.hour;
    final minute = time.minute;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Added Medications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        SizedBox(height: 16),
        medications.isEmpty
            ? Text(
                'No medications added yet.',
                style: TextStyle(fontSize: 16),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        medication.medicationName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      subtitle: Text(medication.sicknessName),
                      trailing: Icon(Icons.arrow_forward, color: Colors.teal),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetReminderPage(
                              medication: medication,
                              patient: widget.patient,
                            ),
                          ),
                        ).then((updatedPatient) {
                          if (updatedPatient != null) {
                            _updatePatient(updatedPatient);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }
}
