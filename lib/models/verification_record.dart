import 'package:flutter/material.dart';

class VerificationRecord {
  final DateTime date;
  final String status; // Added status field
  final String medicationName;
  final TimeOfDay alarm;

  VerificationRecord({
    required this.date,
    required this.status,
    required this.medicationName,
    required this.alarm,
  });
}
