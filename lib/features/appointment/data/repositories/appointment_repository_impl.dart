import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final query = await _firestore.collection(AppConstants.colAppointments).get();
      return query.docs.map((doc) => AppointmentModel.fromMap(doc.data(), doc.id)).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve appointments directory.');
    }
  }

  @override
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await _firestore.collection(AppConstants.colAppointments).doc(appointmentId).get();
      if (doc.exists && doc.data() != null) {
        return AppointmentModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve appointment details.');
    }
  }

  @override
  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      final docWithTimestamp = appointment.copyWith(
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.colAppointments)
          .doc(appointment.appointmentId)
          .set(docWithTimestamp.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to book appointment.');
    }
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection(AppConstants.colAppointments)
          .doc(appointment.appointmentId)
          .update(appointment.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to reschedule appointment.');
    }
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection(AppConstants.colAppointments).doc(appointmentId).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to cancel appointment.');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Security rules violation: Access denied to appointment logs.');
      case 'unavailable':
        return Exception('Database service is offline. Please check your network connection.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred in Cloud Firestore.');
    }
  }
}
