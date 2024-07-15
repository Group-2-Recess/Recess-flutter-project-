import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  const PrescriptionDetailsPage({Key? key}) : super(key: key);

  @override
  _PrescriptionDetailsPageState createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  String _prescriptionDetails = '';
  bool _beforeBreakfast = false;
  bool _afterBreakfast = false;
  bool _beforeLunch = false;
  bool _afterLunch = false;
  bool _evening = false;

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
                  _prescriptionDetails = value!;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('When to take the medicine:'),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _beforeBreakfast,
                    onChanged: (bool? value) {
                      setState(() {
                        _beforeBreakfast = value!;
                      });
                    },
                  ),
                  const Text('Before Breakfast'),
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _afterBreakfast,
                    onChanged: (bool? value) {
                      setState(() {
                        _afterBreakfast = value!;
                      });
                    },
                  ),
                  const Text('After Breakfast'),
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _beforeLunch,
                    onChanged: (bool? value) {
                      setState(() {
                        _beforeLunch = value!;
                      });
                    },
                  ),
                  const Text('Before Lunch'),
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _afterLunch,
                    onChanged: (bool? value) {
                      setState(() {
                        _afterLunch = value!;
                      });
                    },
                  ),
                  const Text('After Lunch'),
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _evening,
                    onChanged: (bool? value) {
                      setState(() {
                        _evening = value!;
                      });
                    },
                  ),
                  const Text('Evening'),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Process the input data
                    print('Prescription Details: $_prescriptionDetails');
                    print('Before Breakfast: $_beforeBreakfast');
                    print('After Breakfast: $_afterBreakfast');
                    print('Before Lunch: $_beforeLunch');
                    print('After Lunch: $_afterLunch');
                    print('Evening: $_evening');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.pink[500], // Updated to backgroundColor
                  foregroundColor:
                      Colors.white, // Updated to foregroundColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
