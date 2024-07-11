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
      apiKey: "AIzaSyCMeU0NysPEF_zf09VXRCKifZWOMNhhc1U",
      appId: "1:564875037088:web:6aa8a55d90c535b12abcc5",
      messagingSenderId: "564875037088",
      projectId: "medical-reminder-app-8ce9e",
      storageBucket: "medical-reminder-app-8ce9e.appspot.com",
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
