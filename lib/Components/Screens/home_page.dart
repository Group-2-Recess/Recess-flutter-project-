import 'package:flutter/material.dart';
import 'patient_list.dart'; // Adjust path as per your project structure
import 'package:medical_reminder/firestore_service.dart'; // Adjust path as per your project structure

class HomePage extends StatelessWidget {
  final String userId; // Added userId as a required parameter
  final FirestoreService firestoreService = FirestoreService();

  HomePage({required this.userId}); // Initialize userId through constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/nurse.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Pill Reminder App!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Never miss a med',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientListPage(
                            userId: userId, // Pass userId to PatientListPage
                          ),
                        ),
                      );
                    },
                    child: Text('View Patients'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
