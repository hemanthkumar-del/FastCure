import 'package:flutter_test/flutter_test.dart';
import 'package:fastcure/features/doctor/data/models/doctor_model.dart';

void main() {
  group('DoctorModel Unit Tests', () {
    test('DoctorModel fromMap parses correct fields', () {
      final map = {
        'doctorId': 'doc_123',
        'fullName': 'Dr. Sarah Jenkins',
        'email': 'sarah@fastcure.com',
        'specialization': 'Cardiologist',
        'consultationFee': 150.0,
        'experience': 12,
        'status': 'Active',
      };

      final doc = DoctorModel.fromMap(map, 'doc_123');

      expect(doc.doctorId, 'doc_123');
      expect(doc.fullName, 'Dr. Sarah Jenkins');
      expect(doc.specialization, 'Cardiologist');
      expect(doc.consultationFee, 150.0);
      expect(doc.experience, 12);
      expect(doc.status, 'Active');
    });

    test('DoctorModel toMap produces correct map', () {
      final doc = DoctorModel(
        doctorId: 'doc_123',
        fullName: 'Dr. Sarah Jenkins',
        email: 'sarah@fastcure.com',
        phoneNumber: '1234567890',
        specialization: 'Cardiologist',
        qualification: 'MD',
        experience: 12,
        consultationFee: 150.0,
        hospitalName: 'General Hospital',
        department: 'Cardiology',
        bio: 'Bio details',
        profileImage: '',
        availableDays: ['Monday', 'Tuesday'],
        availableTimeSlots: ['09:00 AM'],
        status: 'Active',
      );

      final map = doc.toMap();

      expect(map['fullName'], 'Dr. Sarah Jenkins');
      expect(map['specialization'], 'Cardiologist');
      expect(map['consultationFee'], 150.0);
      expect(map['experience'], 12);
      expect(map['status'], 'Active');
    });
  });
}
