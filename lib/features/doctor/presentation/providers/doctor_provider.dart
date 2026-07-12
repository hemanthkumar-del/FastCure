import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/doctor_model.dart';
import '../../domain/repositories/doctor_repository.dart';

enum DoctorSortOption { name, experience, consultationFee }

class DoctorProvider extends ChangeNotifier {
  final DoctorRepository _doctorRepository;
  final List<DoctorModel> _doctors = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Search, Filter, Sort, Pagination states
  String _searchQuery = '';
  String _filterSpecialization = 'All';
  DoctorSortOption _sortBy = DoctorSortOption.name;
  int _currentPage = 1;
  final int _pageSize = 5;

  List<DoctorModel> get allDoctors => _doctors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get filterSpecialization => _filterSpecialization;
  DoctorSortOption get sortBy => _sortBy;
  int get currentPage => _currentPage;

  DoctorProvider(this._doctorRepository) {
    loadDoctors();
  }

  // Clear query parameters
  void resetFilters() {
    _searchQuery = '';
    _filterSpecialization = 'All';
    _sortBy = DoctorSortOption.name;
    _currentPage = 1;
    notifyListeners();
  }

  // Fetch unique list of specialities for filter dropdowns
  List<String> get specializations {
    final specs = _doctors.map((doc) => doc.specialization).toSet().toList();
    specs.sort();
    return ['All', ...specs];
  }

  // Get final filtered, sorted, and paginated list of doctors
  List<DoctorModel> get doctors {
    // 1. Filter by Search Query & Specialty
    List<DoctorModel> filtered = _doctors.where((doc) {
      final matchesSearch = doc.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.specialization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.hospitalName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesSpecialty = _filterSpecialization == 'All' || 
          doc.specialization == _filterSpecialization;

      return matchesSearch && matchesSpecialty;
    }).toList();

    // 2. Sort
    switch (_sortBy) {
      case DoctorSortOption.name:
        filtered.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case DoctorSortOption.experience:
        // Highest experience first
        filtered.sort((a, b) => b.experience.compareTo(a.experience));
        break;
      case DoctorSortOption.consultationFee:
        // Lowest fee first
        filtered.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
    }

    // 3. Paginate
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= filtered.length) {
      return [];
    }
    final endIndex = startIndex + _pageSize;
    return filtered.sublist(
      startIndex, 
      endIndex > filtered.length ? filtered.length : endIndex
    );
  }

  bool get hasNextPage {
    List<DoctorModel> filtered = _doctors.where((doc) {
      final matchesSearch = doc.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.specialization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.hospitalName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesSpecialty = _filterSpecialization == 'All' || 
          doc.specialization == _filterSpecialization;

      return matchesSearch && matchesSpecialty;
    }).toList();
    
    return (_currentPage * _pageSize) < filtered.length;
  }

  bool get hasPreviousPage => _currentPage > 1;

  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to page 1 on new search
    notifyListeners();
  }

  void setFilterSpecialization(String spec) {
    _filterSpecialization = spec;
    _currentPage = 1; // Reset to page 1
    notifyListeners();
  }

  void setSortOption(DoctorSortOption option) {
    _sortBy = option;
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> loadDoctors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _doctorRepository.getDoctors();
      
      if (list.isEmpty) {
        await _seedDoctors();
        list = await _doctorRepository.getDoctors();
      }

      _doctors.clear();
      _doctors.addAll(list);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedDoctors() async {
    final seed = [
      DoctorModel(
        doctorId: 'doc_1',
        fullName: 'Dr. Sarah Jenkins',
        email: 'sarah.jenkins@fastcure.app',
        phoneNumber: '+15559876543',
        specialization: 'Cardiologist',
        qualification: 'MD, DM (Cardiology), FACC',
        experience: 12,
        consultationFee: 150.0,
        hospitalName: 'FastCure Health Center',
        department: 'Cardiology',
        bio: 'Senior consultant cardiologist specializing in interventional cardiac treatments, vascular checks, and preventive cardiac wellness care programs.',
        availableDays: ['Monday', 'Wednesday', 'Friday'],
        availableTimeSlots: ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM'],
        status: 'Active',
      ),
      DoctorModel(
        doctorId: 'doc_2',
        fullName: 'Dr. Michael Chen',
        email: 'michael.chen@fastcure.app',
        phoneNumber: '+15551239876',
        specialization: 'Pediatrician',
        qualification: 'MD (Pediatrics), DCH',
        experience: 9,
        consultationFee: 100.0,
        hospitalName: 'FastCure Childrens Clinic',
        department: 'Pediatrics',
        bio: 'Compassionate pediatric specialist focused on child development, immunizations, and general healthcare management from infancy through adolescence.',
        availableDays: ['Tuesday', 'Thursday'],
        availableTimeSlots: ['10:00 AM', '11:00 AM', '12:00 PM', '04:00 PM'],
        status: 'Active',
      ),
      DoctorModel(
        doctorId: 'doc_3',
        fullName: 'Dr. Emily Watson',
        email: 'emily.watson@fastcure.app',
        phoneNumber: '+15554567890',
        specialization: 'Dermatologist',
        qualification: 'MD (Dermatology), FAAD',
        experience: 15,
        consultationFee: 120.0,
        hospitalName: 'FastCure Skin & Laser Center',
        department: 'Dermatology',
        bio: 'Board-certified dermatologist expert in clinical dermatology, skin cancer screenings, allergy patch testing, and laser skin treatments.',
        availableDays: ['Monday', 'Tuesday', 'Thursday'],
        availableTimeSlots: ['09:30 AM', '01:30 PM', '02:30 PM', '03:30 PM'],
        status: 'Active',
      ),
    ];
    for (var doc in seed) {
      await _doctorRepository.createDoctor(doc);
    }
  }

  Future<bool> addDoctor(DoctorModel doctor, {Uint8List? imageBytes, String? imageName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _doctorRepository.createDoctor(doctor, imageBytes: imageBytes, imageName: imageName);
      await loadDoctors();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDoctor(DoctorModel doctor, {Uint8List? imageBytes, String? imageName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _doctorRepository.updateDoctor(doctor, imageBytes: imageBytes, imageName: imageName);
      await loadDoctors();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDoctor(String doctorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _doctorRepository.deleteDoctor(doctorId);
      await loadDoctors();
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
