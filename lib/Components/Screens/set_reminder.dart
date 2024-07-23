import 'package:flutter/material.dart';
import 'package:medical_reminder/models/patient.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/firestore_service.dart'; // Import necessary for Firestore

class SetReminderPage extends StatefulWidget {
  final Patient patient;
  final Medication medication;

  SetReminderPage({required this.patient, required this.medication});

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  List<MedicationTime> alarms = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    alarms = widget.medication.alarms;
  }

  void _addReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        alarms.add(MedicationTime(hour: time.hour, minute: time.minute));
      });
    }
  }

  Future<void> _saveReminders() async {
    try {
      // Convert the List<MedicationTime> to a List<Map<String, dynamic>>
      Map<String, dynamic> reminderData = {
        'alarms':
            alarms.map((medicationTime) => medicationTime.toJson()).toList(),
      };

      await _firestoreService.updateMedicationReminders(
        widget.patient.id,
        widget.medication.id,
        reminderData,
      );
      Navigator.pop(context, reminderData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminder'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return ListTile(
                  title: Text(
                      '${alarm.hour}:${alarm.minute.toString().padLeft(2, '0')}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        alarms.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addReminder,
            child: Text('Add Reminder'),
          ),
          ElevatedButton(
            onPressed: _saveReminders,
            child: Text('Save Reminders'),
          ),
        ],
      ),
    );
  }
}
