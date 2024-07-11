import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? profileImagePath; // Assuming profile picture path is stored

  const ProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.profileImagePath,
  });

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
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _dateOfBirth = widget.dateOfBirth;
    _profileImage = widget.profileImagePath != null ? File(widget.profileImagePath!) : null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

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

  void updateProfileData(String firstName, String lastName, DateTime? dateOfBirth, File? profileImage) {
    // Implement your logic to update profile data here (e.g., database call)
    print("Updating profile data: ");
    print("First Name: $firstName");
    print("Last Name: $lastName");
    print("Date of Birth: ${dateOfBirth?.toIso8601String()}");
    // Handle profile image update logic (if applicable)
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
                              ? 'Date of Birth: ${_dateOfBirth!.toLocal()}'.split(' ')[0]
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
                            updateProfileData(_firstName, _lastName, _dateOfBirth, _profileImage);
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
    home: ProfilePage(
      firstName: 'John',
      lastName: 'Doe',
      dateOfBirth: DateTime(1990, 5, 15),
      profileImagePath: null,
    ),
  ));
}
