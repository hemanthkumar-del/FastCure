import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../models/prescription_model.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<PrescriptionModel>> getPrescriptions() async {
    final query = await _firestore.collection(AppConstants.colPrescriptions).get();
    return query.docs.map((doc) => PrescriptionModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<PrescriptionModel>> getPrescriptionsForUser(String patientId) async {
    final query = await _firestore
        .collection(AppConstants.colPrescriptions)
        .where('patientId', isEqualTo: patientId)
        .get();
    return query.docs.map((doc) => PrescriptionModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<PrescriptionModel?> getPrescriptionById(String id) async {
    final doc = await _firestore.collection(AppConstants.colPrescriptions).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return PrescriptionModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> createPrescription(PrescriptionModel prescription) async {
    await _firestore
        .collection(AppConstants.colPrescriptions)
        .doc(prescription.id.isNotEmpty ? prescription.id : null)
        .set(prescription.toMap());
  }

  @override
  Future<void> updatePrescription(PrescriptionModel prescription) async {
    await _firestore
        .collection(AppConstants.colPrescriptions)
        .doc(prescription.id)
        .update(prescription.toMap());
  }

  @override
  Future<void> deletePrescription(String id) async {
    await _firestore.collection(AppConstants.colPrescriptions).doc(id).delete();
  }
}
