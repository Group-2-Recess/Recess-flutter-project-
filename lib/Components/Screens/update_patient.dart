import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';

class UpdatePatientPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final Patient patient;

  UpdatePatientPage({
    required this.userId,
    required this.caregiverId,
    required this.patient,
  });

  @override
  _UpdatePatientPageState createState() => _UpdatePatientPageState();
}

class _UpdatePatientPageState extends State<UpdatePatientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  String? _selectedGender;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.patient.name;
    _locationController.text = widget.patient.location;
    _doctorController.text = widget.patient.doctor;
    _selectedGender = widget.patient.gender; // Initialize with existing gender
  }

  Future<void> _updatePatient() async {
    if (_formKey.currentState!.validate()) {
      final updatedPatient = Patient(
        id: widget.patient.id,
        userId: widget.userId, // Pass userId
        profileId: widget
            .patient.profileId, // Pass profileId from the existing patient
        caregiverId: widget.caregiverId, // Pass caregiverId
        name: _nameController.text,
        location: _locationController.text,
        gender: _selectedGender!,
        doctor: _doctorController.text,
        medications: widget.patient.medications,
        verificationRecords:
            widget.patient.verificationRecords, // Pass verificationRecords
      );

      try {
        await FirestoreService().updatePatient(
          widget.userId,
          widget.caregiverId,
          updatedPatient,
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update patient: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Patient'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: Text('Select Gender'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                items: _genders.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a gender' : null,
              ),
              TextFormField(
                controller: _doctorController,
                decoration: InputDecoration(labelText: 'Doctor'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a doctor\'s name' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePatient,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
