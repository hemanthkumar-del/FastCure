import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<MedicineModel>> getMedicines() async {
    try {
      final query = await _firestore.collection(AppConstants.colMedicines).get();
      return query.docs.map((doc) => MedicineModel.fromMap(doc.data(), doc.id)).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve medicine inventory.');
    }
  }

  @override
  Future<MedicineModel?> getMedicineById(String medicineId) async {
    try {
      final doc = await _firestore.collection(AppConstants.colMedicines).doc(medicineId).get();
      if (doc.exists && doc.data() != null) {
        return MedicineModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve medicine details.');
    }
  }

  @override
  Future<void> createMedicine(MedicineModel medicine) async {
    try {
      await _firestore
          .collection(AppConstants.colMedicines)
          .doc(medicine.medicineId)
          .set(medicine.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to add medicine to inventory.');
    }
  }

  @override
  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      await _firestore
          .collection(AppConstants.colMedicines)
          .doc(medicine.medicineId)
          .update(medicine.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to update medicine inventory.');
    }
  }

  @override
  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _firestore.collection(AppConstants.colMedicines).doc(medicineId).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to delete medicine record.');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Security rules violation: Access denied to medicine logs.');
      case 'unavailable':
        return Exception('Database service is offline. Please check your network connection.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred in Cloud Firestore.');
    }
  }
}
