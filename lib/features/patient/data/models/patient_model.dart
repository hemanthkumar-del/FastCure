class PatientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String bloodGroup;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final List<String> allergies;
  final List<String> medicalConditions;

  PatientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.allergies,
    required this.medicalConditions,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map, String patientId) {
    return PatientModel(
      id: patientId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      address: map['address'] ?? '',
      emergencyContactName: map['emergencyContactName'] ?? '',
      emergencyContactPhone: map['emergencyContactPhone'] ?? '',
      allergies: List<String>.from(map['allergies'] ?? []),
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'bloodGroup': bloodGroup,
      'address': address,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
    };
  }
}
