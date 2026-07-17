import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
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

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailVerified => _currentUser?.isVerified ?? false;

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
