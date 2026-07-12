import '../../data/models/patient_model.dart';

abstract class PatientRepository {
  Future<List<PatientModel>> getPatients();
  Future<PatientModel?> getPatientById(String id);
  Future<void> createPatient(PatientModel patient);
  Future<void> updatePatient(PatientModel patient);
  Future<void> deletePatient(String id);
}
