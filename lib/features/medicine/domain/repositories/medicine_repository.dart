import '../../data/models/medicine_model.dart';

abstract class MedicineRepository {
  Future<List<MedicineModel>> getMedicines();
  Future<MedicineModel?> getMedicineById(String medicineId);
  Future<void> createMedicine(MedicineModel medicine);
  Future<void> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String medicineId);
}
