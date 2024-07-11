import 'package:flutter/material.dart';
import 'caregiver.dart'; // Adjust the import based on your file structure
import 'patient_page.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('ARE YOU? Tell us more about you')),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://c8.alamy.com/comp/D91YB6/beautiful-medical-nurse-portrait-in-office-D91YB6.jpg',
            fit: BoxFit.fill,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CaregiverPage()),
                    );
                  },
                  child: const Text('Are you a Caregiver/Nurse?'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PatientPage()),
                    );
                  },
                  child: const Text('Are you a Patient?'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
