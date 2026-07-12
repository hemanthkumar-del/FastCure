import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .set(user.toMap());
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .update(user.toMap());
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .delete();
  }
}
