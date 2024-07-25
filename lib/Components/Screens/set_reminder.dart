import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';

class SetReminderPage extends StatefulWidget {
  final Medication medication;
  final String userId;
  final String patientId; // Patient ID

  SetReminderPage({
    required this.medication,
    required this.userId,
    required this.patientId,
  });

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  List<MedicationTime> alarms = [];

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

  void _saveReminders() {
    Navigator.pop(context, alarms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminder'),
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
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
