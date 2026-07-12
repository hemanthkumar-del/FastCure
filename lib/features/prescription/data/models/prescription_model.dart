class PrescriptionItem {
  final String medicineName;
  final String frequency; // e.g. "Once daily"
  final String timing;    // e.g. "Bedtime"
  final String duration;  // e.g. "30 Days"

  PrescriptionItem({
    required this.medicineName,
    required this.frequency,
    required this.timing,
    required this.duration,
  });

  factory PrescriptionItem.fromMap(Map<String, dynamic> map) {
    return PrescriptionItem(
      medicineName: map['medicineName'] ?? '',
      frequency: map['frequency'] ?? '',
      timing: map['timing'] ?? '',
      duration: map['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'frequency': frequency,
      'timing': timing,
      'duration': duration,
    };
  }
}

class PrescriptionModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String patientId;
  final String patientName;
  final DateTime dateIssued;
  final String diagnosis;
  final List<PrescriptionItem> medications;

  PrescriptionModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientId,
    required this.patientName,
    required this.dateIssued,
    required this.diagnosis,
    required this.medications,
  });

  factory PrescriptionModel.fromMap(Map<String, dynamic> map, String presId) {
    return PrescriptionModel(
      id: presId,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      dateIssued: map['dateIssued'] != null 
          ? DateTime.parse(map['dateIssued'].toString()) 
          : DateTime.now(),
      diagnosis: map['diagnosis'] ?? '',
      medications: (map['medications'] as List<dynamic>?)
              ?.map((item) => PrescriptionItem.fromMap(Map<String, dynamic>.from(item)))
              .toList() ?? 
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientId': patientId,
      'patientName': patientName,
      'dateIssued': dateIssued.toIso8601String(),
      'diagnosis': diagnosis,
      'medications': medications.map((med) => med.toMap()).toList(),
    };
  }
}
