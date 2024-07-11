import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';

class EditPatientPage extends StatefulWidget {
  final Patient patient;
  final ValueChanged<Patient> onSave;

  EditPatientPage({required this.patient, required this.onSave});

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _genderController;
  late TextEditingController _doctorController;
  List<Medication> _medications = [];

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
        sicknessName: '',
        medicationName: '',
        prescription: '',
        alarms: [],
      ));
    });
  }

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
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
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  _medications[index].alarms.add(time);
                                });
                              }
                            },
                            child: Text('Add Alarm'),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _deleteMedication(index),
                            child: Text('Delete Medication'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 224, 100, 91),
                            ),
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
                child: Text('Add Medication'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final updatedPatient = Patient(
                    id: widget.patient.id,
                    name: _nameController.text,
                    location: _locationController.text,
                    gender: _genderController.text,
                    doctor: _doctorController.text,
                    medications: _medications,
                  );
                  widget.onSave(updatedPatient);
                  Navigator.pop(context);
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
