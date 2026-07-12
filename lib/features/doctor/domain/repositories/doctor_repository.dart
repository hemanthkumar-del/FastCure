import 'dart:typed_data';
import '../../data/models/doctor_model.dart';

abstract class DoctorRepository {
  Future<List<DoctorModel>> getDoctors();
  Future<DoctorModel?> getDoctorById(String doctorId);
  Future<void> createDoctor(DoctorModel doctor, {Uint8List? imageBytes, String? imageName});
  Future<void> updateDoctor(DoctorModel doctor, {Uint8List? imageBytes, String? imageName});
  Future<void> deleteDoctor(String doctorId);
}
