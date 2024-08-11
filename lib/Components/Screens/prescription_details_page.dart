import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_reminder/models/medication.dart'; // Import your Medication model

class PrescriptionDetailsPage extends StatefulWidget {
  final String patientId; // Pass the patientId to the page
  final Medication? medication; // Optionally pass a Medication object

  const PrescriptionDetailsPage({
    Key? key,
    required this.patientId,
    this.medication,
  }) : super(key: key);

  @override
  _PrescriptionDetailsPageState createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late String _prescriptionDetails;
  late bool _beforeBreakfast;
  late bool _afterBreakfast;
  late bool _beforeLunch;
  late bool _afterLunch;
  late bool _evening;

  @override
  void initState() {
    super.initState();

    // Initialize fields with medication data if available
    if (widget.medication != null) {
      _prescriptionDetails = widget.medication!.prescription;
      _beforeBreakfast = widget.medication!.alarms.contains('Before Breakfast');
      _afterBreakfast = widget.medication!.alarms.contains('After Breakfast');
      _beforeLunch = widget.medication!.alarms.contains('Before Lunch');
      _afterLunch = widget.medication!.alarms.contains('After Lunch');
      _evening = widget.medication!.alarms.contains('Evening');
    } else {
      _prescriptionDetails = '';
      _beforeBreakfast = false;
      _afterBreakfast = false;
      _beforeLunch = false;
      _afterLunch = false;
      _evening = false;
    }
  }

  Future<void> _savePrescription() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prepare prescription data
      final Map<String, dynamic> prescriptionData = {
        'details': _prescriptionDetails,
        'beforeBreakfast': _beforeBreakfast,
        'afterBreakfast': _afterBreakfast,
        'beforeLunch': _beforeLunch,
        'afterLunch': _afterLunch,
        'evening': _evening,

        //'alarms': {
          //'beforeBreakfast': _beforeBreakfast,
          //'afterBreakfast': _afterBreakfast,
          //'beforeLunch': _beforeLunch,
          //'afterLunch': _afterLunch,
          //'evening': _evening,
        //},
       // (corrected patient info & added newsetreminderpage)
        'timestamp': FieldValue.serverTimestamp(), // Optional: add a timestamp
      };

      try {
        // Save prescription data to Firestore
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.patientId)
            .collection('prescriptions')
            .add(prescriptionData);

        // Show confirmation and return to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription saved successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving prescription: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _prescriptionDetails,
                decoration: const InputDecoration(
                  labelText: 'Prescription Details',
                  prefixIcon: Icon(FontAwesomeIcons.pills),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter prescription details';
                  }
                  return null;
                },
                onSaved: (value) {
                  _prescriptionDetails = value ?? '';
                },
              ),
              CheckboxListTile(
                title: const Text('Before Breakfast'),
                value: _beforeBreakfast,
                onChanged: (bool? value) {
                  setState(() {
                    _beforeBreakfast = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('After Breakfast'),
                value: _afterBreakfast,
                onChanged: (bool? value) {
                  setState(() {
                    _afterBreakfast = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Before Lunch'),
                value: _beforeLunch,
                onChanged: (bool? value) {
                  setState(() {
                    _beforeLunch = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('After Lunch'),
                value: _afterLunch,
                onChanged: (bool? value) {
                  setState(() {
                    _afterLunch = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Evening'),
                value: _evening,
                onChanged: (bool? value) {
                  setState(() {
                    _evening = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePrescription,
                child: const Text('Save Prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
