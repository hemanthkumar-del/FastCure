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
      AppLogger.info('Firestore user lookup started: UID=${firebaseUser.uid}');
      final doc = await _firestore
          .collection(AppConstants.colUsers)
          .doc(firebaseUser.uid)
          .get();
      AppLogger.info('Firestore user lookup completed: exists=${doc.exists}');

      if (doc.exists && doc.data() != null) {
        // Sync isVerified state directly from Auth to firestore if it changed
        final isVerifiedAuth = firebaseUser.emailVerified;
        final model = UserModel.fromMap(doc.data()!, firebaseUser.uid);
        
        if (model.isVerified != isVerifiedAuth) {
          final updatedModel = model.copyWith(isVerified: isVerifiedAuth);
          AppLogger.info('Firestore write started: syncing isVerified state');
          await _firestore
              .collection(AppConstants.colUsers)
              .doc(firebaseUser.uid)
              .update({'isVerified': isVerifiedAuth});
          AppLogger.info('Firestore write completed');
          return updatedModel;
        }
        return model;
      } else {
        AppLogger.warning('Firestore user document not found for UID: ${firebaseUser.uid}. Generating fallback UserModel.');
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
    } catch (e, stackTrace) {
      AppLogger.error('Error mapping Firebase user details from Firestore: $e\n$stackTrace');
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
    AppLogger.info('Login started: email=$email');
    try {
      AppLogger.info('FirebaseAuth request sent: signInWithEmailAndPassword');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      AppLogger.info('FirebaseAuth response received: UID=${credential.user?.uid}');

      if (credential.user != null) {
        // Update lastLogin timestamp in Firestore
        final now = DateTime.now();
        AppLogger.info('Firestore write started: update lastLogin/isVerified for ${credential.user!.uid}');
        await _firestore
            .collection(AppConstants.colUsers)
            .doc(credential.user!.uid)
            .update({
          'lastLogin': Timestamp.fromDate(now),
          'isVerified': credential.user!.emailVerified,
        });
        AppLogger.info('Firestore write completed');

        AppLogger.info('Firestore user lookup started');
        final userModel = await _mapFirebaseUser(credential.user);
        AppLogger.info('Firestore user lookup completed');
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('FirebaseAuthException in signInWithEmail: ${e.code} - ${e.message}\n$stackTrace');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Generic Exception in signInWithEmail: $e\n$stackTrace');
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
    AppLogger.info('SignUp started: email=$email, fullName=$fullName, role=$role');
    try {
      AppLogger.info('FirebaseAuth request sent: createUserWithEmailAndPassword');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      AppLogger.info('FirebaseAuth response received: UID=${credential.user?.uid}');

      if (credential.user != null) {
        AppLogger.info('FirebaseAuth request sent: updateDisplayName');
        await credential.user!.updateDisplayName(fullName);
        AppLogger.info('FirebaseAuth display name updated');

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
        AppLogger.info('Firestore write started: create user document');
        await _firestore
            .collection(AppConstants.colUsers)
            .doc(credential.user!.uid)
            .set(newUser.toMap());
        AppLogger.info('Firestore write completed');

        // Trigger verification email automatically
        AppLogger.info('FirebaseAuth request sent: sendEmailVerification');
        await credential.user!.sendEmailVerification();
        AppLogger.info('FirebaseAuth email verification sent');

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('FirebaseAuthException in signUpWithEmail: ${e.code} - ${e.message}\n$stackTrace');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Generic Exception in signUpWithEmail: $e\n$stackTrace');
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    AppLogger.info('Google Sign-In started');
    try {
      AppLogger.info('GoogleSignIn requesting interactive dialog');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        AppLogger.info('Google Sign-In cancelled by user');
        return null; 
      }
      AppLogger.info('GoogleSignIn account selected: ${googleUser.email}');

      AppLogger.info('GoogleSignIn retrieving authentication details');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      AppLogger.info('FirebaseAuth request sent: signInWithCredential');
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      AppLogger.info('FirebaseAuth response received: UID=${firebaseUser?.uid}');

      if (firebaseUser != null) {
        final now = DateTime.now();

        // Check if user document already exists
        AppLogger.info('Firestore user lookup started');
        final doc = await _firestore
            .collection(AppConstants.colUsers)
            .doc(firebaseUser.uid)
            .get();
        AppLogger.info('Firestore user lookup completed: exists=${doc.exists}');

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
          AppLogger.info('Firestore write started: create user document for Google user');
          await _firestore
              .collection(AppConstants.colUsers)
              .doc(firebaseUser.uid)
              .set(newUser.toMap());
          AppLogger.info('Firestore write completed');
          return newUser;
        } else {
          // Document exists, update lastLogin & verification status
          AppLogger.info('Firestore write started: update lastLogin/isVerified for Google user');
          await _firestore
              .collection(AppConstants.colUsers)
              .doc(firebaseUser.uid)
              .update({
            'lastLogin': Timestamp.fromDate(now),
            'isVerified': true,
          });
          AppLogger.info('Firestore write completed');
          return await _mapFirebaseUser(firebaseUser);
        }
      }
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('FirebaseAuthException in signInWithGoogle: ${e.code} - ${e.message}\n$stackTrace');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Google Sign-In Error: $e\n$stackTrace');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    AppLogger.info('Password reset requested for email=$email');
    try {
      AppLogger.info('FirebaseAuth request sent: sendPasswordResetEmail');
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      AppLogger.info('FirebaseAuth password reset email sent successfully');
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('FirebaseAuthException in resetPassword: ${e.code} - ${e.message}\n$stackTrace');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Generic Exception in resetPassword: $e\n$stackTrace');
      throw Exception('Failed to send password reset link.');
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    AppLogger.info('Email verification requested');
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        AppLogger.info('FirebaseAuth request sent: sendEmailVerification');
        await user.sendEmailVerification();
        AppLogger.info('FirebaseAuth email verification sent successfully');
      } else {
        AppLogger.warning('No logged-in user available to send verification email');
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('FirebaseAuthException in sendVerificationEmail: ${e.code} - ${e.message}\n$stackTrace');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Generic Exception in sendVerificationEmail: $e\n$stackTrace');
      throw Exception('Failed to send email verification link.');
    }
  }

  @override
  Future<void> signOut() async {
    AppLogger.info('Logout started');
    try {
      AppLogger.info('FirebaseAuth/GoogleSignIn signing out');
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      AppLogger.info('Logout completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error during sign-out: $e\n$stackTrace');
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
