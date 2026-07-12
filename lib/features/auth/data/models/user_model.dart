import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role; // Admin, Doctor, Receptionist, Patient
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? createdAt;
  final bool isVerified;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
    this.isVerified = false,
    this.lastLogin,
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Patient',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      createdAt: _parseDateTime(map['createdAt']),
      isVerified: map['isVerified'] ?? false,
      lastLogin: _parseDateTime(map['lastLogin']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'isVerified': isVerified,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? role,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    bool? isVerified,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
