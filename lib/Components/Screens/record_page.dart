import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:medical_reminder/firestore_service.dart';

class RecordPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  RecordPage({required this.patientId, required this.patientName});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final records =
          await firestoreService.getPatientRecords(widget.patientId);
      setState(() {
        _records = records;
      });
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records for ${widget.patientName}'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePDF,
          ),
        ],
      ),
      body: _records.isEmpty
          ? Center(child: Text('No records found.'))
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return ListTile(
                  title: Text(record['medicationName']),
                  subtitle: Text(
                    'Time: ${record['time']} '
                    'Date: ${_formatDate(record['date'])} '
                    'Taken: ${record['taken'] == 'true' ? 'Yes' : 'No'}',
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    return DateFormat.yMMMd().format(date); // Format as MMM d, yyyy
  }

  void _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ListView.builder(
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final record = _records[index];
              return pw.Container(
                padding: pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Medication Name: ${record['medicationName']}'),
                    pw.Text('Time: ${record['time']}'),
                    pw.Text('Date: ${_formatDate(record['date'])}'),
                    pw.Text(
                        'Taken: ${record['taken'] == 'true' ? 'Yes' : 'No'}'),
                    pw.Divider(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
