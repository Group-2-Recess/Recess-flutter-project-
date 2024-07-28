import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/firestore_service.dart';

class SetReminderPage extends StatefulWidget {
  final String userId;
  final String patientId;
  final String caregiverId;
  final Medication medication;

  SetReminderPage({
    required this.userId,
    required this.patientId,
    required this.caregiverId,
    required this.medication,
  });

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  final TextEditingController _reminderTimeController = TextEditingController();

  Future<void> _saveReminder() async {
    final reminderTime = _reminderTimeController.text;
    if (reminderTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a reminder time')));
      return;
    }

    try {
      final reminderData = {
        'reminderTime': reminderTime,
        // Add additional fields as needed
      };

      await FirestoreService().addReminder(
          widget.userId, widget.caregiverId, widget.patientId, reminderData);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Reminder set successfully')));
      Navigator.pop(context); // Navigate back after saving
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to set reminder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminder'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Set Reminder for ${widget.medication.medicationName}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _reminderTimeController,
              decoration:
                  InputDecoration(labelText: 'Reminder Time (e.g., 8:00 AM)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReminder,
              child: Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
