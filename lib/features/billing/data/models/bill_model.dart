import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String billId;
  final String patientId;
  final String appointmentId;
  final double doctorFee;
  final double medicineFee;
  final double labFee;
  final double total;
  final String paymentMethod; // Cash, Card, Insurance, UPI
  final String status; // Pending, Paid
  final DateTime? createdAt;

  // Helper UI fields
  final String? patientName;
  final String? doctorName;

  BillModel({
    required this.billId,
    required this.patientId,
    required this.appointmentId,
    required this.doctorFee,
    required this.medicineFee,
    required this.labFee,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
    this.patientName,
    this.doctorName,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory BillModel.fromMap(Map<String, dynamic> map, String id) {
    return BillModel(
      billId: id,
      patientId: map['patientId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      doctorFee: (map['doctorFee'] ?? 0.0).toDouble(),
      medicineFee: (map['medicineFee'] ?? 0.0).toDouble(),
      labFee: (map['labFee'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      status: map['status'] ?? 'Pending',
      createdAt: map['createdAt'] != null ? _parseDateTime(map['createdAt']) : null,
      patientName: map['patientName'],
      doctorName: map['doctorName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'doctorFee': doctorFee,
      'medicineFee': medicineFee,
      'labFee': labFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'patientName': patientName,
      'doctorName': doctorName,
    };
  }

  BillModel copyWith({
    String? billId,
    String? patientId,
    String? appointmentId,
    double? doctorFee,
    double? medicineFee,
    double? labFee,
    double? total,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    String? patientName,
    String? doctorName,
  }) {
    return BillModel(
      billId: billId ?? this.billId,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorFee: doctorFee ?? this.doctorFee,
      medicineFee: medicineFee ?? this.medicineFee,
      labFee: labFee ?? this.labFee,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}
