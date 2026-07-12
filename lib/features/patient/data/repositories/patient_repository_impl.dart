import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/patient_repository.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> _uploadProfileImage(String patientId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('patient_profiles').child('$patientId.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = await ref.putData(imageBytes, metadata);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to upload patient photo to cloud storage.');
    }
  }

  @override
  Future<List<PatientModel>> getPatients() async {
    try {
      final query = await _firestore.collection(AppConstants.colPatients).get();
      return query.docs.map((doc) => PatientModel.fromMap(doc.data(), doc.id)).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve patients directory.');
    }
  }

  @override
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      final doc = await _firestore.collection(AppConstants.colPatients).doc(patientId).get();
      if (doc.exists && doc.data() != null) {
        return PatientModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to retrieve patient details.');
    }
  }

  @override
  Future<void> createPatient(PatientModel patient, {Uint8List? imageBytes, String? imageName}) async {
    try {
      String? imageUrl = patient.profileImage;
      
      if (imageBytes != null) {
        imageUrl = await _uploadProfileImage(patient.patientId, imageBytes);
      }

      final patientWithImage = patient.copyWith(
        profileImage: imageUrl,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.colPatients)
          .doc(patient.patientId)
          .set(patientWithImage.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to create patient record.');
    }
  }

  @override
  Future<void> updatePatient(PatientModel patient, {Uint8List? imageBytes, String? imageName}) async {
    try {
      String? imageUrl = patient.profileImage;
      
      if (imageBytes != null) {
        imageUrl = await _uploadProfileImage(patient.patientId, imageBytes);
      }

      final patientWithImage = patient.copyWith(
        profileImage: imageUrl,
      );

      await _firestore
          .collection(AppConstants.colPatients)
          .doc(patient.patientId)
          .update(patientWithImage.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to update patient record.');
    }
  }

  @override
  Future<void> deletePatient(String patientId) async {
    try {
      await _firestore.collection(AppConstants.colPatients).doc(patientId).delete();
      
      try {
        final ref = _storage.ref().child('patient_profiles').child('$patientId.jpg');
        await ref.delete();
      } catch (_) {
        // Silent catch if storage link is empty
      }
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw Exception('Failed to remove patient record.');
    }
  }

  Exception _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Security rules violation: Access denied to patient files.');
      case 'unavailable':
        return Exception('Database service is offline. Please check your network connection.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred in Cloud Firestore.');
    }
  }
}
