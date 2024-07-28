import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'caregiver.dart';
import 'package:medical_reminder/Components/Screens/user_details_form.dart';
import 'package:medical_reminder/Components/Screens/patient_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medical_reminder/Components/Screens/home_page.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({Key? key}) : super(key: key);

  Future<void> _navigateToNextPage(BuildContext context, String userId) async {
    try {
      // Reference to the 'users' collection to get the user document
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user document
      final userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        String role = userSnapshot.data()?['role'] ?? '';

        if (role == 'caregiver') {
          // Reference to the 'caregiver_profiles' subcollection
          final caregiverProfilesCollection =
              userDoc.collection('caregiver_profiles');

          // Get the first document in the 'caregiver_profiles' collection
          final caregiverProfilesQuery =
              await caregiverProfilesCollection.limit(1).get();

          if (caregiverProfilesQuery.docs.isNotEmpty) {
            // If there are caregiver profiles, navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          } else {
            // If no caregiver profiles, navigate to CaregiverPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CaregiverPage(),
              ),
            );
          }
        } else if (role == 'patient') {
          // Reference to the 'patient_profiles' subcollection
          final patientProfilesCollection =
              userDoc.collection('patient_profiles');

          final patientProfilesQuery =
              await patientProfilesCollection.limit(1).get();

          if (patientProfilesQuery.docs.isNotEmpty) {
            // If there are patient profiles, navigate to UserDetailsForm
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsForm(userId: userId),
              ),
            );
          } else {
            // If no patient profiles, navigate to ProfilePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(),
              ),
            );
          }
        }
      } else {
        // If the user document does not exist, navigate to ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking profiles: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user ID from FirebaseAuth
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('ARE YOU? Tell us more about you')),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://c8.alamy.com/comp/D91YB6/beautiful-medical-nurse-portrait-in-office-D91YB6.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (userId.isNotEmpty) {
                      _navigateToNextPage(context, userId);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    }
                  },
                  child: const Text('Are you a Caregiver/Nurse?'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (userId.isNotEmpty) {
                      _navigateToNextPage(context, userId);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    }
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
