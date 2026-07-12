import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<MedicineModel>> getMedicines() async {
    final query = await _firestore.collection(AppConstants.colMedicines).get();
    return query.docs.map((doc) => MedicineModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<MedicineModel?> getMedicineById(String id) async {
    final doc = await _firestore.collection(AppConstants.colMedicines).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return MedicineModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> createMedicine(MedicineModel medicine) async {
    await _firestore
        .collection(AppConstants.colMedicines)
        .doc(medicine.id.isNotEmpty ? medicine.id : null)
        .set(medicine.toMap());
  }

  @override
  Future<void> updateMedicine(MedicineModel medicine) async {
    await _firestore
        .collection(AppConstants.colMedicines)
        .doc(medicine.id)
        .update(medicine.toMap());
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await _firestore.collection(AppConstants.colMedicines).doc(id).delete();
  }
}
