import 'package:flutter/material.dart';
import '../../data/models/prescription_model.dart';
import '../../domain/repositories/prescription_repository.dart';

class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionRepository _prescriptionRepository;
  final List<PrescriptionModel> _prescriptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PrescriptionModel> get prescriptions => _prescriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PrescriptionProvider(this._prescriptionRepository) {
    loadPrescriptions();
  }

  Future<void> loadPrescriptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _prescriptionRepository.getPrescriptions();
      
      // If collection is empty, seed mock prescriptions
      if (list.isEmpty) {
        await _seedPrescriptions();
        list = await _prescriptionRepository.getPrescriptions();
      }

      _prescriptions.clear();
      _prescriptions.addAll(list);
      // Sort by date issued
      _prescriptions.sort((a, b) => b.dateIssued.compareTo(a.dateIssued));
    } catch (e) {
      _errorMessage = 'Failed to load prescriptions: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedPrescriptions() async {
    final mockPrescriptions = [
      PrescriptionModel(
        id: 'pres_1',
        doctorId: 'doc_1',
        doctorName: 'Dr. Sarah Jenkins',
        doctorSpecialty: 'Cardiology',
        patientId: 'patient_doe',
        patientName: 'John Doe',
        dateIssued: DateTime.now().subtract(const Duration(days: 1)),
        diagnosis: 'Essential Hypertension (Stage 1)',
        medications: [
          PrescriptionItem(medicineName: 'Atorvastatin 20mg', frequency: '1 Tablet daily', timing: 'Bedtime', duration: '30 Days'),
          PrescriptionItem(medicineName: 'Lisinopril 10mg', frequency: '1 Tablet daily', timing: 'Morning (with water)', duration: '90 Days'),
          PrescriptionItem(medicineName: 'Omega-3 Fish Oil 1000mg', frequency: '1 Capsule twice daily', timing: 'Breakfast & Dinner', duration: '60 Days'),
        ],
      ),
      PrescriptionModel(
        id: 'pres_2',
        doctorId: 'doc_2',
        doctorName: 'Dr. Michael Chen',
        doctorSpecialty: 'Pediatrics',
        patientId: 'patient_doe',
        patientName: 'John Doe',
        dateIssued: DateTime.now().subtract(const Duration(days: 90)),
        diagnosis: 'Acute Rhinopharyngitis',
        medications: [
          PrescriptionItem(medicineName: 'Amoxicillin 500mg', frequency: '1 Capsule 3 times daily', timing: 'After meals', duration: '7 Days'),
          PrescriptionItem(medicineName: 'Paracetamol 500mg', frequency: '1 Tablet 4 times daily', timing: 'Every 6 hours as needed', duration: '5 Days'),
        ],
      ),
    ];
    for (var pres in mockPrescriptions) {
      await _prescriptionRepository.createPrescription(pres);
    }
  }

  Future<bool> addPrescription(PrescriptionModel prescription) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _prescriptionRepository.createPrescription(prescription);
      await loadPrescriptions();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePrescription(PrescriptionModel prescription) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _prescriptionRepository.updatePrescription(prescription);
      await loadPrescriptions();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePrescription(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _prescriptionRepository.deletePrescription(id);
      await loadPrescriptions();
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
