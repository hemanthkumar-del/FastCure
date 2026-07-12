import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/patient_repository.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<PatientModel>> getPatients() async {
    final query = await _firestore.collection(AppConstants.colPatients).get();
    return query.docs.map((doc) => PatientModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<PatientModel?> getPatientById(String id) async {
    final doc = await _firestore.collection(AppConstants.colPatients).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return PatientModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> createPatient(PatientModel patient) async {
    await _firestore
        .collection(AppConstants.colPatients)
        .doc(patient.id.isNotEmpty ? patient.id : null)
        .set(patient.toMap());
  }

  @override
  Future<void> updatePatient(PatientModel patient) async {
    await _firestore
        .collection(AppConstants.colPatients)
        .doc(patient.id)
        .update(patient.toMap());
  }

  @override
  Future<void> deletePatient(String id) async {
    await _firestore.collection(AppConstants.colPatients).doc(id).delete();
  }
}
