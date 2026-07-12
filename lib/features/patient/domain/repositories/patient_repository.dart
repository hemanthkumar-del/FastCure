import 'dart:typed_data';
import '../../data/models/patient_model.dart';

abstract class PatientRepository {
  Future<List<PatientModel>> getPatients();
  Future<PatientModel?> getPatientById(String patientId);
  Future<void> createPatient(PatientModel patient, {Uint8List? imageBytes, String? imageName});
  Future<void> updatePatient(PatientModel patient, {Uint8List? imageBytes, String? imageName});
  Future<void> deletePatient(String patientId);
}
