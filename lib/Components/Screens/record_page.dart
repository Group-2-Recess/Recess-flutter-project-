import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical_reminder/models/verification.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class RecordPage extends StatefulWidget {
  final String patientId;

  RecordPage({Key? key, required this.patientId}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<Verification> _verifications = [];

  @override
  void initState() {
    super.initState();
    _fetchLocalVerifications();
  }

  Future<void> _fetchLocalVerifications() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    List<Verification> verifications = [];

    for (String key in keys) {
      if (key.startsWith('verification_${widget.patientId}_')) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          final jsonData = json.decode(jsonString);
          final verification = Verification.fromJson(jsonData);
          verifications.add(verification);
        }
      }
    }

    setState(() {
      _verifications = verifications;
    });
  }

  Future<String> _savePdfToFile(List<Verification> verifications) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text('Verification Records',
                  style: pw.TextStyle(fontSize: 24, color: PdfColors.green)),
              pw.SizedBox(height: 20),
              ...verifications.map((verification) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text('Medication ID: ${verification.medicationId}',
                        style:
                            pw.TextStyle(fontSize: 18, color: PdfColors.black)),
                    pw.Text('Statement: ${verification.verificationStatement}',
                        style:
                            pw.TextStyle(fontSize: 16, color: PdfColors.black)),
                    pw.Text('Date: ${verification.timestamp}',
                        style:
                            pw.TextStyle(fontSize: 16, color: PdfColors.black)),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    final outputFile = await getLocalPath();
    final file = File(outputFile);
    await file.writeAsBytes(await pdf.save());

    print('PDF saved to $outputFile');
    return outputFile;
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/verification_records.pdf';
  }

  Future<void> _generateAndPrintPdf() async {
    if (_verifications.isNotEmpty) {
      try {
        final path = await _savePdfToFile(_verifications);
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => File(path).readAsBytes(),
        );
        print('Printing initiated');
      } catch (e) {
        print('Error during PDF generation or printing: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating or printing PDF')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No records to print')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Records'),
        backgroundColor: Colors.green[800], // Dark green color for AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generateAndPrintPdf,
            color: Colors.white,
          ),
        ],
      ),
      body: _verifications.isEmpty
          ? Center(
              child: Text('No verification records available',
                  style: TextStyle(fontSize: 18, color: Colors.green[700])))
          : ListView.builder(
              itemCount: _verifications.length,
              itemBuilder: (context, index) {
                final verification = _verifications[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Colors.green[50], // Light green color for the Card
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      verification.verificationStatement,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800], // Dark green color for title
                      ),
                    ),
                    subtitle: Text(
                      'Date: ${verification.timestamp.toLocal()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
