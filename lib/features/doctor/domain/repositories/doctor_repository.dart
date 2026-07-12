import '../../data/models/doctor_model.dart';

abstract class DoctorRepository {
  Future<List<DoctorModel>> getDoctors();
  Future<DoctorModel?> getDoctorById(String id);
  Future<void> createDoctor(DoctorModel doctor);
  Future<void> updateDoctor(DoctorModel doctor);
  Future<void> deleteDoctor(String id);
}
