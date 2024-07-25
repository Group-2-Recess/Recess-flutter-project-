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
import 'package:medical_reminder/Components/Screens/medication_detail.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/components/screens/medication_verification_page.dart';
import 'package:uuid/uuid.dart';
import 'package:medical_reminder/Components/Screens/patient_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        '/user-details-form': (context) => UserDetailsForm(userId: ''),
        '/prescription-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          final patientId = args['patientId'] as String;
          return PrescriptionDetailsPage(patientId: patientId);
        },
      },
    );
  }
}
