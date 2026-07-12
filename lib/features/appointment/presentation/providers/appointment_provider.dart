import 'package:flutter/material.dart';
import '../../data/models/appointment_model.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;
  final List<AppointmentModel> _appointments = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Selected calendar day filter for calendar view
  DateTime _selectedCalendarDate = DateTime.now();

  List<AppointmentModel> get allAppointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedCalendarDate => _selectedCalendarDate;

  AppointmentProvider(this._appointmentRepository) {
    loadAppointments();
  }

  void setSelectedCalendarDate(DateTime date) {
    _selectedCalendarDate = date;
    notifyListeners();
  }

  // Filter: Appointments scheduled for today
  List<AppointmentModel> get todayAppointments {
    final now = DateTime.now();
    return _appointments.where((app) {
      return app.date.year == now.year &&
          app.date.month == now.month &&
          app.date.day == now.day;
    }).toList();
  }

  // Filter: Calendar view appointments for selected day
  List<AppointmentModel> get calendarAppointments {
    return _appointments.where((app) {
      return app.date.year == _selectedCalendarDate.year &&
          app.date.month == _selectedCalendarDate.month &&
          app.date.day == _selectedCalendarDate.day;
    }).toList();
  }

  // Filter: Appointments for a specific doctor
  List<AppointmentModel> getDoctorSchedule(String doctorId) {
    return _appointments.where((app) => app.doctorId == doctorId).toList();
  }

  // Filter: Appointment history for a specific patient
  List<AppointmentModel> getPatientHistory(String patientId) {
    return _appointments.where((app) => app.patientId == patientId).toList();
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _appointmentRepository.getAppointments();

      if (list.isEmpty) {
        await _seedAppointments();
        list = await _appointmentRepository.getAppointments();
      }

      _appointments.clear();
      _appointments.addAll(list);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedAppointments() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final seed = [
      AppointmentModel(
        appointmentId: 'app_1',
        doctorId: 'doc_1',
        patientId: 'pat_1',
        date: tomorrow,
        time: '10:00 AM',
        status: 'Approved',
        reason: 'Routine cardiovascular checkup and ECG analysis.',
        notes: 'Patient should avoid caffeine prior to visit.',
        doctorName: 'Dr. Sarah Jenkins',
        doctorSpecialty: 'Cardiologist',
        patientName: 'Jane Smith',
      ),
      AppointmentModel(
        appointmentId: 'app_2',
        doctorId: 'doc_2',
        patientId: 'pat_2',
        date: tomorrow,
        time: '04:00 PM',
        status: 'Pending',
        reason: 'Child wellness program and pediatric vaccination check.',
        notes: 'Bring previous immunization record books.',
        doctorName: 'Dr. Michael Chen',
        doctorSpecialty: 'Pediatrician',
        patientName: 'John Miller',
      ),
    ];
    for (var app in seed) {
      await _appointmentRepository.createAppointment(app);
    }
  }

  Future<bool> bookAppointment(AppointmentModel appointment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _appointmentRepository.createAppointment(appointment);
      await loadAppointments();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final app = _appointments.firstWhere((a) => a.appointmentId == appointmentId);
      final cancelledApp = app.copyWith(status: 'Cancelled');
      await _appointmentRepository.updateAppointment(cancelledApp);
      await loadAppointments();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rescheduleAppointment(String appointmentId, DateTime newDate, String newTime) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final app = _appointments.firstWhere((a) => a.appointmentId == appointmentId);
      final rescheduledApp = app.copyWith(
        date: newDate,
        time: newTime,
        status: 'Pending', // Reset to pending for approval
      );
      await _appointmentRepository.updateAppointment(rescheduledApp);
      await loadAppointments();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveAppointment(String appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final app = _appointments.firstWhere((a) => a.appointmentId == appointmentId);
      final approvedApp = app.copyWith(status: 'Approved');
      await _appointmentRepository.updateAppointment(approvedApp);
      await loadAppointments();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectAppointment(String appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final app = _appointments.firstWhere((a) => a.appointmentId == appointmentId);
      final rejectedApp = app.copyWith(status: 'Rejected');
      await _appointmentRepository.updateAppointment(rejectedApp);
      await loadAppointments();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
