// CaregiverPage.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_reminder/resources/add.dart';
import 'package:medical_reminder/utils.dart';
import 'package:medical_reminder/Components/Screens/home_page.dart';

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

  selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  void saveProfile() async {
    if (!formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    if (_image == null) {
      print("Image is null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    String names = nameController.text;
    String organisationName = organisationController.text;
    String location = locationController.text;

    try {
      print("Saving data...");

      String resp = await StoreData().saveData(
        names: names,
        organisationName: organisationName,
        location: location,
        file: _image!,
      );

      if (resp == 'Success') {
        print("Data saved successfully");
        // Replace 'userId' with the actual user ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(userId: ''), // Pass the actual userId here
          ),
        );
      } else {
        print("Data saving failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp)),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0.0,
        title: const Text(
          'Caregiver Profile',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _image != null ? MemoryImage(_image!) : null,
                    child: _image == null
                        ? IconButton(
                            icon: Icon(Icons.camera_alt, size: 50),
                            onPressed: selectImage,
                          )
                        : null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: organisationController,
                    decoration: InputDecoration(
                      labelText: 'Organisation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your organisation name'
                        : null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your location' : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveProfile,
                    child: Text('Save Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
