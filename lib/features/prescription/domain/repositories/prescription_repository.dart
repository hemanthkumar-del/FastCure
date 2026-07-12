import '../../data/models/prescription_model.dart';

abstract class PrescriptionRepository {
  Future<List<PrescriptionModel>> getPrescriptions();
  Future<PrescriptionModel?> getPrescriptionById(String prescriptionId);
  Future<void> createPrescription(PrescriptionModel prescription);
  Future<void> updatePrescription(PrescriptionModel prescription);
  Future<void> deletePrescription(String prescriptionId);
}
