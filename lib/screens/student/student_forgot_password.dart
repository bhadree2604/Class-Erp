import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';

/// Student forgot password — mirror of `student/forgot-password.html`.
class StudentForgotPasswordScreen extends StatefulWidget {
  const StudentForgotPasswordScreen({super.key});

  @override
  State<StudentForgotPasswordScreen> createState() =>
      _StudentForgotPasswordScreenState();
}

class _StudentForgotPasswordScreenState extends State<StudentForgotPasswordScreen> {
  final _studentIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _handleReset() {
    final studentId = _studentIdCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (studentId.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Password reset link has been sent to $email. Please check your email.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: AppCard(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/rit_logo.jpg', height: 80, width: 80, fit: BoxFit.contain),
                    const SizedBox(height: 24),
                    Text('Reset Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                    const SizedBox(height: 8),
                    Text('Enter your Student ID to receive password reset instructions', textAlign: TextAlign.center, style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                    const SizedBox(height: 32),
                    Align(alignment: Alignment.centerLeft, child: Text('Student ID', style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary, fontSize: 14))),
                    const SizedBox(height: 6),
                    TextField(controller: _studentIdCtrl, decoration: const InputDecoration(hintText: 'Enter your student ID')),
                    const SizedBox(height: 16),
                    Align(alignment: Alignment.centerLeft, child: Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary, fontSize: 14))),
                    const SizedBox(height: 6),
                    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Enter your registered email')),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _handleReset, child: const Text('Send Reset Link')),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                          child: const Text('Back to Login'),
                        ),
                        Text(' | ', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.studentCreateAccount),
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}