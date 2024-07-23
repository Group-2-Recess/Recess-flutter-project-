import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart'; // Adjust path as per your project structure

class UserDetailsForm extends StatefulWidget {
  const UserDetailsForm({Key? key}) : super(key: key);

  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  String _illness = '';
  String _medication = '';
  String _prescription = '';
  String _reminder = '';

  Future<void> _saveUserDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prepare user details data
      final Map<String, dynamic> userDetailsData = {
        'illness': _illness,
        'medication': _medication,
        'prescription': _prescription,
        'reminder': _reminder,
        'timestamp': FieldValue.serverTimestamp(), // Optional: add a timestamp
      };

      try {
        // Save user details data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .add(userDetailsData);

        // Show confirmation and navigate to the Home page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User details saved successfully!')),
        );

        // Navigate to the HomePage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false, // Remove all previous routes
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving user details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MEDICATION FORM',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center align the title
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.pink[100]!,
              Colors.pink[200]!,
              Colors.pink[300]!,
              Colors.pink[400]!,
              Colors.pink[500]!,
            ],
            center: Alignment(0.0, 0.0),
            radius: 1.5,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink[300]!,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Illness',
                            prefixIcon: Icon(FontAwesomeIcons.virus),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your illness';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _illness = value!;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Medication',
                            prefixIcon: Icon(FontAwesomeIcons.capsules),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your medication';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _medication = value!;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/prescription-details', // Adjust as needed
                            );
                          },
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Prescription/Medicine(s)',
                              prefixIcon: Icon(FontAwesomeIcons.pills),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your prescription/medicine(s)';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _prescription = value!;
                            },
                            enabled: false, // Make it non-editable
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/reminder', // Adjust as needed
                            );
                          },
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Reminder',
                              prefixIcon: Icon(FontAwesomeIcons.bell),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a reminder for taking medication';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _reminder = value!;
                            },
                            enabled: false, // Make it non-editable
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: _saveUserDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.pink[500], // Updated to backgroundColor
                            foregroundColor:
                                Colors.white, // Updated to foregroundColor
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
