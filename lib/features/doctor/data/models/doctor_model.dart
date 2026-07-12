class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int experienceYears;
  final String clinicLocation;
  final double consultationFee;
  final List<String> availableSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experienceYears,
    required this.clinicLocation,
    required this.consultationFee,
    required this.availableSlots,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map, String docId) {
    return DoctorModel(
      id: docId,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      rating: (map['rating'] ?? 0.0) as double,
      experienceYears: (map['experienceYears'] ?? 0) as int,
      clinicLocation: map['clinicLocation'] ?? '',
      consultationFee: (map['consultationFee'] ?? 0.0) as double,
      availableSlots: List<String>.from(map['availableSlots'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'experienceYears': experienceYears,
      'clinicLocation': clinicLocation,
      'consultationFee': consultationFee,
      'availableSlots': availableSlots,
    };
  }
}
