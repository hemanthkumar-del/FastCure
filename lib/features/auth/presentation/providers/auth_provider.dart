import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  StreamSubscription<UserModel?>? _authSubscription;
  bool _isUploading = false;
  double? _uploadProgress;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _currentUser?.isVerified ?? false;
  bool get isUploading => _isUploading;
  double? get uploadProgress => _uploadProgress;

  AuthProvider(this._authRepository) {
    _init();
  }

  Future<void> _init() async {
    try {
      final cachedUser = await _loadLocalUser();
      final firebaseCurrentUser = fb.FirebaseAuth.instance.currentUser;
      
      if (firebaseCurrentUser != null && cachedUser != null && firebaseCurrentUser.uid == cachedUser.uid) {
        _currentUser = cachedUser;
      } else if (firebaseCurrentUser == null) {
        await _clearLocalUser();
        _currentUser = null;
      }
    } catch (e) {
      AppLogger.error('Shared preferences auth initialization error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }

    _authSubscription = _authRepository.onAuthStateChanged.listen((user) async {
      if (user != null) {
        if (_currentUser != null && _currentUser!.uid == user.uid && _currentUser!.role != 'Patient' && user.role == 'Patient') {
          user = user.copyWith(role: _currentUser!.role);
        }
        _currentUser = user;
        await _saveLocalUser(user);
      } else {
        _currentUser = null;
        await _clearLocalUser();
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _saveLocalUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_role', user.role);
    await prefs.setString('cached_user_uid', user.uid);
    await prefs.setString('cached_user_email', user.email);
    await prefs.setString('cached_user_name', user.fullName);
    await prefs.setBool('cached_user_verified', user.isVerified);
    if (user.photoUrl != null) {
      await prefs.setString('cached_user_photo', user.photoUrl!);
    } else {
      await prefs.remove('cached_user_photo');
    }
  }

  Future<void> _clearLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user_role');
    await prefs.remove('cached_user_uid');
    await prefs.remove('cached_user_email');
    await prefs.remove('cached_user_name');
    await prefs.remove('cached_user_verified');
    await prefs.remove('cached_user_photo');
  }

  Future<UserModel?> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('cached_user_uid');
    final role = prefs.getString('cached_user_role');
    if (uid != null && role != null) {
      return UserModel(
        uid: uid,
        role: role,
        email: prefs.getString('cached_user_email') ?? '',
        fullName: prefs.getString('cached_user_name') ?? '',
        isVerified: prefs.getBool('cached_user_verified') ?? false,
        photoUrl: prefs.getString('cached_user_photo'),
      );
    }
    return null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signInWithEmail(email, password);
      if (_currentUser != null) {
        await _saveLocalUser(_currentUser!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
      );
      if (_currentUser != null) {
        await _saveLocalUser(_currentUser!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signInWithGoogle();
      if (_currentUser != null) {
        await _saveLocalUser(_currentUser!);
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendVerificationEmail() async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendVerificationEmail();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> reloadUser() async {
    // Reloads native FirebaseAuth state to check if email was verified
    try {
      final user = fb.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        _currentUser = await _authRepository.getCurrentUser();
        if (_currentUser != null) {
          await _saveLocalUser(_currentUser!);
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> completeOnboarding(String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(role: role, isVerified: true);
        await _authRepository.createUserProfile(updatedUser);
        _currentUser = updatedUser;
        await _saveLocalUser(updatedUser);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<bool> uploadProfilePicture(String filePath) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $filePath');
      }

      final sizeInBytes = await file.length();
      if (sizeInBytes > 5 * 1024 * 1024) {
        throw Exception('Image size exceeds the 5 MB limit.');
      }

      final uid = _currentUser!.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final progressCompleter = Completer<void>();
      late StreamSubscription<TaskSnapshot> subscription;
      
      subscription = uploadTask.snapshotEvents.listen(
        (snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          _uploadProgress = progress.clamp(0.0, 1.0);
          notifyListeners();
        },
        onError: (e) {
          progressCompleter.completeError(e);
        },
        onDone: () {
          progressCompleter.complete();
        },
      );

      await uploadTask.whenComplete(() {}).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Upload timed out. Please check your network connection.');
        },
      );
      await progressCompleter.future;
      await subscription.cancel();

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'photoUrl': downloadUrl});

      final updatedUser = _currentUser!.copyWith(photoUrl: downloadUrl);
      _currentUser = updatedUser;
      await _saveLocalUser(updatedUser);

      _uploadProgress = null;
      _isUploading = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _uploadProgress = null;
      _isUploading = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeProfilePicture() async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _currentUser!.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      try {
        await storageRef.delete();
      } catch (e) {
        AppLogger.warning('Profile picture delete from storage failed/ignored: $e');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'photoUrl': null});

      _currentUser = UserModel(
        uid: _currentUser!.uid,
        fullName: _currentUser!.fullName,
        email: _currentUser!.email,
        role: _currentUser!.role,
        photoUrl: null,
        phoneNumber: _currentUser!.phoneNumber,
        createdAt: _currentUser!.createdAt,
        isVerified: _currentUser!.isVerified,
        lastLogin: _currentUser!.lastLogin,
      );

      await _saveLocalUser(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      await _clearLocalUser();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
