import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_reminder/models/reminder.dart';
import 'reminders_list_page.dart'; // Import the RemindersListPage

class NewSetReminderPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final String patientId;
  final String medicationName;

  NewSetReminderPage({
    Key? key,
    required this.userId,
    required this.caregiverId,
    required this.patientId,
    required this.medicationName,
  }) : super(key: key);

  @override
  _NewSetReminderPageState createState() => _NewSetReminderPageState();
}

class _NewSetReminderPageState extends State<NewSetReminderPage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedSound = 'Default';
  bool _vibration = true;
  int _snoozeDuration = 5;
  List<bool> _selectedDays = List.generate(7, (_) => false);
  bool _enabled = true;

  void _saveReminder() {
    final reminder = Reminder(
      id: UniqueKey().toString(),
      time: _selectedTime.format(context),
      days: _selectedDays,
      enabled: _enabled,
      sound: _selectedSound,
      vibration: _vibration,
      snoozeDuration: _snoozeDuration * 60, // Convert minutes to seconds
      medicationName: widget.medicationName,
    );

    // Save the reminder to Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('patients')
        .doc(widget.patientId)
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toJson())
        .then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RemindersListPage(
            userId: widget.userId,
            patientId: widget.patientId,
          ),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save reminder: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text('New Set Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimePicker(),
            const SizedBox(height: 16),
            _buildSoundPicker(),
            const SizedBox(height: 16),
            _buildSnoozeDurationPicker(),
            const SizedBox(height: 16),
            _buildVibrationSwitch(),
            const SizedBox(height: 16),
            _buildDaysPicker(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: _saveReminder,
                child: const Text(
                  'Save Reminder',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Time:', style: TextStyle(fontSize: 16)),
        TextButton(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (picked != null && picked != _selectedTime) {
              setState(() {
                _selectedTime = picked;
              });
            }
          },
          child: Text(_selectedTime.format(context),
              style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildSoundPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Sound:', style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: _selectedSound,
          onChanged: (String? newValue) {
            setState(() {
              _selectedSound = newValue!;
            });
          },
          items: <String>['Default', 'Alarm', 'Beep']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSnoozeDurationPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Snooze Duration:', style: TextStyle(fontSize: 16)),
        DropdownButton<int>(
          value: _snoozeDuration,
          onChanged: (int? newValue) {
            setState(() {
              _snoozeDuration = newValue!;
            });
          },
          items: <int>[5, 10, 15, 20].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value minutes'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVibrationSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Vibration:', style: TextStyle(fontSize: 16)),
        Switch(
          value: _vibration,
          onChanged: (bool value) {
            setState(() {
              _vibration = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDaysPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeat Days:', style: TextStyle(fontSize: 16)),
        Wrap(
          children: List.generate(7, (index) {
            final day =
                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
            return ChoiceChip(
              label: Text(day),
              selected: _selectedDays[index],
              onSelected: (bool selected) {
                setState(() {
                  _selectedDays[index] = selected;
                });
              },
            );
          }),
        ),
      ],
    );
  }
}
