import 'package:flutter/material.dart';
import 'package:medical_reminder/Components/Screens/patient_list.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firebaseService = FirestoreService();
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String caregiverId = ''; // Define caregiverId here

  @override
  void initState() {
    super.initState();
    fetchCaregiverId();
  }

  Future<void> fetchCaregiverId() async {
    try {
      caregiverId = await _firebaseService.getProfileId(userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching caregiver ID: $e')),
      );
    }
  }

  void navigateToPatientListPage(BuildContext context) {
    if (caregiverId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientListPage(
            userId: userId,
            caregiverId: caregiverId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No caregiver profile found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.teal,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      navigateToPatientListPage(context);
                    },
                    child: Text('View Patients'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                      backgroundColor: Colors.teal,
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
