// user_details_form.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserDetailsForm extends StatefulWidget {
  final String userId;

  const UserDetailsForm({Key? key, required this.userId}) : super(key: key);

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

      final Map<String, dynamic> userDetailsData = {
        'illness': _illness,
        'medication': _medication,
        'prescription': _prescription,
        'reminder': _reminder,
        'timestamp': FieldValue.serverTimestamp(),
      };
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
        centerTitle: true,
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
                      color: Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: Offset(0.0, 5.0),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter your medication details:',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Illness',
                          prefixIcon: Icon(Icons.local_hospital),
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
                          prefixIcon: Icon(Icons.medical_services),
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
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Prescription',
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your prescription';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _prescription = value!;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Reminder',
                          prefixIcon: Icon(FontAwesomeIcons.solidClock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your reminder';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _reminder = value!;
                        },
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _saveUserDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save Details'),
                      ),
                    ],
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
