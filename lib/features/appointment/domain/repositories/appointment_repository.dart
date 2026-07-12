import '../../data/models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel?> getAppointmentById(String appointmentId);
  Future<void> createAppointment(AppointmentModel appointment);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String appointmentId);
}
