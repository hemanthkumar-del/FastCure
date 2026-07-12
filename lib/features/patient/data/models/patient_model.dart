import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String patientId;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final DateTime dob;
  final String bloodGroup;
  final String address;
  final List<String> medicalHistory;
  final List<String> allergies;
  final String? profileImage;
  final DateTime? createdAt;

  PatientModel({
    required this.patientId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.address,
    required this.medicalHistory,
    required this.allergies,
    this.profileImage,
    this.createdAt,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    // Gracefully handle medical history if saved as a raw string or list
    List<String> parsedHistory = [];
    if (map['medicalHistory'] is List) {
      parsedHistory = List<String>.from(map['medicalHistory']);
    } else if (map['medicalHistory'] is String && map['medicalHistory'].toString().trim().isNotEmpty) {
      parsedHistory = [map['medicalHistory']];
    }

    return PatientModel(
      patientId: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? 'Male',
      dob: _parseDateTime(map['dob']),
      bloodGroup: map['bloodGroup'] ?? '',
      address: map['address'] ?? '',
      medicalHistory: parsedHistory,
      allergies: List<String>.from(map['allergies'] ?? []),
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null ? _parseDateTime(map['createdAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': Timestamp.fromDate(dob),
      'bloodGroup': bloodGroup,
      'address': address,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'profileImage': profileImage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  PatientModel copyWith({
    String? patientId,
    String? fullName,
    String? email,
    String? phone,
    String? gender,
    DateTime? dob,
    String? bloodGroup,
    String? address,
    List<String>? medicalHistory,
    List<String>? allergies,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return PatientModel(
      patientId: patientId ?? this.patientId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
