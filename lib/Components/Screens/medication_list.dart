import 'package:flutter/material.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:medical_reminder/models/medication.dart';
import 'medication_detail.dart';

class MedicationListPage extends StatefulWidget {
  final String userId;
  final String caregiverId;
  final String patientId;

  const MedicationListPage({
    super.key,
    required this.userId,
    required this.caregiverId,
    required this.patientId,
  });

  @override
  _MedicationListPageState createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Medication> medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    try {
      final fetchedMedications = await _firestoreService.getMedications(
          widget.caregiverId, widget.patientId);
      setState(() {
        medications = fetchedMedications;
      });
    } catch (e) {
      // Handle error
      print('Error fetching medications: $e');
    }
  }

  void _navigateToMedicationDetail(Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailPage(
          userId: widget.userId,
          caregiverId: widget.caregiverId,
          patientId: widget.patientId,
          medication: medication,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: ListView.builder(
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return ListTile(
            title: Text(medication.name),
            subtitle: Text(medication.prescription),
            onTap: () => _navigateToMedicationDetail(medication),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add medication page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
