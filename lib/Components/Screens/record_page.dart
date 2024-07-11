import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:medical_reminder/database_helper.dart';

class RecordPage extends StatefulWidget {
  final String patientName;

  RecordPage({required this.patientName});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  void _fetchRecords() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final fetchedRecords =
          await dbHelper.queryRecordsByPatient(widget.patientName);
      setState(() {
        records = fetchedRecords;
      });
    } catch (e) {
      print("Error fetching records: $e");
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Records for ${widget.patientName}',
                  style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Medication Name', 'Time', 'Date', 'Taken'],
                data: records.map((record) {
                  return [
                    record['medicationName'],
                    record['time'],
                    record['date'],
                    record['taken'] == 1 ? 'Yes' : 'No',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print("Error generating PDF: $e");
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
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: records.isEmpty
            ? Center(
                child: Text(
                  'No records found for ${widget.patientName}.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Icon(
                        Icons.medical_services,
                        color: Colors.teal,
                      ),
                      title: Text(
                        record['medicationName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            'Time: ${record['time']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Date: ${record['date']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Taken: ${record['taken'] == 1 ? 'Yes' : 'No'}',
                            style: TextStyle(
                                fontSize: 16,
                                color: record['taken'] == 1
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
