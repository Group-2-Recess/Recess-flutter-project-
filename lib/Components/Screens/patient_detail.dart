import 'package:flutter/material.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/models/patient.dart';
import 'medication_detail.dart'; // Import MedicationDetailPage

class PatientDetailPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final Patient? patient; // Allow null for adding new patients

  const PatientDetailPage({
    super.key,
    required this.userId,
    required this.caregiverId,
    this.patient,
  });

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _doctorController;
  String? _selectedGender; // Variable to hold the selected gender

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient?.name);
    _addressController = TextEditingController(text: widget.patient?.address);
    _doctorController = TextEditingController(text: widget.patient?.doctor);
    _selectedGender = widget.patient?.gender; // Initialize selected gender
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final patient = Patient(
        id: widget.patient?.id ?? '',
        name: _nameController.text,
        address: _addressController.text,
        gender: _selectedGender ?? '', // Use selected gender
        doctor: _doctorController.text,
      );

      if (widget.patient == null) {
        await _firestoreService.addPatient(widget.caregiverId, patient);
      } else {
        await _firestoreService.updatePatient(
            widget.caregiverId, widget.patient!.id, patient);
      }

      // Navigate to MedicationDetailPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationDetailPage(
            userId: widget.userId,
            caregiverId: widget.caregiverId,
            patientId: patient.id, // Pass the patient's ID
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
        backgroundColor: Colors.green[800], // Dark green color for AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'Doctor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a doctor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
