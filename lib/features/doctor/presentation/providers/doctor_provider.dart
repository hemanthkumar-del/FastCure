import 'package:flutter/material.dart';
import '../../data/models/doctor_model.dart';
import '../../domain/repositories/doctor_repository.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorRepository _doctorRepository;
  final List<DoctorModel> _doctors = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<DoctorModel> get doctors {
    if (_searchQuery.isEmpty) {
      return _doctors;
    }
    return _doctors
        .where((doc) =>
            doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doc.specialty.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DoctorProvider(this._doctorRepository) {
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _doctorRepository.getDoctors();
      
      // If collection is fresh/empty, seed sample doctors to database
      if (list.isEmpty) {
        await _seedDoctors();
        list = await _doctorRepository.getDoctors();
      }

      _doctors.clear();
      _doctors.addAll(list);
    } catch (e) {
      _errorMessage = 'Failed to load doctors: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedDoctors() async {
    final seed = [
      DoctorModel(
        id: 'doc_1',
        name: 'Dr. Sarah Jenkins',
        specialty: 'Cardiologist',
        rating: 4.9,
        experienceYears: 12,
        clinicLocation: 'FastCure Health Center, Clinic B, Floor 2',
        consultationFee: 150.0,
        availableSlots: ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM'],
      ),
      DoctorModel(
        id: 'doc_2',
        name: 'Dr. Michael Chen',
        specialty: 'Pediatrician',
        rating: 4.8,
        experienceYears: 9,
        clinicLocation: 'FastCure Health Center, Clinic A, Floor 1',
        consultationFee: 100.0,
        availableSlots: ['10:00 AM', '11:00 AM', '12:00 PM', '04:00 PM'],
      ),
      DoctorModel(
        id: 'doc_3',
        name: 'Dr. Emily Watson',
        specialty: 'Dermatologist',
        rating: 4.7,
        experienceYears: 15,
        clinicLocation: 'FastCure Health Center, Clinic D, Floor 3',
        consultationFee: 120.0,
        availableSlots: ['09:30 AM', '01:30 PM', '02:30 PM', '03:30 PM'],
      ),
    ];
    for (var doc in seed) {
      await _doctorRepository.createDoctor(doc);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addDoctor(DoctorModel doctor) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _doctorRepository.createDoctor(doctor);
      await loadDoctors();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDoctor(DoctorModel doctor) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _doctorRepository.updateDoctor(doctor);
      await loadDoctors();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDoctor(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _doctorRepository.deleteDoctor(id);
      await loadDoctors();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
