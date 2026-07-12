import '../../data/models/bill_model.dart';

abstract class BillRepository {
  Future<List<BillModel>> getBills();
  Future<BillModel?> getBillById(String billId);
  Future<void> createBill(BillModel bill);
  Future<void> updateBill(BillModel bill);
  Future<void> deleteBill(String billId);
}
