import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_reminder/utils.dart';
import 'package:medical_reminder/firestore_service.dart'; // Import FirestoreService
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medical_reminder/Components/Screens/home_page.dart';

class EditCaregiverProfilePage extends StatefulWidget {
  final String profileId; // Pass the profile ID

  const EditCaregiverProfilePage({Key? key, required this.profileId}) : super(key: key);

  @override
  _EditCaregiverProfilePageState createState() => _EditCaregiverProfilePageState();
}

class _EditCaregiverProfilePageState extends State<EditCaregiverProfilePage> {
  final formKey = GlobalKey<FormState>();
  Uint8List? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController organisationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  bool isNameEditable = false;
  bool isOrganizationEditable = false;
  bool isLocationEditable = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in')),
        );
        return;
      }

      final firestoreService = FirestoreService();
      final profile = await firestoreService.getCaregiverProfileById(user.uid, widget.profileId);

      setState(() {
        nameController.text = profile['name'];
        organisationController.text = profile['organization'];
        locationController.text = profile['location'];
        if (profile['image'] != null) {
          _image = Uint8List.fromList(profile['image'].cast<int>());
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Future<void> selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  Future<void> updateProfile() async {
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
        'organization': organisationController.text,
        'location': locationController.text,
        'image': _image != null ? _image!.toList() : null,
      };

      final firestoreService = FirestoreService();
      await firestoreService.updateCaregiverProfile(userId, widget.profileId, caregiverData);

      // Navigate back to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(), // No parameters
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Caregiver Profile'),
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
                  'Edit your nurse/caregiver profile here',
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
                            icon: const Icon(Icons.add_a_photo, color: Colors.white),
                            onPressed: selectImage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                buildEditableField(
                  controller: nameController,
                  labelText: "FULL NAMES",
                  isEditable: isNameEditable,
                  onEditPressed: () {
                    setState(() {
                      isNameEditable = !isNameEditable;
                    });
                  },
                ),
                const SizedBox(height: 36),
                buildEditableField(
                  controller: organisationController,
                  labelText: "ORGANIZATION NAME",
                  isEditable: isOrganizationEditable,
                  onEditPressed: () {
                    setState(() {
                      isOrganizationEditable = !isOrganizationEditable;
                    });
                  },
                ),
                const SizedBox(height: 36),
                buildEditableField(
                  controller: locationController,
                  labelText: "LOCATION",
                  isEditable: isLocationEditable,
                  onEditPressed: () {
                    setState(() {
                      isLocationEditable = !isLocationEditable;
                    });
                  },
                ),
                const SizedBox(height: 36),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: updateProfile,
                    child: const Text('Update Profile'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditableField({
    required TextEditingController controller,
    required String labelText,
    required bool isEditable,
    required VoidCallback onEditPressed,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.green),
              enabled: isEditable,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $labelText.toLowerCase()';
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: Icon(isEditable ? Icons.check : Icons.edit),
          color: Colors.green,
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}
