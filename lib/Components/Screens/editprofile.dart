import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userId; // Pass user ID to fetch their data

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  DateTime? _dateOfBirth;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userRef = FirebaseFirestore.instance
        .collection('patient_profiles')
        .doc(widget.userId);
    final doc = await userRef.get();

    if (doc.exists) {
      setState(() {
        _firstName = doc['firstName'] ?? '';
        _lastName = doc['lastName'] ?? '';
        _dateOfBirth = (doc['dateOfBirth'] as Timestamp).toDate();
        _profileImage = doc['profileImagePath'] != null
            ? File(doc['profileImagePath'])
            : null;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
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

  Future<void> updateProfileData() async {
    final userRef = FirebaseFirestore.instance
        .collection('patient_profiles')
        .doc(widget.userId);

    await userRef.update({
      'firstName': _firstName,
      'lastName': _lastName,
      'dateOfBirth': Timestamp.fromDate(_dateOfBirth!),
      // Handle profile image path update logic if applicable
      // 'profileImagePath': _profileImage?.path,
    });

    // Optionally show a confirmation message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0.0,
        title: Text(
          'Edit Your Patient Profile',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
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
                CircleAvatar(
                  radius: 80,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : AssetImage('assets/blackman.jpg') as ImageProvider,
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Change Profile Picture'),
                ),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _firstName,
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
                      SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: _lastName,
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
                      SizedBox(height: 10.0),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: _dateOfBirth != null
                              ? 'Date of Birth: ${_dateOfBirth!.toLocal()}'
                                  .split(' ')[0]
                              : 'Select Date of Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            updateProfileData();
                          }
                        },
                        child: Text('Save Changes'),
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

void main() {
  runApp(MaterialApp(
    home: ProfilePage(userId: 'USER_ID'), // Pass the user ID here
  ));
}
