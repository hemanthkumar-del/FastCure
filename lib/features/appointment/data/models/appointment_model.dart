class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String reason;
  final String status; // pending, confirmed, completed, cancelled

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.reason,
    required this.status,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String appId) {
    return AppointmentModel(
      id: appId,
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'] ?? '',
      appointmentDate: map['appointmentDate'] != null 
          ? DateTime.parse(map['appointmentDate'].toString()) 
          : DateTime.now(),
      appointmentTime: map['appointmentTime'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'reason': reason,
      'status': status,
    };
  }
}
