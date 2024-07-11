import 'package:flutter/material.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Page'),
      ),
      body: const Center(
        child: Text(
          'Welcome, Patient!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
