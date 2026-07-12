import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Helper to map firebase User to our custom UserModel
  Future<UserModel?> _mapFirebaseUser(User? firebaseUser) async {
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.colUsers)
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        // Sync isVerified state directly from Auth to firestore if it changed
        final isVerifiedAuth = firebaseUser.emailVerified;
        final model = UserModel.fromMap(doc.data()!, firebaseUser.uid);
        
        if (model.isVerified != isVerifiedAuth) {
          final updatedModel = model.copyWith(isVerified: isVerifiedAuth);
          await _firestore
              .collection(AppConstants.colUsers)
              .doc(firebaseUser.uid)
              .update({'isVerified': isVerifiedAuth});
          return updatedModel;
        }
        return model;
      } else {
        // Fallback user model if Firestore doc hasn't been created yet
        return UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'No Name',
          email: firebaseUser.email ?? '',
          role: 'Patient',
          photoUrl: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
          createdAt: DateTime.now(),
          isVerified: firebaseUser.emailVerified,
          lastLogin: DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('Error mapping Firebase user details from Firestore: $e');
      // If Firestore is offline or fails, return baseline info from Auth
      return UserModel(
        uid: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        role: 'Patient',
        photoUrl: firebaseUser.photoURL,
        phoneNumber: firebaseUser.phoneNumber,
        isVerified: firebaseUser.emailVerified,
      );
    }
  }

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      return await _mapFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update lastLogin timestamp in Firestore
        final now = DateTime.now();
        await _firestore
            .collection(AppConstants.colUsers)
            .doc(credential.user!.uid)
            .update({
          'lastLogin': Timestamp.fromDate(now),
          'isVerified': credential.user!.emailVerified,
        });

        return await _mapFirebaseUser(credential.user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed. Please check your network connection.');
    }
  }

  @override
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update Display Name in Auth profile
        await credential.user!.updateDisplayName(fullName);

        final now = DateTime.now();
        final newUser = UserModel(
          uid: credential.user!.uid,
          fullName: fullName,
          email: email.trim(),
          role: role,
          phoneNumber: phoneNumber,
          createdAt: now,
          isVerified: false,
          lastLogin: now,
        );

        // Save to users Firestore collection
        await _firestore
            .collection(AppConstants.colUsers)
            .doc(credential.user!.uid)
            .set(newUser.toMap());

        // Trigger verification email automatically
        await credential.user!.sendEmailVerification();

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final now = DateTime.now();

        // Check if user document already exists
        final doc = await _firestore
            .collection(AppConstants.colUsers)
            .doc(firebaseUser.uid)
            .get();

        if (!doc.exists) {
          // If first sign-in, create Firestore record automatically
          final newUser = UserModel(
            uid: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'Google User',
            email: firebaseUser.email ?? '',
            role: 'Patient',
            photoUrl: firebaseUser.photoURL,
            phoneNumber: firebaseUser.phoneNumber,
            createdAt: now,
            isVerified: true, // Google accounts are pre-verified
            lastLogin: now,
          );
          await _firestore
              .collection(AppConstants.colUsers)
              .doc(firebaseUser.uid)
              .set(newUser.toMap());
          return newUser;
        } else {
          // Document exists, update lastLogin & verification status
          await _firestore
              .collection(AppConstants.colUsers)
              .doc(firebaseUser.uid)
              .update({
            'lastLogin': Timestamp.fromDate(now),
            'isVerified': true,
          });
          return await _mapFirebaseUser(firebaseUser);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google Sign-In failed.');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset link.');
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send email verification link.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Logout failed.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return await _mapFirebaseUser(user);
  }

  // Map Firebase auth errors to human-friendly feedback messages
  Exception _handleAuthException(FirebaseAuthException e) {
    AppLogger.error('FirebaseAuth Error: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'invalid-email':
        return Exception('The email address is not formatted correctly.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'user-not-found':
        return Exception('No account exists with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return Exception('An account with this email address already exists.');
      case 'weak-password':
        return Exception('The password is too weak. Please use at least 6 characters.');
      case 'operation-not-allowed':
        return Exception('Sign-in provider is disabled in Firebase Console.');
      case 'network-request-failed':
        return Exception('A network connection error occurred. Please check your internet.');
      default:
        return Exception(e.message ?? 'An unknown authentication error occurred.');
    }
  }
}
