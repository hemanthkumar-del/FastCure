import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/patient_model.dart';
import '../../domain/repositories/patient_repository.dart';

enum PatientSortOption { name, registrationDate }

class PatientProvider extends ChangeNotifier {
  final PatientRepository _patientRepository;
  final List<PatientModel> _patients = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _filterGender = 'All';
  String _filterBloodGroup = 'All';
  PatientSortOption _sortBy = PatientSortOption.name;
  int _currentPage = 1;
  final int _pageSize = 5;

  List<PatientModel> get allPatients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get filterGender => _filterGender;
  String get filterBloodGroup => _filterBloodGroup;
  PatientSortOption get sortBy => _sortBy;
  int get currentPage => _currentPage;

  PatientProvider(this._patientRepository) {
    loadPatients();
  }

  void resetFilters() {
    _searchQuery = '';
    _filterGender = 'All';
    _filterBloodGroup = 'All';
    _sortBy = PatientSortOption.name;
    _currentPage = 1;
    notifyListeners();
  }

  List<String> get bloodGroups {
    final groups = _patients.map((pat) => pat.bloodGroup).toSet().toList();
    groups.sort();
    return ['All', ...groups];
  }

  List<PatientModel> get patients {
    // 1. Filter
    List<PatientModel> filtered = _patients.where((pat) {
      final matchesSearch = pat.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pat.phone.contains(_searchQuery) ||
          pat.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesGender = _filterGender == 'All' || pat.gender == _filterGender;
      final matchesBlood = _filterBloodGroup == 'All' || pat.bloodGroup == _filterBloodGroup;

      return matchesSearch && matchesGender && matchesBlood;
    }).toList();

    // 2. Sort
    switch (_sortBy) {
      case PatientSortOption.name:
        filtered.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case PatientSortOption.registrationDate:
        filtered.sort((a, b) {
          final dateA = a.createdAt ?? DateTime.now();
          final dateB = b.createdAt ?? DateTime.now();
          return dateB.compareTo(dateA); // Newest first
        });
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
    List<PatientModel> filtered = _patients.where((pat) {
      final matchesSearch = pat.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pat.phone.contains(_searchQuery) ||
          pat.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesGender = _filterGender == 'All' || pat.gender == _filterGender;
      final matchesBlood = _filterBloodGroup == 'All' || pat.bloodGroup == _filterBloodGroup;

      return matchesSearch && matchesGender && matchesBlood;
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
    _currentPage = 1;
    notifyListeners();
  }

  void setFilterGender(String gender) {
    _filterGender = gender;
    _currentPage = 1;
    notifyListeners();
  }

  void setFilterBloodGroup(String group) {
    _filterBloodGroup = group;
    _currentPage = 1;
    notifyListeners();
  }

  void setSortOption(PatientSortOption option) {
    _sortBy = option;
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _patientRepository.getPatients();
      
      if (list.isEmpty) {
        await _seedPatients();
        list = await _patientRepository.getPatients();
      }

      _patients.clear();
      _patients.addAll(list);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedPatients() async {
    final seed = [
      PatientModel(
        patientId: 'pat_1',
        fullName: 'Jane Smith',
        email: 'jane.smith@email.com',
        phone: '+15551112222',
        gender: 'Female',
        dob: DateTime(1990, 5, 14),
        bloodGroup: 'O+',
        address: '123 Health Ave, Medical District, NY',
        medicalHistory: ['Asthma diagnostic in 2015', 'Mild hypertension'],
        allergies: ['Penicillin', 'Peanuts'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/png?seed=JaneSmith',
      ),
      PatientModel(
        patientId: 'pat_2',
        fullName: 'John Miller',
        email: 'john.miller@email.com',
        phone: '+15552223333',
        gender: 'Male',
        dob: DateTime(1985, 11, 23),
        bloodGroup: 'A-',
        address: '456 Wellness Blvd, Green Park, CA',
        medicalHistory: ['Appendectomy in 2018'],
        allergies: ['Sulfonamides'],
        profileImage: 'https://api.dicebear.com/7.x/adventurer/png?seed=JohnMiller',
      ),
    ];
    for (var pat in seed) {
      await _patientRepository.createPatient(pat);
    }
  }

  Future<bool> addPatient(PatientModel patient, {Uint8List? imageBytes, String? imageName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _patientRepository.createPatient(patient, imageBytes: imageBytes, imageName: imageName);
      await loadPatients();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePatient(PatientModel patient, {Uint8List? imageBytes, String? imageName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _patientRepository.updatePatient(patient, imageBytes: imageBytes, imageName: imageName);
      await loadPatients();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePatient(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _patientRepository.deletePatient(patientId);
      await loadPatients();
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
