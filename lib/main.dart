import 'package:flutter/material.dart';
import 'package:signup_and_login/Components/Screens/login.dart';
import 'package:signup_and_login/Components/Screens/signup.dart';
import 'package:signup_and_login/Components/Screens/forgotPassword.dart';

void main() {
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
      },
    );
  }
}
