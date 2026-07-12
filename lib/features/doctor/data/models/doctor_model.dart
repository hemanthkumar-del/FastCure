import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String doctorId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String specialization;
  final String qualification;
  final int experience;
  final double consultationFee;
  final String hospitalName;
  final String department;
  final String bio;
  final String? profileImage;
  final List<String> availableDays;
  final List<String> availableTimeSlots;
  final String status; // Active, Inactive
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorModel({
    required this.doctorId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.specialization,
    required this.qualification,
    required this.experience,
    required this.consultationFee,
    required this.hospitalName,
    required this.department,
    required this.bio,
    this.profileImage,
    required this.availableDays,
    required this.availableTimeSlots,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      doctorId: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      specialization: map['specialization'] ?? '',
      qualification: map['qualification'] ?? '',
      experience: (map['experience'] ?? 0) as int,
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(),
      hospitalName: map['hospitalName'] ?? '',
      department: map['department'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['profileImage'],
      availableDays: List<String>.from(map['availableDays'] ?? []),
      availableTimeSlots: List<String>.from(map['availableTimeSlots'] ?? []),
      status: map['status'] ?? 'Active',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'specialization': specialization,
      'qualification': qualification,
      'experience': experience,
      'consultationFee': consultationFee,
      'hospitalName': hospitalName,
      'department': department,
      'bio': bio,
      'profileImage': profileImage,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  DoctorModel copyWith({
    String? doctorId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? specialization,
    String? qualification,
    int? experience,
    double? consultationFee,
    String? hospitalName,
    String? department,
    String? bio,
    String? profileImage,
    List<String>? availableDays,
    List<String>? availableTimeSlots,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorModel(
      doctorId: doctorId ?? this.doctorId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      consultationFee: consultationFee ?? this.consultationFee,
      hospitalName: hospitalName ?? this.hospitalName,
      department: department ?? this.department,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      availableDays: availableDays ?? this.availableDays,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
