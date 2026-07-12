import 'package:flutter/material.dart';
import '../../data/models/patient_model.dart';
import '../../domain/repositories/patient_repository.dart';

class PatientProvider extends ChangeNotifier {
  final PatientRepository _patientRepository;
  PatientModel? _currentPatientProfile;
  bool _isLoading = false;
  String? _errorMessage;

  PatientModel? get currentPatientProfile => _currentPatientProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PatientProvider(this._patientRepository) {
    loadPatientProfile();
  }

  Future<void> loadPatientProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For Phase 3, we retrieve our main patient doc, or create one if empty
      var patient = await _patientRepository.getPatientById('patient_doe');
      if (patient == null) {
        await _seedPatientProfile();
        patient = await _patientRepository.getPatientById('patient_doe');
      }
      _currentPatientProfile = patient;
    } catch (e) {
      _errorMessage = 'Failed to load patient records: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedPatientProfile() async {
    final mockPatient = PatientModel(
      id: 'patient_doe',
      name: 'John Doe',
      email: 'johndoe@fastcure.app',
      phone: '+1 (555) 019-2834',
      dateOfBirth: '14 May 1992',
      bloodGroup: 'O Positive (O+)',
      address: '123 Medical Center Way, Suite 400',
      emergencyContactName: 'Jane Doe (Spouse)',
      emergencyContactPhone: '+1 (555) 019-5829',
      allergies: ['Penicillin', 'Peanuts'],
      medicalConditions: ['Mild Asthma'],
    );
    await _patientRepository.createPatient(mockPatient);
  }

  Future<bool> updateProfile(PatientModel profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _patientRepository.updatePatient(profile);
      _currentPatientProfile = profile;
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
