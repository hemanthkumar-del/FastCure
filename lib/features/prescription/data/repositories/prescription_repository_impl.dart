import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../models/prescription_model.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<PrescriptionModel>> getPrescriptions() async {
    try {
      final query = await _firestore.collection(AppConstants.colPrescriptions).get();
      return query.docs.map((doc) => PrescriptionModel.fromMap(doc.data(), doc.id)).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve prescription logs.');
    }
  }

  @override
  Future<PrescriptionModel?> getPrescriptionById(String prescriptionId) async {
    try {
      final doc = await _firestore.collection(AppConstants.colPrescriptions).doc(prescriptionId).get();
      if (doc.exists && doc.data() != null) {
        return PrescriptionModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve prescription details.');
    }
  }

  @override
  Future<void> createPrescription(PrescriptionModel prescription) async {
    try {
      final docWithTimestamp = prescription.copyWith(
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.colPrescriptions)
          .doc(prescription.prescriptionId)
          .set(docWithTimestamp.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to issue prescription.');
    }
  }

  @override
  Future<void> updatePrescription(PrescriptionModel prescription) async {
    try {
      await _firestore
          .collection(AppConstants.colPrescriptions)
          .doc(prescription.prescriptionId)
          .update(prescription.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to update prescription details.');
    }
  }

  @override
  Future<void> deletePrescription(String prescriptionId) async {
    try {
      await _firestore.collection(AppConstants.colPrescriptions).doc(prescriptionId).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to delete prescription record.');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Security rules violation: Access denied to prescription logs.');
      case 'unavailable':
        return Exception('Database service is offline. Please check your network connection.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred in Cloud Firestore.');
    }
  }
}
