class PatientProfile {
  String id;
  String firstName;
  String lastName;
  DateTime dateOfBirth;
  String profileImageUrl;

  PatientProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.profileImageUrl,
  });

  // Convert a PatientProfile object into a map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create a PatientProfile object from a map object
  factory PatientProfile.fromMap(Map<String, dynamic> map, String userId) {
    return PatientProfile(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
