import 'package:flutter/material.dart';
import 'package:medical_reminder/models/reminder.dart';
import 'package:uuid/uuid.dart';

class SetReminderPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final String patientId;
  final String medicationName;

  const SetReminderPage({
    super.key,
    required this.userId,
    required this.caregiverId,
    required this.patientId,
    required this.medicationName,
  });

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedSound = 'default';
  List<String> _sounds = ['default', 'sound1', 'sound2', 'sound3'];
  int _snoozeDuration = 5; // Automatically set snooze duration to 5 minutes
  List<bool> _selectedDays =
      List.filled(7, false); // List to hold day selections

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Reminder'),
        backgroundColor: Colors.green, // Green color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildListTile(
              title: 'Reminder Time',
              subtitle: _selectedTime.format(context),
              icon: Icons.access_time,
              onPressed: _selectTime,
            ),
            const SizedBox(height: 20),
            _buildListTile(
              title: 'Select Sound',
              subtitle: _selectedSound,
              icon: Icons.music_note,
              onPressed: _selectSound,
            ),
            const SizedBox(height: 20),
            _buildListTile(
              title: 'Snooze Duration',
              subtitle: '$_snoozeDuration minutes',
              icon: Icons.timer,
              onPressed: _selectSnoozeDuration,
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Days',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            ToggleButtons(
              isSelected: _selectedDays,
              selectedColor: Colors.white,
              color: Colors.black,
              fillColor: Colors.green,
              borderColor: Colors.green,
              borderWidth: 2.0,
              selectedBorderColor: Colors.green,
              borderRadius: BorderRadius.circular(8),
              children: _buildDayButtons(),
              onPressed: (int index) {
                setState(() {
                  _selectedDays[index] = !_selectedDays[index];
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Green color for the button
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: IconButton(
        icon: Icon(icon, color: Colors.green), // Green color for the icons
        onPressed: onPressed,
      ),
    );
  }

  List<Widget> _buildDayButtons() {
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days
        .map((day) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                day,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ))
        .toList();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _selectSound() async {
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Sound'),
          children: _sounds.map((sound) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, sound);
              },
              child: Text(sound),
            );
          }).toList(),
        );
      },
    );
    if (picked != null && picked != _selectedSound) {
      setState(() {
        _selectedSound = picked;
      });
    }
  }

  void _selectSnoozeDuration() async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Snooze Duration'),
          children: List.generate(60, (index) => index + 1).map((duration) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, duration);
              },
              child: Text('$duration minutes'),
            );
          }).toList(),
        );
      },
    );
    if (picked != null && picked != _snoozeDuration) {
      setState(() {
        _snoozeDuration = picked;
      });
    }
  }

  void _saveReminder() {
    if (_selectedDays.contains(true)) {
      final String id = Uuid().v4(); // Generate a unique ID for the reminder
      final Reminder reminder = Reminder(
        id: id, // Set the generated ID
        time: _selectedTime.format(context),
        days: _selectedDays,
        medicationName: widget.medicationName,
        sound: _selectedSound,
        snoozeDuration: _snoozeDuration,
      );
      Navigator.pop(context, reminder);
    } else {
      // Show error message if no day is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day for the reminder.'),
        ),
      );
    }
  }
}
