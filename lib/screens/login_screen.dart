import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/auth_service.dart';
import '../theme.dart';

/// Login screen — mirror of `student/index.html` / `mentor/index.html`.
/// Expects a role argument: 'student' | 'mentor'.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  late String _role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'student';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isStudent => _role == 'student';

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter username and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final user = await AuthService.instance.login(username, password, _role);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Wrong username or password.';
      });
      return;
    }

    final destination = _isStudent
        ? AppRoutes.studentDashboard
        : AppRoutes.mentorDashboard;

    Navigator.of(context).pushNamedAndRemoveUntil(destination, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _isStudent;

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
            child: Stack(
              children: [
                Center(
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
                              _isStudent ? 'Student Login' : 'Mentor Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColorsExtension.of(context).textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Please login to continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColorsExtension.of(context).textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_error != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                margin: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  border: const Border(
                                    left: BorderSide(
                                        color: AppColors.accent, width: 3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.15),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        size: 16, color: AppColors.accent),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: AppColors.errorFg,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            _buildField(
                              controller: _usernameController,
                              label: 'Username',
                              hint: 'Enter your username',
                              obscure: false,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              obscure: true,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isStudent
                                      ? const Color(0xFF1d4ed8)
                                      : const Color(0xFF2e7d32),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('LOGIN'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          Navigator.of(context).pushNamed(
                                            isStudent
                                                ? AppRoutes.studentForgotPassword
                                                : AppRoutes.mentorForgotPassword,
                                          );
                                        },
                                  child: const Text('Forgot Password?'),
                                ),
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          Navigator.of(context).pushNamed(
                                            isStudent
                                                ? AppRoutes.studentCreateAccount
                                                : AppRoutes.mentorCreateAccount,
                                          );
                                        },
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
                Positioned(
                  top: 20,
                  right: 20,
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    elevation: 8,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Text(
                          '\u2190 Back to Home',
                          style: TextStyle(
                            color: AppColorsExtension.of(context).textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColorsExtension.of(context).textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColorsExtension.of(context).textLight),
          ),
          onSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }
}