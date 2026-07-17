import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading spinner while retrieving session state
    if (!authProvider.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Direct routing
    if (authProvider.isAuthenticated) {
      if (authProvider.isEmailVerified) {
        return const DashboardScreen();
      } else {
        return const EmailVerificationScreen();
      }
    } else {
      return const LoginScreen();
    }
  }
}
