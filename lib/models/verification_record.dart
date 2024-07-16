class VerificationRecord {
  String patientName;
  String medicationName;
  DateTime time;
  bool taken;

  VerificationRecord({
    required this.patientName,
    required this.medicationName,
    required this.time,
    required this.taken,
  });

  factory VerificationRecord.fromJson(Map<String, dynamic> json) {
    return VerificationRecord(
      patientName: json['patientName'],
      medicationName: json['medicationName'],
      time: DateTime.parse(json['time']),
      taken: json['taken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'medicationName': medicationName,
      'time': time.toIso8601String(),
      'taken': taken,
    };
  }
}
