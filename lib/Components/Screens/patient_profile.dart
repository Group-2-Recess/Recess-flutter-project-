import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medical_reminder/models/profilemodel.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/Components/Screens/user_details_form.dart'; // Ensure correct import path
// (corrected patient info & added newsetreminderpage)

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  DateTime? _dateOfBirth;
  io.File? _profileImage;
  final FirestoreService _firestoreService = FirestoreService();
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _checkExistingProfile();
  }

  Future<void> _checkExistingProfile() async {
    try {
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('patient_profile')
          .doc(_user.uid)
          .get();

      if (profileDoc.exists) {
        // Profile exists, redirect to UserDetailsForm
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsForm(userId: _user.uid),
          ),
        );
      }
    } catch (e) {
      print("Error checking profile: $e");
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Implement web image picker logic here if needed
    } else {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = io.File(pickedFile.path);
        });
      }
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

  Future<String> _uploadProfileImage(io.File image) async {
    if (kIsWeb) {
      // Implement web-specific upload logic here if needed
    } else {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().toString()}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    }
    return '';
  }

  Future<void> _saveProfile() async {
    try {
      String imageUrl = '';
      if (_profileImage != null) {
        imageUrl = await _uploadProfileImage(_profileImage!);
      }

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('patient_profile')
          .doc(_user.uid); // Use the logged-in user's UID as the document ID

      PatientProfile profile = PatientProfile(
        id: docRef.id, // Use the user's UID as the document ID
        firstName: _firstName,
        lastName: _lastName,
        dateOfBirth: _dateOfBirth!,
        profileImageUrl: imageUrl,
      );

      await _firestoreService.savePatientProfile(profile);

      Fluttertoast.showToast(
        msg: "Profile created successfully.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsForm(userId: _user.uid),
        ),
      );
    } catch (e) {
      print("Error saving profile: $e");
      Fluttertoast.showToast(
        msg: "Failed to create profile.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        elevation: 2.0,
        title: Text(
          'Create Your Patient Profile',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80.0,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.add_a_photo,
                            size: 40.0, color: Colors.grey[600])
                        : null,
                  ),
                ),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 12.0),
                        ),
                        onSaved: (value) => _firstName = value!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your first name'
                            : null,
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 12.0),
                        ),
                        onSaved: (value) => _lastName = value!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your last name'
                            : null,
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 12.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today,
                                color: Colors.pink[300]),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        onTap: () => _selectDate(context),
                        validator: (value) => _dateOfBirth == null
                            ? 'Please select your date of birth'
                            : null,
                        controller: TextEditingController(
                          text: _dateOfBirth == null
                              ? ''
                              : "${_dateOfBirth!.toLocal()}".split(' ')[0],
                        ),
                      ),
                      SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _saveProfile();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 55, 210, 91), // Background color
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
