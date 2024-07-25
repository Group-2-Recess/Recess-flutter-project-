// ProfilePage.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // For image byte data
import 'user_details_form.dart'; // Ensure this is the correct path to UserDetailsForm

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  DateTime? _dateOfBirth;
  Uint8List? _profileImage; // Change to Uint8List for Flutter Web
  String? _profileImageUrl; // URL for displaying the image

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes =
          await pickedFile.readAsBytes(); // Use readAsBytes for async operation
      setState(() {
        _profileImage = bytes;
        _profileImageUrl = null; // Reset the profile image URL
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateOfBirth = pickedDate;
      });
    }
  }

  Future<String> _uploadProfileImage(Uint8List image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${DateTime.now().toString()}');
    final uploadTask = storageRef.putData(image);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_profileImage != null && _dateOfBirth != null) {
        String imageUrl;
        try {
          imageUrl = await _uploadProfileImage(_profileImage!);
        } catch (error) {
          // Handle image upload error (e.g., display a snackbar)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading profile image: $error")),
          );
          return;
        }

        // Create a document reference for the user profile
        final userRef =
            FirebaseFirestore.instance.collection('patient_profiles').doc();

        // Save profile data
        await userRef.set({
          'id': userRef.id, // Use the document ID as profile ID
          'firstName': _firstName,
          'lastName': _lastName,
          'dateOfBirth': Timestamp.fromDate(_dateOfBirth!),
          'profileImageUrl': imageUrl,
        });

        // Navigate to UserDetailsForm after successful save, passing the userId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsForm(userId: userRef.id),
          ),
        );
      } else {
        // Handle case where no profile image is selected or date of birth is not set
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Please select a profile image and date of birth.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0.0,
        title: Text(
          'Create Your Patient Profile',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onSaved: (value) => _firstName = value!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your first name'
                            : null,
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onSaved: (value) => _lastName = value!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your last name'
                            : null,
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: TextEditingController(
                          text: _dateOfBirth != null
                              ? "${_dateOfBirth!.year}-${_dateOfBirth!.month}-${_dateOfBirth!.day}"
                              : '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) => _dateOfBirth == null
                            ? 'Please select your date of birth'
                            : null,
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? MemoryImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(Icons.camera_alt, size: 50)
                              : null,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        child: Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
