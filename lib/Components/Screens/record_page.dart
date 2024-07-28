import 'package:flutter/material.dart';
import 'package:medical_reminder/models/medication.dart';
import 'package:medical_reminder/models/verification_record.dart';
import 'package:medical_reminder/firestore_service.dart';
import 'package:intl/intl.dart';

class RecordPage extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String userId;

  RecordPage({
    required this.patientId,
    required this.patientName,
    required this.userId,
  });

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Medication> _medications = [];
  Map<String, List<VerificationRecord>> _verificationRecords = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch medications
      List<Medication> medications =
          await _firestoreService.getMedications(widget.patientId);
      setState(() {
        _medications = medications;
      });

      // Fetch verification records for each medication
      for (var medication in medications) {
        List<VerificationRecord> records = await _firestoreService
            .getVerificationRecords(widget.patientId, medication.id);
        setState(() {
          _verificationRecords[medication.id] = records;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading records: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Records for ${widget.patientName}'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              // Implement PDF generation here if needed
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medications:',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _medications.length,
                          itemBuilder: (context, index) {
                            final medication = _medications[index];
                            final verificationRecords =
                                _verificationRecords[medication.id] ?? [];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Medication: ${medication.medicationName}', // Updated property
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    Text(
                                        'Dosage: ${medication.prescription}'), // Updated field
                                    SizedBox(height: 8.0),
                                    if (medication.alarms != null &&
                                        medication.alarms!.isNotEmpty)
                                      Text(
                                        'Alarms:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                    if (medication.alarms != null &&
                                        medication.alarms!.isNotEmpty)
                                      ...medication.alarms!.map((alarm) {
                                        return Text(
                                          'Alarm: ${DateFormat.jm().format(alarm as DateTime)}', // Display alarm time
                                        );
                                      }).toList(),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Verification Records:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    ...verificationRecords.isNotEmpty
                                        ? verificationRecords.map((record) {
                                            return Text(
                                              'Taken: ${record.taken ? 'Yes' : 'No'}, Date: ${DateFormat.yMd().format(record.time)}', // Updated fields
                                            );
                                          }).toList()
                                        : [
                                            Text(
                                                'No verification records found')
                                          ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
