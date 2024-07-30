class Verification {
  final String medicationId;
  final String patientId;
  final String caregiverId;
  final String verificationStatement;
  final DateTime timestamp;
  final bool verified; // Field for verification status

  Verification({
    required this.medicationId,
    required this.patientId,
    required this.caregiverId,
    required this.verificationStatement,
    required this.timestamp,
    required this.verified,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'patientId': patientId,
      'caregiverId': caregiverId,
      'verificationStatement': verificationStatement,
      'timestamp': timestamp.toIso8601String(),
      'verified': verified,
    };
  }

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      medicationId: json['medicationId'],
      patientId: json['patientId'],
      caregiverId: json['caregiverId'],
      verificationStatement: json['verificationStatement'],
      timestamp: DateTime.parse(json['timestamp']),
      verified: json['verified'], // Ensure this field is read correctly
    );
  }
}
