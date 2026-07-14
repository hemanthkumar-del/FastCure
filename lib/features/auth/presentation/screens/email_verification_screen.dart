import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/logger.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _canResend = false;
  int _secondsRemaining = 30;
  Timer? _cooldownTimer;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
    
    // Auto refresh every 4 seconds in background to detect verification
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkVerificationStatus();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 30;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.reloadUser();
    
    if (mounted && authProvider.isEmailVerified) {
      _autoRefreshTimer?.cancel();
      AppLogger.info('Navigation started: AppRoutes.dashboard (Email Verified)');
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
  }

  Future<void> _resendEmail() async {
    if (_canResend) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.resendVerificationEmail();
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email resent successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          _startCooldownTimer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to resend email.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _signOut() async {
    _autoRefreshTimer?.cancel();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = Provider.of<AuthProvider>(context).currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title & Info
              Text(
                'Verify Your Email Address',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We have sent a verification email to:',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please click the link in the email to activate your account. Once verified, you will be redirected automatically.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Checked Button
              CustomButton(
                text: 'Check Status Now',
                onPressed: _checkVerificationStatus,
              ),
              const SizedBox(height: 16),

              // Resend Button
              TextButton(
                onPressed: _canResend ? _resendEmail : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _canResend
                      ? 'Resend Verification Email'
                      : 'Resend Email in ${_secondsRemaining}s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _canResend ? theme.colorScheme.primary : theme.disabledColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
