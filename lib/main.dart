import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:medical_reminder/Components/Screens/forgotPassword.dart';
import 'package:medical_reminder/Components/Screens/login.dart';
import 'package:medical_reminder/Components/Screens/signup.dart';
import 'package:medical_reminder/selection_page.dart'; // Adjust this import
import 'package:medical_reminder/patient_page.dart'; // Adjust this import
import 'package:medical_reminder/caregiver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCMeU0NysPEF_zf09VXRCKifZWOMNhhc1U",
      appId: "medical-reminder-app-8ce9e",
      messagingSenderId: "564875037088",
      projectId: "medical-reminder-app-8ce9e",
      storageBucket: "medical-reminder-app-8ce9e.appspot.com",
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
        '/caregiver': (context) =>
            const CaregiverPage(), // Add route for CaregiverPage
      },
    );
  }
}
