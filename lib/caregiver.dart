import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_reminder/utils.dart';
import 'package:medical_reminder/Components/Screens/home_page.dart'; // Import the HomePage
import 'package:medical_reminder/firestore_service.dart'; // Import FirestoreService
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverPage extends StatefulWidget {
  const CaregiverPage({Key? key}) : super(key: key);

  @override
  _CaregiverPageState createState() => _CaregiverPageState();
}

class _CaregiverPageState extends State<CaregiverPage> {
  final formKey = GlobalKey<FormState>();
  Uint8List? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController organisationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  Future<void> selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in')),
        );
        return;
      }

      final userId = user.uid;
      final caregiverData = {
        'name': nameController.text,
        'organisation': organisationController.text,
        'location': locationController.text,
        'image': _image != null ? _image!.toList() : null,
      };

      final firestoreService = FirestoreService();
      await firestoreService.saveCaregiverProfile(userId, caregiverData);

      // Retrieve profile ID and navigate to HomePage
      String profileId = await firestoreService.getProfileId(userId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(), // No parameters
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Page'),
        backgroundColor: Colors.green,
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
          Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 36),
                const Text(
                  'Create your nurse/caregiver profile here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 36),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundImage: _image != null
                              ? MemoryImage(_image!)
                              : const NetworkImage(
                                  'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg',
                                ) as ImageProvider,
                        ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo,
                                color: Colors.white),
                            onPressed: selectImage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                buildNames(),
                const SizedBox(height: 36),
                buildOrganisationName(),
                const SizedBox(height: 36),
                buildLocation(),
                const SizedBox(height: 36),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNames() => TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: "FULL NAMES",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(16),
          labelStyle: TextStyle(color: Colors.green),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      );

  Widget buildOrganisationName() => TextFormField(
        controller: organisationController,
        decoration: InputDecoration(
          labelText: "ORGANISATION NAME",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.green),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your organization';
          }
          return null;
        },
      );

  Widget buildLocation() => TextFormField(
        controller: locationController,
        decoration: InputDecoration(
          labelText: "LOCATION",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.green),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your location';
          }
          return null;
        },
      );
}
