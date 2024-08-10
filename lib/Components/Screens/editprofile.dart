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

class EditProfilePage extends StatefulWidget {
  final String userId;

  // Constructor accepting userId
  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  DateTime? _dateOfBirth;
  io.File? _profileImage;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isEditingFirstName = false;
  bool _isEditingLastName = false;
  bool _isEditingDateOfBirth = false;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('patient_profile')
          .doc(widget.userId)
          .get();

      if (profileDoc.exists) {
        setState(() {
          final profile = PatientProfile.fromMap(
              profileDoc.data() as Map<String, dynamic>, profileDoc.id);
          _firstName = profile.firstName;
          _lastName = profile.lastName;
          _dateOfBirth = profile.dateOfBirth;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
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
        _isEditingDateOfBirth = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      String imageUrl = '';
      if (_profileImage != null) {
        imageUrl = await _uploadProfileImage(_profileImage!);
      }

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('patient_profile')
          .doc(widget.userId);

      PatientProfile profile = PatientProfile(
        id: docRef.id,
        firstName: _firstName,
        lastName: _lastName,
        dateOfBirth: _dateOfBirth!,
        profileImageUrl: imageUrl,
      );

      await _firestoreService.savePatientProfile(profile);

      Fluttertoast.showToast(
        msg: "Profile updated successfully.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      setState(() {
        _isEditingFirstName = false;
        _isEditingLastName = false;
        _isEditingDateOfBirth = false;
      });
    } catch (e) {
      print("Error saving profile: $e");
      Fluttertoast.showToast(
        msg: "Failed to update profile.",
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
          'Edit Your Patient Profile',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await _saveProfile();
              }
            },
          ),
        ],
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              enabled: _isEditingFirstName,
                              initialValue: _firstName,
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
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.pink[300]),
                            onPressed: () {
                              setState(() {
                                _isEditingFirstName = true;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              enabled: _isEditingLastName,
                              initialValue: _lastName,
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
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.pink[300]),
                            onPressed: () {
                              setState(() {
                                _isEditingLastName = true;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
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
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.pink[300]),
                            onPressed: () {
                              setState(() {
                                _isEditingDateOfBirth = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_isEditingFirstName || _isEditingLastName || _isEditingDateOfBirth) {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _saveProfile();
                      }
                    }
                  },
                  child: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[300],
                    padding: EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
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
