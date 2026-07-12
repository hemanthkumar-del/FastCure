import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/bill_repository.dart';
import '../models/bill_model.dart';

class BillRepositoryImpl implements BillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<BillModel>> getBills() async {
    try {
      final query = await _firestore.collection('bills').get();
      return query.docs.map((doc) => BillModel.fromMap(doc.data(), doc.id)).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve billing records.');
    }
  }

  @override
  Future<BillModel?> getBillById(String billId) async {
    try {
      final doc = await _firestore.collection('bills').doc(billId).get();
      if (doc.exists && doc.data() != null) {
        return BillModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve bill details.');
    }
  }

  @override
  Future<void> createBill(BillModel bill) async {
    try {
      final docWithTimestamp = bill.copyWith(
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('bills')
          .doc(bill.billId)
          .set(docWithTimestamp.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to generate billing record.');
    }
  }

  @override
  Future<void> updateBill(BillModel bill) async {
    try {
      await _firestore
          .collection('bills')
          .doc(bill.billId)
          .update(bill.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to update billing details.');
    }
  }

  @override
  Future<void> deleteBill(String billId) async {
    try {
      await _firestore.collection('bills').doc(billId).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to remove billing record.');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Security rules violation: Access denied to billing logs.');
      case 'unavailable':
        return Exception('Database service is offline. Please check your network connection.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred in Cloud Firestore.');
    }
  }
}
