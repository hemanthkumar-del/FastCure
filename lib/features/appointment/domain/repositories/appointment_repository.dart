import '../../data/models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentModel>> getAppointments();
  Future<List<AppointmentModel>> getAppointmentsForUser(String patientId);
  Future<AppointmentModel?> getAppointmentById(String id);
  Future<void> createAppointment(AppointmentModel appointment);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String id);
}
