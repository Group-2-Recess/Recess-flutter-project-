import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'medication_detail.dart'; // Import MedicationDetailPage

class PatientDetailPage extends StatefulWidget {
  final Patient patient;
  final String profileId; // CaregiverProfile ID

  PatientDetailPage({required this.patient, required this.profileId});

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  String _selectedGender = 'Male'; // Initialize with 'Male'

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _locationController = TextEditingController(text: widget.patient.location);
    _selectedGender =
        widget.patient.gender ?? 'Male'; // Default to 'Male' if null
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _updateGender(String? newGender) {
    setState(() {
      _selectedGender = newGender ?? 'Male'; // Default to 'Male' if null
    });
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedPatient = widget.patient.copyWith(
        name: _nameController.text,
        location: _locationController.text,
        gender: _selectedGender,
      );

      try {
        await FirestoreService().updatePatient(
          'userUID', // Replace with the actual user UID
          widget.profileId,
          updatedPatient,
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Patient details updated')));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicationDetailPage(
              patientId: updatedPatient.id,
              userId: 'userUID', // Replace with the actual user UID
              caregiverId: widget.profileId,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update patient: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> genderOptions = ['Male', 'Female', 'Other'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Patient Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: genderOptions.contains(_selectedGender)
                    ? _selectedGender
                    : genderOptions[0],
                items: genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Gender'),
                onChanged: (String? newGender) {
                  _updateGender(newGender);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePatient,
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
