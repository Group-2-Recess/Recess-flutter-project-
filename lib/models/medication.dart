import 'package:flutter/material.dart';

class Medication {
  String sicknessName;
  String medicationName;
  String prescription;
  List<TimeOfDay> alarms; // Changed to TimeOfDay for storing times
  bool isVerified; // New field for verification status
  DateTime? verificationDate; // New field for verification date

  Medication({
    required this.sicknessName,
    required this.medicationName,
    required this.prescription,
    required this.alarms,
    this.isVerified = false,
    this.verificationDate,
  });
}
