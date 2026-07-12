import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../models/doctor_model.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> _uploadProfileImage(String doctorId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('doctor_profiles').child('$doctorId.jpg');
      
      // Upload using metadata for proper content rendering
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = await ref.putData(imageBytes, metadata);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to upload profile photo to cloud storage.');
    }
  }

  @override
  Future<List<DoctorModel>> getDoctors() async {
    try {
      final query = await _firestore.collection(AppConstants.colDoctors).get();
      return query.docs.map((doc) => DoctorModel.fromMap(doc.data(), doc.id)).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve doctors directory.');
    }
  }

  @override
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final doc = await _firestore.collection(AppConstants.colDoctors).doc(doctorId).get();
      if (doc.exists && doc.data() != null) {
        return DoctorModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve doctor details.');
    }
  }

  @override
  Future<void> createDoctor(DoctorModel doctor, {Uint8List? imageBytes, String? imageName}) async {
    try {
      String? imageUrl = doctor.profileImage;
      
      if (imageBytes != null) {
        imageUrl = await _uploadProfileImage(doctor.doctorId, imageBytes);
      }

      final docWithImage = doctor.copyWith(
        profileImage: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.colDoctors)
          .doc(doctor.doctorId)
          .set(docWithImage.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to create doctor record.');
    }
  }

  @override
  Future<void> updateDoctor(DoctorModel doctor, {Uint8List? imageBytes, String? imageName}) async {
    try {
      String? imageUrl = doctor.profileImage;
      
      if (imageBytes != null) {
        imageUrl = await _uploadProfileImage(doctor.doctorId, imageBytes);
      }

      final docWithImage = doctor.copyWith(
        profileImage: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.colDoctors)
          .doc(doctor.doctorId)
          .update(docWithImage.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to update doctor record.');
    }
  }

  @override
  Future<void> deleteDoctor(String doctorId) async {
    try {
      // Delete document
      await _firestore.collection(AppConstants.colDoctors).doc(doctorId).delete();
      
      // Delete image in storage if present
      try {
        final ref = _storage.ref().child('doctor_profiles').child('$doctorId.jpg');
        await ref.delete();
      } catch (_) {
        // Fail silently if image doesn't exist in storage
      }
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to remove doctor record.');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Security rules violation: Access denied to doctor records.');
      case 'unavailable':
        return Exception('The database service is offline. Please check your network connection.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred in Cloud Firestore.');
    }
  }
}
