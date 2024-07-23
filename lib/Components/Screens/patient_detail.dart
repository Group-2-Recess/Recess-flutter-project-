import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/models/medication.dart';
import 'medication_detail.dart'; // Import your MedicationDetailPage

class PatientDetailPage extends StatefulWidget {
  final Patient patient;

  PatientDetailPage({required this.patient});

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _name;
  late String _location;
  late String _gender;
  late String _doctor;
  late List<Medication> _medications; // Updated to hold Medication objects
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _name = widget.patient.name ?? ''; // Use existing name if present
    _location =
        widget.patient.location ?? ''; // Use existing location if present
    _gender = widget.patient.gender ?? ''; // Use existing gender if present
    _doctor = widget.patient.doctor ?? ''; // Use existing doctor if present
    _medications = List.from(widget.patient.medications ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Enter Patient Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
                onSaved: (value) {
                  _location = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the gender';
                  }
                  return null;
                },
                onSaved: (value) {
                  _gender = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _doctor,
                decoration: InputDecoration(labelText: 'Doctor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the doctor';
                  }
                  return null;
                },
                onSaved: (value) {
                  _doctor = value!;
                },
              ),
              SizedBox(height: 32), // Ensure proper spacing before the button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Ensure the patient has an ID
                      String patientId = widget.patient.id.isNotEmpty
                          ? widget.patient.id
                          : _firestoreService.generateId();

                      Patient updatedPatient = Patient(
                        id: patientId,
                        name: _name,
                        location: _location,
                        gender: _gender,
                        doctor: _doctor,
                        medications: _medications, // Updated medications list
                        verificationRecords: widget.patient.verificationRecords,
                      );

                      // Save updated patient to Firestore using FirestoreService
                      _firestoreService.savePatient(updatedPatient).then((_) {
                        print('Patient updated in Firestore');
                        // Navigate to MedicationDetailPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicationDetailPage(patient: updatedPatient),
                          ),
                        );
                      }).catchError((error) {
                        print('Error updating patient in Firestore: $error');
                        // Handle error
                      });
                    }
                  },
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
