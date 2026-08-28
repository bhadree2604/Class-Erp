import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/auth_service.dart';

/// Dark-themed unified login for students and mentors.
/// Supports college email/password plus "Continue with Google" (matched
/// against existing local accounts by email — never creates accounts).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;
  String? _error;

  // Dark palette for the login screen.
  static const _bg = Color(0xFF0C1116);
  static const _card = Color(0xFF161D26);
  static const _fieldBg = Color(0xFF1E2731);
  static const _border = Color(0xFF2E3A47);
  static const _mutedText = Color(0xFF8B97A5);
  static const _lightText = Color(0xFFF2F5F9);
  static const _errorBoxBg = Color(0xFF2A1517);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateAs(User user) {
    String destination;
    if (user.isStudent) {
      destination = AppRoutes.studentDashboard;
    } else if (user.isMentor) {
      destination = AppRoutes.mentorDashboard;
    } else if (user.isAdmin) {
      destination = AppRoutes.adminDashboard;
    } else {
      destination = AppRoutes.login; // fallback
    }

    Navigator.of(context).pushNamedAndRemoveUntil(destination, (route) => false);
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter college email and password.');
      return;
    }

    // Validate email format for non-admin (case-insensitive admin check)
    if (username.toLowerCase() != 'admin' && !RegExp(r'^[\w\-]+@ritrjpm\.ac\.in$').hasMatch(username)) {
      setState(() {
        _loading = false;
        _error = 'Enter a valid college email';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final user = await AuthService.instance.login(username, password);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Wrong username or password.';
      });
      return;
    }

    _navigateAs(user);
  }

  /// Firebase-backed Google sign-in: authenticates via Google + Firebase Auth,
  /// then matches the verified email against existing local accounts.
  /// No new account is ever created from a Google identity.
  Future<void> _handleGoogleSignIn() async {
    if (_googleLoading || _loading) return;
    setState(() {
      _googleLoading = true;
      _error = null;
    });

    try {
      final email = await AuthService.instance.signInWithGoogle();

      if (!mounted) return;

      final user = await AuthService.instance.findUserByEmail(email);

      if (user == null) {
        // No matching local account — sign the Firebase user back out.
        await AuthService.instance.signOutFirebase();
        setState(() {
          _googleLoading = false;
          _error =
              'No account found for this email ($email). Please sign in with your college email or contact your admin.';
        });
        return;
      }

      await AuthService.instance.saveCurrentUser(user);
      if (!mounted) return;
      _navigateAs(user);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _googleLoading = false;
        _error = e.toString().contains('MissingPluginException')
            ? 'Google sign-in is not available on this device/platform.'
            : 'Google sign-in failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: _bg,
          image: const DecorationImage(
            image: AssetImage('assets/rit_clg_photo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
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
                          width: 72,
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _lightText,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Please login to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _mutedText, fontSize: 14),
                      ),
                      const SizedBox(height: 28),

                      // ---- Continue with Google ----
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              (_loading || _googleLoading) ? null : _handleGoogleSignIn,
                          icon: _googleLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const _GoogleGLogo(size: 20),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1F2937),
                            disabledBackgroundColor: Colors.white70,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        _buildErrorBox(_error!),
                        const SizedBox(height: 16),
                      ],

                      // ---- Email / Password ----
                      _buildField(
                        controller: _usernameController,
                        label: 'Email',
                        hint: 'Enter your college email',
                        obscure: false,
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscure: _obscurePassword,
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _mutedText,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ---- Sign in ----
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_loading || _googleLoading)
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF111827),
                            disabledBackgroundColor: Colors.white70,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: (_loading || _googleLoading)
                            ? null
                            : () => _showRoleChoiceDialog(
                                  context,
                                  'Forgot Password?',
                                  'Are you a Student or Mentor?',
                                  onStudent: () =>
                                      Navigator.of(context).pushNamed(AppRoutes.studentForgotPassword),
                                  onMentor: () =>
                                      Navigator.of(context).pushNamed(AppRoutes.mentorForgotPassword),
                                ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: _mutedText),
                        ),
                      ),
                      TextButton(
                        onPressed: (_loading || _googleLoading)
                            ? null
                            : () => _showRoleChoiceDialog(
                                  context,
                                  'Create Account',
                                  'Are you a Student or Mentor?',
                                  onStudent: () =>
                                      Navigator.of(context).pushNamed(AppRoutes.studentCreateAccount),
                                  onMentor: () =>
                                      Navigator.of(context).pushNamed(AppRoutes.mentorCreateAccount),
                                ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Color(0xFF60A5FA),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: _border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR WITH EMAIL',
            style: TextStyle(
              color: _mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const Expanded(child: Divider(color: _border, thickness: 1)),
      ],
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _errorBoxBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDC2626), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: Color(0xFFF87171)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRoleChoiceDialog(
    BuildContext context,
    String title,
    String message, {
    required VoidCallback onStudent,
    required VoidCallback onMentor,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _lightText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mutedText, fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onStudent();
                    },
                    icon: const Icon(Icons.school_outlined, size: 20),
                    label: const Text('Student'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: _border),
                      foregroundColor: _lightText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onMentor();
                    },
                    icon: const Icon(Icons.person_outline, size: 20),
                    label: const Text('Mentor'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: _mutedText, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required IconData icon,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _lightText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: _lightText),
          cursorColor: const Color(0xFF60A5FA),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _mutedText),
            prefixIcon: Icon(icon, color: _mutedText, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: _fieldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
          onSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }
}

/// The four-colour Google "G", drawn so no image asset is needed.
class _GoogleGLogo extends StatelessWidget {
  final double size;

  const _GoogleGLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleGPainter(),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.38;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    Paint arc(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color;

    double rad(double degrees) => degrees * 3.141592653589793 / 180.0;

    // Ring segments (canvas angles are clockwise, 0 = 3 o'clock).
    canvas.drawArc(rect, rad(-42.5), rad(85), false, arc(_blue)); // right
    canvas.drawArc(rect, rad(42.5), rad(95), false, arc(_green)); // bottom
    canvas.drawArc(rect, rad(137.5), rad(95), false, arc(_yellow)); // left
    canvas.drawArc(rect, rad(232.5), rad(85), false, arc(_red)); // top

    // Horizontal bar of the G, from centre to the right edge.
    final center = rect.center;
    canvas.drawRect(
      Rect.fromLTRB(center.dx, center.dy - stroke / 2, size.width,
          center.dy + stroke / 2),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}