import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../theme.dart';

/// Mentor forgot password — mirror of `mentor/forgot-password.html`.
class MentorForgotPasswordScreen extends StatefulWidget {
  const MentorForgotPasswordScreen({super.key});

  @override
  State<MentorForgotPasswordScreen> createState() =>
      _MentorForgotPasswordScreenState();
}

class _MentorForgotPasswordScreenState extends State<MentorForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _handleReset() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your college email'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final emailRegExp = RegExp(r'^[\w\-]+@ritrjpm\.ac\.in$');
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid college email'), behavior: SnackBarBehavior.floating),
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
          image: DecorationImage(
            image: AssetImage('assets/rit_clg_photo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 40,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/rit_logo.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Forgot Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColorsExtension.of(context).textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your college email to receive password reset instructions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColorsExtension.of(context).textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'College Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'Enter your college email'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1d4ed8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                            child: const Text('Send Reset Link'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                              child: const Text('Back to Login'),
                            ),
                            Text(
                              ' | ',
                              style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pushReplacementNamed(AppRoutes.mentorCreateAccount),
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
        ),
      ),
    );
  }
}
