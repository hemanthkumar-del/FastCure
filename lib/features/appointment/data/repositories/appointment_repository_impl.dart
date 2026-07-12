import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    final query = await _firestore.collection(AppConstants.colAppointments).get();
    return query.docs.map((doc) => AppointmentModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsForUser(String patientId) async {
    final query = await _firestore
        .collection(AppConstants.colAppointments)
        .where('patientId', isEqualTo: patientId)
        .get();
    return query.docs.map((doc) => AppointmentModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<AppointmentModel?> getAppointmentById(String id) async {
    final doc = await _firestore.collection(AppConstants.colAppointments).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return AppointmentModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> createAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection(AppConstants.colAppointments)
        .doc(appointment.id.isNotEmpty ? appointment.id : null)
        .set(appointment.toMap());
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection(AppConstants.colAppointments)
        .doc(appointment.id)
        .update(appointment.toMap());
  }

  @override
  Future<void> deleteAppointment(String id) async {
    await _firestore.collection(AppConstants.colAppointments).doc(id).delete();
  }
}
