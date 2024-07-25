import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:uuid/uuid.dart';

class EditPatientPage extends StatefulWidget {
  final Patient patient;
  final ValueChanged<Patient> onSave;
  final String userId; // Add this line

  EditPatientPage({
    required this.patient,
    required this.onSave,
    required this.userId, // Update constructor
  });

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _genderController;
  late TextEditingController _doctorController;
  List<Medication> _medications = [];

  final FirestoreService _firebaseService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _locationController = TextEditingController(text: widget.patient.location);
    _genderController = TextEditingController(text: widget.patient.gender);
    _doctorController = TextEditingController(text: widget.patient.doctor);
    _medications = List.from(widget.patient.medications);
  }

  void _addNewMedication() {
    setState(() {
      _medications.add(Medication(
        id: Uuid().v4(),
        sicknessName: '',
        medicationName: '',
        prescription: '',
        alarms: [],
        isVerified: false,
        verificationDate: DateTime.now(),
        userId: widget.userId, // Add userId here
      ));
    });
  }

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    final updatedPatient = Patient(
      id: widget.patient.id,
      name: _nameController.text,
      location: _locationController.text,
      gender: _genderController.text,
      doctor: _doctorController.text,
      medications: _medications,
      verificationRecords: [], // Adjust as needed
      userId: widget.userId, // Add userId here
    );

    try {
      await _firebaseService.updatePatient(updatedPatient);
      widget.onSave(updatedPatient);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Patient'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Patient Name'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: _doctorController,
                decoration: InputDecoration(labelText: 'Doctor'),
              ),
              SizedBox(height: 20),
              Text(
                'Medications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: TextEditingController(
                                text: _medications[index].sicknessName),
                            decoration:
                                InputDecoration(labelText: 'Sickness Name'),
                            onChanged: (value) {
                              setState(() {
                                _medications[index].sicknessName = value;
                              });
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: _medications[index].medicationName),
                            decoration:
                                InputDecoration(labelText: 'Medication Name'),
                            onChanged: (value) {
                              setState(() {
                                _medications[index].medicationName = value;
                              });
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: _medications[index].prescription),
                            decoration:
                                InputDecoration(labelText: 'Prescription'),
                            onChanged: (value) {
                              setState(() {
                                _medications[index].prescription = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Alarms',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _medications[index].alarms.length,
                            itemBuilder: (context, alarmIndex) {
                              return ListTile(
                                title: Text(
                                  'Alarm: ${_medications[index].alarms[alarmIndex].format(context)}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _medications[index]
                                          .alarms
                                          .removeAt(alarmIndex);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _addAlarm(index);
                            },
                            child: Text('Add Alarm'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _deleteMedication(index);
                            },
                            child: Text('Delete Medication'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addNewMedication,
                child: Text('Add New Medication'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addAlarm(int medicationIndex) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _medications[medicationIndex].alarms.add(
              MedicationTime(
                hour: picked.hour,
                minute: picked.minute,
              ),
            );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _genderController.dispose();
    _doctorController.dispose();
    super.dispose();
  }
}
