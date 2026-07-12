import 'package:flutter/material.dart';
import '../../data/models/medicine_model.dart';
import '../../domain/repositories/medicine_repository.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineRepository _medicineRepository;
  final List<MedicineModel> _medicines = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<MedicineModel> get allMedicines => _medicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  MedicineProvider(this._medicineRepository) {
    loadMedicines();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<MedicineModel> get medicines {
    if (_searchQuery.trim().isEmpty) {
      return _medicines;
    }
    return _medicines.where((med) {
      return med.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          med.manufacturer.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> loadMedicines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _medicineRepository.getMedicines();

      if (list.isEmpty) {
        await _seedMedicines();
        list = await _medicineRepository.getMedicines();
      }

      _medicines.clear();
      _medicines.addAll(list);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedMedicines() async {
    final seed = [
      MedicineModel(
        medicineId: 'med_1',
        name: 'Amoxicillin',
        manufacturer: 'Pfizer Inc.',
        dosage: '500mg',
        stock: 120,
        price: 15.0,
        category: 'Antibiotics',
        type: 'Capsule',
      ),
      MedicineModel(
        medicineId: 'med_2',
        name: 'Paracetamol',
        manufacturer: 'GlaxoSmithKline',
        dosage: '650mg',
        stock: 500,
        price: 5.0,
        category: 'Analgesics',
        type: 'Tablet',
      ),
      MedicineModel(
        medicineId: 'med_3',
        name: 'Atorvastatin',
        manufacturer: 'Merck & Co.',
        dosage: '20mg',
        stock: 90,
        price: 25.0,
        category: 'Cardiovascular',
        type: 'Tablet',
      ),
    ];
    for (var med in seed) {
      await _medicineRepository.createMedicine(med);
    }
  }

  Future<bool> deductStock(String medicineId, int quantity) async {
    try {
      final index = _medicines.indexWhere((m) => m.medicineId == medicineId);
      if (index != -1) {
        final med = _medicines[index];
        if (med.stock < quantity) {
          throw Exception('Insufficient inventory stock for ${med.name}. Available: ${med.stock}');
        }
        final updatedMed = med.copyWith(stock: med.stock - quantity);
        await _medicineRepository.updateMedicine(updatedMed);
        _medicines[index] = updatedMed;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> addMedicine(MedicineModel medicine) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _medicineRepository.createMedicine(medicine);
      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMedicine(MedicineModel medicine) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _medicineRepository.updateMedicine(medicine);
      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedicine(String medicineId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _medicineRepository.deleteMedicine(medicineId);
      await loadMedicines();
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
