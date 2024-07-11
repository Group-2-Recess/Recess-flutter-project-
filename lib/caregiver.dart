import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_reminder/utils.dart'; 
import 'package:medical_reminder/resources/add.dart'; 

class CaregiverPage extends StatefulWidget {
  const CaregiverPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CaregiverPageState createState() => _CaregiverPageState();
}

class _CaregiverPageState extends State<CaregiverPage> {
  final formKey = GlobalKey<FormState>();
  String names = "";
  String organisation = "";
  String location = "";
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
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    String names = nameController.text;
    String organisationName = organisationController.text;
    String location = locationController.text;

    String resp;
    try {
      resp = await StoreData().saveData(
        names: names,
        organisationName: organisationName,
        location: location,
        file: _image!,
      );
    } catch (e) {
      resp = e.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resp)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Page'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://c8.alamy.com/comp/D91YB6/beautiful-medical-nurse-portrait-in-office-D91YB6.jpg',
            fit: BoxFit.fill,
          ),
          Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 36),
                const Text(
                  'Create your nurse/ Caregiver profile here',
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
                            icon: const Icon(Icons.add_a_photo),
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
        decoration: const InputDecoration(
          labelText: "FULL NAMES",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.pink,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
        onSaved: (value) => names = value ?? '',
      );

  Widget buildOrganisationName() => TextFormField(
        controller: organisationController,
        decoration: const InputDecoration(
          labelText: "ORGANISATION NAME",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.pink,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your organization';
          }
          return null;
        },
        onSaved: (value) => organisation = value ?? '',
      );

  Widget buildLocation() => TextFormField(
        controller: locationController,
        decoration: const InputDecoration(
          labelText: "LOCATION",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.pink,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your location';
          }
          return null;
        },
        onSaved: (value) => location = value ?? '',
      );
}