import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'editprofile.dart'; // Ensure you import the EditProfilePage
import 'prescription_details_page.dart'; // Import PrescriptionDetailsPage
import 'new_set_reminder.dart'; // Import NewSetReminderPage
import 'package:medical_reminder/models/medication.dart';


class UserDetailsForm extends StatefulWidget {
  final String userId;

  const UserDetailsForm({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailsFormState createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD

  String _illness = '';
  String _medication = '';
  String _prescription = '';
=======
  final List<String> _commonIllnesses = [
    'Flu',
    'Cold',
    'Allergy',
    // ... other illnesses
  ];
  final List<String> _commonMedications = [
    'Aspirin',
    'Ibuprofen',
    'Acetaminophen',
    // ... other medications
  ];

  List<String> _illnesses = [''];
  List<Map<String, String>> _medications = [
    {'name': '', 'prescription': ''}
  ];
>>>>>>> 50897db (corrected patient info & added newsetreminderpage)
  String _reminder = '';

  Future<void> _saveUserDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Map<String, dynamic> userDetailsData = {
<<<<<<< HEAD
        'illness': _illness,
        'medication': _medication,
        'prescription': _prescription,
=======
        'illnesses': _illnesses,
        'medications': _medications
            .map((med) =>
                {'name': med['name'], 'prescription': med['prescription']})
            .toList(),
>>>>>>> 50897db (corrected patient info & added newsetreminderpage)
        'reminder': _reminder,
        'timestamp': FieldValue.serverTimestamp(),
      };

<<<<<<< HEAD
      // Save the userDetailsData to Firestore or any other database here
=======
      try {
        await FirebaseFirestore.instance
            .collection('user_details')
            .doc(widget.userId)
            .set(userDetailsData, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Details saved successfully')),
        );
      } catch (e) {
        print("Error saving user details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save details')),
        );
      }
>>>>>>> 50897db (corrected patient info & added newsetreminderpage)
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userId: widget.userId),
      ),
    );
  }

<<<<<<< HEAD
=======
  void _navigateToPrescriptionDetails(String medicationName, int index) async {
    final selectedMedication = _medications[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionDetailsPage(
          patientId: widget.userId,
          medication: Medication(
            id: 'med_$index',
            name: selectedMedication['name']!,
            diagnosis: '',
            prescription: selectedMedication['prescription']!,
            dosage: '',
            frequency: '',
            instructions: '',
            alarms: [], // Adjust this based on your model
            reminders: [], // Adjust this based on your model
            verificationStatus: false,
            verificationDate: DateTime.now(),
          ),
        ),
      ),
    );

    // Update the prescription details if any changes were made
    if (result != null) {
      setState(() {
        _medications[index]['prescription'] = result as String;
      });
    }
  }

  void _navigateToNewSetReminderPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewSetReminderPage(
          userId: widget.userId,
          caregiverId: 'yourCaregiverId', // Replace with the appropriate ID
          patientId: 'yourPatientId', // Replace with the appropriate ID
          medicationName: '', // Use the relevant medication name if needed
        ),
      ),
    );

    // Update the reminder field if a reminder was set
    if (result != null) {
      setState(() {
        _reminder = result.toString();
      });
    }
  }

  void _addIllnessField() {
    setState(() {
      _illnesses.add('');
    });
  }

  void _removeIllnessField(int index) {
    setState(() {
      _illnesses.removeAt(index);
    });
  }

  void _addMedicationField() {
    setState(() {
      _medications.add({'name': '', 'prescription': ''});
    });
  }

  void _removeMedicationField(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

>>>>>>> 50897db (corrected patient info & added newsetreminderpage)
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
        actions: [
          IconButton(
<<<<<<< HEAD
            icon: const Icon(Icons.settings), // Changed icon
=======
            icon: const Icon(Icons.settings),
>>>>>>> 50897db (corrected patient info & added newsetreminderpage)
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
<<<<<<< HEAD
              Color.fromARGB(255, 8, 228, 81)!,
              Color.fromARGB(255, 8, 228, 81)!,
              Color.fromARGB(255, 8, 228, 81)!,
              Color.fromARGB(255, 8, 228, 81)!,
              Color.fromARGB(255, 8, 228, 81)!,
=======
              Color.fromARGB(255, 8, 228, 81),
              // other colors
>>>>>>> 50897db (corrected patient info & added newsetreminderpage)
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
<<<<<<< HEAD
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
                          backgroundColor:
                              const Color.fromARGB(255, 30, 233, 84),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save Details'),
=======
                      // Illness Fields
                      ..._illnesses.asMap().entries.map((entry) {
                        int index = entry.key;
                        String value = entry.value;

                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: value.isEmpty ? null : value,
                                decoration: const InputDecoration(
                                  labelText: 'Illness',
                                  prefixIcon: Icon(Icons.local_hospital),
                                ),
                                items: _commonIllnesses.map((illness) {
                                  return DropdownMenuItem<String>(
                                    value: illness,
                                    child: Text(illness),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _illnesses[index] = newValue!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select an illness';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeIllnessField(index),
                            ),
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: _addIllnessField,
                        child: const Text('Add Illness'),
                      ),
                      const SizedBox(height: 16.0),
                      // Medication Fields
                      ..._medications.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> med = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: med['name']!.isEmpty
                                        ? null
                                        : med['name'],
                                    decoration: const InputDecoration(
                                      labelText: 'Medication',
                                      prefixIcon: Icon(Icons.medical_services),
                                    ),
                                    items: _commonMedications.map((medication) {
                                      return DropdownMenuItem<String>(
                                        value: medication,
                                        child: Text(medication),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _medications[index]['name'] = newValue!;
                                        // Clear prescription when medication changes
                                        _medications[index]['prescription'] =
                                            '';
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a medication';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeMedicationField(index),
                                ),
                              ],
                            ),
                            if (med['name']!.isNotEmpty) ...[
                              InkWell(
                                onTap: () => _navigateToPrescriptionDetails(
                                    med['name']!, index),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText:
                                        'Prescription for ${med['name']}',
                                    prefixIcon: Icon(Icons.receipt),
                                  ),
                                  onTap: () => _navigateToPrescriptionDetails(
                                      med['name']!, index),
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text: med['prescription'],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the prescription details';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16.0),
                            ]
                          ],
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: _addMedicationField,
                        child: const Text('Add Medication'),
                      ),
                      const SizedBox(height: 16.0),
                      // Reminder Field
                      GestureDetector(
                        onTap: _navigateToNewSetReminderPage,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Reminder',
                              prefixIcon: Icon(FontAwesomeIcons.bell),
                            ),
                            controller: TextEditingController(
                              text: _reminder,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please set a reminder';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveUserDetails,
                          child: const Text('Save'),
                        ),
>>>>>>> 50897db (corrected patient info & added newsetreminderpage)
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
