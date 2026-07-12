import 'package:flutter/material.dart';
import '../../data/models/bill_model.dart';
import '../../domain/repositories/bill_repository.dart';

class BillProvider extends ChangeNotifier {
  final BillRepository _billRepository;
  final List<BillModel> _bills = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'All'; // All, Paid, Pending

  List<BillModel> get allBills => _bills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  BillProvider(this._billRepository) {
    loadBills();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  List<BillModel> get bills {
    List<BillModel> filtered = _bills;

    // Status filter
    if (_statusFilter != 'All') {
      filtered = filtered.where((b) => b.status == _statusFilter).toList();
    }

    // Search filter
    if (_searchQuery.trim().isNotEmpty) {
      filtered = filtered.where((b) {
        return (b.patientName ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Future<void> loadBills() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var list = await _billRepository.getBills();

      if (list.isEmpty) {
        await _seedBills();
        list = await _billRepository.getBills();
      }

      _bills.clear();
      _bills.addAll(list);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedBills() async {
    final seed = [
      BillModel(
        billId: 'bill_1',
        patientId: 'pat_1',
        appointmentId: 'app_1',
        doctorFee: 150.0,
        medicineFee: 45.0,
        labFee: 80.0,
        total: 275.0,
        paymentMethod: 'Card',
        status: 'Paid',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        patientName: 'Jane Smith',
        doctorName: 'Dr. Sarah Jenkins',
      ),
      BillModel(
        billId: 'bill_2',
        patientId: 'pat_2',
        appointmentId: 'app_2',
        doctorFee: 120.0,
        medicineFee: 15.0,
        labFee: 0.0,
        total: 135.0,
        paymentMethod: 'Cash',
        status: 'Pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        patientName: 'John Miller',
        doctorName: 'Dr. Michael Chen',
      ),
    ];
    for (var bill in seed) {
      await _billRepository.createBill(bill);
    }
  }

  Future<bool> generateBill(BillModel bill) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _billRepository.createBill(bill);
      await loadBills();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsPaid(String billId, String paymentMethod) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _bills.indexWhere((b) => b.billId == billId);
      if (index != -1) {
        final updated = _bills[index].copyWith(
          status: 'Paid',
          paymentMethod: paymentMethod,
        );
        await _billRepository.updateBill(updated);
        await loadBills();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsPending(String billId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _bills.indexWhere((b) => b.billId == billId);
      if (index != -1) {
        final updated = _bills[index].copyWith(status: 'Pending');
        await _billRepository.updateBill(updated);
        await loadBills();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBill(String billId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _billRepository.deleteBill(billId);
      await loadBills();
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
