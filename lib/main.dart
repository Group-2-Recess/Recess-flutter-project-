import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medical_reminder/Components/Screens/forgotPassword.dart';
import 'package:medical_reminder/Components/Screens/login.dart';
import 'package:medical_reminder/Components/Screens/signup.dart';
import 'package:medical_reminder/selection_page.dart'; // Adjust this import
import 'package:medical_reminder/patient_page.dart';    // Adjust this import
import 'package:medical_reminder/caregiver.dart';    // Import CaregiverPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "your_api_key",
      appId: "your_app_id",
      messagingSenderId: "your_sender_id",
      projectId: "your_project_id",
      storageBucket: "your_storage_bucket",
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
      home: const Login(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/patient': (context) => const PatientPage(),
        '/selection': (context) => const SelectionPage(),
        '/caregiver': (context) => const CaregiverPage(),  // Add route for CaregiverPage
      },
    );
  }
}
