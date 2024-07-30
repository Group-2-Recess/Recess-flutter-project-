class CaregiverProfile {
  String id; // Document ID
  final String userId; // Firebase user ID
  final String name;
  final String organization;
  final String location;
  final String? image; // URL or path to the profile image

  CaregiverProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.organization,
    required this.location,
    this.image,
  });

  factory CaregiverProfile.fromMap(Map<String, dynamic> data) {
    return CaregiverProfile(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      organization: data['organization'] ?? '',
      location: data['location'] ?? '',
      image: data['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'organization': organization,
      'location': location,
      'image': image,
    };
  }
}
