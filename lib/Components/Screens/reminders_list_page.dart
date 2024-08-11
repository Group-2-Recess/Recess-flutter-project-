import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemindersListPage extends StatelessWidget {
  final String userId;
  final String patientId;

  RemindersListPage({required this.userId, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text('Reminders List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('patients')
            .doc(patientId)
            .collection('reminders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No reminders found.'));
          }

          final reminders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminderData =
                  reminders[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text('Medication: ${reminderData['medicationName']}'),
                subtitle: Text('Time: ${reminderData['time']}'),
                trailing:
                    Text(reminderData['enabled'] ? 'Enabled' : 'Disabled'),
              );
            },
          );
        },
      ),
    );
  }
}
