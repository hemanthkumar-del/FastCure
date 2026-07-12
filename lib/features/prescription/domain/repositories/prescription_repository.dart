import '../../data/models/prescription_model.dart';

abstract class PrescriptionRepository {
  Future<List<PrescriptionModel>> getPrescriptions();
  Future<List<PrescriptionModel>> getPrescriptionsForUser(String patientId);
  Future<PrescriptionModel?> getPrescriptionById(String id);
  Future<void> createPrescription(PrescriptionModel prescription);
  Future<void> updatePrescription(PrescriptionModel prescription);
  Future<void> deletePrescription(String id);
}
