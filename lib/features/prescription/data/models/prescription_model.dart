import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionItem {
  final String medicineId;
  final String name;
  final String dosage;      // e.g. "1 Tablet morning, 1 night after food"
  final int quantity;       // e.g. 10

  PrescriptionItem({
    required this.medicineId,
    required this.name,
    required this.dosage,
    required this.quantity,
  });

  factory PrescriptionItem.fromMap(Map<String, dynamic> map) {
    return PrescriptionItem(
      medicineId: map['medicineId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      quantity: (map['quantity'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'name': name,
      'dosage': dosage,
      'quantity': quantity,
    };
  }
}

class PrescriptionModel {
  final String prescriptionId;
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final List<PrescriptionItem> medicines;
  final String notes;
  final DateTime? createdAt;

  // Helper UI fields
  final String? doctorName;
  final String? doctorSpecialty;
  final String? patientName;

  PrescriptionModel({
    required this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.medicines,
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

  factory PrescriptionModel.fromMap(Map<String, dynamic> map, String id) {
    return PrescriptionModel(
      prescriptionId: id,
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      medicines: (map['medicines'] as List<dynamic>?)
              ?.map((item) => PrescriptionItem.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null ? _parseDateTime(map['createdAt']) : null,
      doctorName: map['doctorName'],
      doctorSpecialty: map['doctorSpecialty'],
      patientName: map['patientName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prescriptionId': prescriptionId,
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'medicines': medicines.map((med) => med.toMap()).toList(),
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientName': patientName,
    };
  }

  PrescriptionModel copyWith({
    String? prescriptionId,
    String? doctorId,
    String? patientId,
    String? appointmentId,
    List<PrescriptionItem>? medicines,
    String? notes,
    DateTime? createdAt,
    String? doctorName,
    String? doctorSpecialty,
    String? patientName,
  }) {
    return PrescriptionModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      medicines: medicines ?? this.medicines,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      patientName: patientName ?? this.patientName,
    );
  }
}
