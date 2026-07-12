import 'package:flutter/material.dart';
import '../../../medicine/presentation/providers/medicine_provider.dart';
import '../../data/models/prescription_model.dart';
import '../../domain/repositories/prescription_repository.dart';

class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionRepository _prescriptionRepository;
  final List<PrescriptionModel> _prescriptions = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<PrescriptionModel> get allPrescriptions => _prescriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  PrescriptionProvider(this._prescriptionRepository) {
    loadPrescriptions();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<PrescriptionModel> get prescriptions {
    if (_searchQuery.trim().isEmpty) {
      return _prescriptions;
    }
    return _prescriptions.where((pres) {
      return (pres.patientName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (pres.doctorName ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> loadPrescriptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _prescriptionRepository.getPrescriptions();

      if (list.isEmpty) {
        await _seedPrescriptions();
        list = await _prescriptionRepository.getPrescriptions();
      }

      _prescriptions.clear();
      _prescriptions.addAll(list);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedPrescriptions() async {
    final seed = [
      PrescriptionModel(
        prescriptionId: 'pres_1',
        doctorId: 'doc_1',
        patientId: 'pat_1',
        appointmentId: 'app_1',
        medicines: [
          PrescriptionItem(
            medicineId: 'med_1',
            name: 'Amoxicillin',
            dosage: '500mg - 1 capsule thrice a day for 5 days.',
            quantity: 15,
          ),
          PrescriptionItem(
            medicineId: 'med_2',
            name: 'Paracetamol',
            dosage: '650mg - 1 tablet SOS for body pain.',
            quantity: 10,
          ),
        ],
        notes: 'Advised plenty of warm fluids and bed rest.',
        doctorName: 'Dr. Sarah Jenkins',
        patientName: 'Jane Smith',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    for (var pres in seed) {
      await _prescriptionRepository.createPrescription(pres);
    }
  }

  Future<bool> issuePrescription(PrescriptionModel prescription, MedicineProvider medProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Verify stock and deduct inventory
      for (var item in prescription.medicines) {
        // Find medicine in provider memory list
        final match = medProvider.allMedicines.any((m) => m.medicineId == item.medicineId && m.stock >= item.quantity);
        if (!match) {
          throw Exception('Stock shortage for item: ${item.name}. Verify inventory count.');
        }
      }

      // Deduct stock for all items
      for (var item in prescription.medicines) {
        await medProvider.deductStock(item.medicineId, item.quantity);
      }

      // 2. Create database record
      await _prescriptionRepository.createPrescription(prescription);
      await loadPrescriptions();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePrescription(String prescriptionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _prescriptionRepository.deletePrescription(prescriptionId);
      await loadPrescriptions();
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
