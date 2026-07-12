import 'package:flutter/material.dart';
import '../../data/models/medicine_model.dart';
import '../../domain/repositories/medicine_repository.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineRepository _medicineRepository;
  final List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<MedicineModel> get medicines {
    if (_searchQuery.isEmpty) {
      return _medicines;
    }
    return _medicines
        .where((med) =>
            med.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            med.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MedicineProvider(this._medicineRepository) {
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _medicineRepository.getMedicines();
      
      // If collection is empty, seed mock medicines
      if (list.isEmpty) {
        await _seedMedicines();
        list = await _medicineRepository.getMedicines();
      }

      _medicines.clear();
      _medicines.addAll(list);
    } catch (e) {
      _errorMessage = 'Failed to load medicines: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedMedicines() async {
    final mockMeds = [
      MedicineModel(
        id: 'med_1',
        name: 'Amoxicillin 500mg',
        category: 'Antibiotic',
        type: 'Capsule',
        stockStatus: 'In Stock',
        dosageInstructions: '3 times daily after meals',
      ),
      MedicineModel(
        id: 'med_2',
        name: 'Atorvastatin 20mg',
        category: 'Cardiovascular',
        type: 'Tablet',
        stockStatus: 'In Stock',
        dosageInstructions: '1 tablet at bedtime',
      ),
      MedicineModel(
        id: 'med_3',
        name: 'Metformin 850mg',
        category: 'Antidiabetic',
        type: 'Tablet',
        stockStatus: 'Low Stock',
        dosageInstructions: '2 times daily with breakfast & dinner',
      ),
      MedicineModel(
        id: 'med_4',
        name: 'Albuterol Inhaler',
        category: 'Respiratory',
        type: 'Inhaler',
        stockStatus: 'In Stock',
        dosageInstructions: '2 puffs every 4-6 hours as needed',
      ),
      MedicineModel(
        id: 'med_5',
        name: 'Ibuprofen 400mg',
        category: 'Analgesic',
        type: 'Tablet',
        stockStatus: 'Out of Stock',
        dosageInstructions: '1 tablet every 6 hours as needed for pain',
      ),
    ];
    for (var med in mockMeds) {
      await _medicineRepository.createMedicine(med);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addMedicine(MedicineModel medicine) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _medicineRepository.createMedicine(medicine);
      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMedicine(MedicineModel medicine) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _medicineRepository.updateMedicine(medicine);
      await loadMedicines();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedicine(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _medicineRepository.deleteMedicine(id);
      await loadMedicines();
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
