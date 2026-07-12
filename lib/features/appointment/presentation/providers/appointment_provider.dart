import 'package:flutter/material.dart';
import '../../data/models/appointment_model.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;
  final List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppointmentProvider(this._appointmentRepository) {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _appointmentRepository.getAppointments();
      
      // If collection is empty, seed mock appointments
      if (list.isEmpty) {
        await _seedAppointments();
        list = await _appointmentRepository.getAppointments();
      }

      _appointments.clear();
      _appointments.addAll(list);
      // Sort appointments by date (newest/closest first)
      _appointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    } catch (e) {
      _errorMessage = 'Failed to load appointments: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedAppointments() async {
    final mockApps = [
      AppointmentModel(
        id: 'app_1',
        patientId: 'patient_doe',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        doctorSpecialty: 'Cardiologist',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        appointmentTime: '09:00 AM',
        reason: 'Routine cardiac checkup',
        status: 'confirmed',
      ),
      AppointmentModel(
        id: 'app_2',
        patientId: 'patient_doe',
        doctorId: 'doc_2',
        doctorName: 'Dr. Michael Chen',
        doctorSpecialty: 'Pediatrician',
        appointmentDate: DateTime.now().subtract(const Duration(days: 18)),
        appointmentTime: '11:30 AM',
        reason: 'Flu symptoms evaluation',
        status: 'completed',
      ),
    ];
    for (var app in mockApps) {
      await _appointmentRepository.createAppointment(app);
    }
  }

  Future<bool> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime date,
    required String time,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newApp = AppointmentModel(
        id: 'app_${DateTime.now().millisecondsSinceEpoch}',
        patientId: 'patient_doe', // Bound to active patient ID in production
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        appointmentDate: date,
        appointmentTime: time,
        reason: reason,
        status: 'confirmed',
      );

      await _appointmentRepository.createAppointment(newApp);
      await loadAppointments();
      return true;
    } catch (e) {
      _errorMessage = 'Booking failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final app = await _appointmentRepository.getAppointmentById(id);
      if (app != null) {
        final updatedApp = AppointmentModel(
          id: app.id,
          patientId: app.patientId,
          doctorId: app.doctorId,
          doctorName: app.doctorName,
          doctorSpecialty: app.doctorSpecialty,
          appointmentDate: app.appointmentDate,
          appointmentTime: app.appointmentTime,
          reason: app.reason,
          status: 'cancelled',
        );
        await _appointmentRepository.updateAppointment(updatedApp);
        await loadAppointments();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Cancellation failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
