import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';

class SetReminderPage extends StatefulWidget {
  final Patient patient;
  final Medication medication;

  SetReminderPage({required this.patient, required this.medication});

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  List<TimeOfDay> alarms = [];

  void _addAlarm() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime != null) {
        setState(() {
          alarms.add(pickedTime);
        });
      }
    });
  }

  void _saveReminders() {
    setState(() {
      widget.medication.alarms = alarms;
    });

    // Update the medications list in the patient object
    for (int i = 0; i < widget.patient.medications.length; i++) {
      if (widget.patient.medications[i].medicationName ==
              widget.medication.medicationName &&
          widget.patient.medications[i].sicknessName ==
              widget.medication.sicknessName) {
        widget.patient.medications[i] = widget.medication;
      }
    }

    Navigator.pop(context, widget.patient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminders'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Add Alarm',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addAlarm,
              icon: Icon(Icons.alarm_add),
              label: Text('Add Alarm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        alarms[index].format(context),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            alarms.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveReminders,
              icon: Icon(Icons.save),
              label: Text('Save Reminders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
