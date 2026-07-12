import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final DateTime date;
  final String time;
  final String status; // Pending, Approved, Cancelled, Rejected
  final String reason;
  final String notes;
  final DateTime? createdAt;

  // UI helper fields to avoid nested database queries in lists
  final String? doctorName;
  final String? doctorSpecialty;
  final String? patientName;

  AppointmentModel({
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.time,
    required this.status,
    required this.reason,
    required this.notes,
    this.createdAt,
    this.doctorName,
    this.doctorSpecialty,
    this.patientName,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      appointmentId: id,
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      date: _parseDateTime(map['date']),
      time: map['time'] ?? '',
      status: map['status'] ?? 'Pending',
      reason: map['reason'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null ? _parseDateTime(map['createdAt']) : null,
      doctorName: map['doctorName'],
      doctorSpecialty: map['doctorSpecialty'],
      patientName: map['patientName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'reason': reason,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientName': patientName,
    };
  }

  AppointmentModel copyWith({
    String? appointmentId,
    String? doctorId,
    String? patientId,
    DateTime? date,
    String? time,
    String? status,
    String? reason,
    String? notes,
    DateTime? createdAt,
    String? doctorName,
    String? doctorSpecialty,
    String? patientName,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      patientName: patientName ?? this.patientName,
    );
  }
}
