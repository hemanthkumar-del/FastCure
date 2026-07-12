import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../models/doctor_model.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DoctorModel>> getDoctors() async {
    final query = await _firestore.collection(AppConstants.colDoctors).get();
    return query.docs.map((doc) => DoctorModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<DoctorModel?> getDoctorById(String id) async {
    final doc = await _firestore.collection(AppConstants.colDoctors).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return DoctorModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> createDoctor(DoctorModel doctor) async {
    await _firestore
        .collection(AppConstants.colDoctors)
        .doc(doctor.id.isNotEmpty ? doctor.id : null)
        .set(doctor.toMap());
  }

  @override
  Future<void> updateDoctor(DoctorModel doctor) async {
    await _firestore
        .collection(AppConstants.colDoctors)
        .doc(doctor.id)
        .update(doctor.toMap());
  }

  @override
  Future<void> deleteDoctor(String id) async {
    await _firestore.collection(AppConstants.colDoctors).doc(id).delete();
  }
}
