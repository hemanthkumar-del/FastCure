import '../../data/models/user_model.dart';

abstract class AuthRepository {
  /// Stream of user authentication state changes to manage persistence.
  Stream<UserModel?> get onAuthStateChanged;

  /// Logs in a user using email and password.
  Future<UserModel?> signInWithEmail(String email, String password);

  /// Registers a new user and creates their Firestore record profile.
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phoneNumber,
  });

  /// Authenticates using Google Single Sign-On and maps user to Firestore.
  Future<UserModel?> signInWithGoogle();

  /// Sends a password reset email.
  Future<void> resetPassword(String email);

  /// Triggers a verification email request for the currently logged in user.
  Future<void> sendVerificationEmail();

  /// Logs out the user and clears sessions.
  Future<void> signOut();

  /// Gets the currently authenticated user's model from Firestore.
  Future<UserModel?> getCurrentUser();
}
