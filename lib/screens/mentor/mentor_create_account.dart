import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

class MentorCreateAccountScreen extends StatefulWidget {
  const MentorCreateAccountScreen({super.key});

  @override
  State<MentorCreateAccountScreen> createState() =>
      _MentorCreateAccountScreenState();
}

class _MentorCreateAccountScreenState extends State<MentorCreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  String _selectedDepartment = '';
  String _generatedId = '';

  static const _departments = {
    'Computer Science': '104',
    'Information Technology': '105',
    'Electronics': '106',
    'Mechanical': '107',
    'Civil': '108',
    'Electrical': '109',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _designationCtrl.dispose();
    _qualificationCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  void _generateMentorId() {
    if (_selectedDepartment.isEmpty) {
      setState(() => _generatedId = '');
      return;
    }
    final deptCode = _departments[_selectedDepartment];
    final year = DateTime.now().year.toString().substring(2);
    // simple placeholder ID; could be improved with sequence
    setState(() => _generatedId = 'M$year${deptCode}001');
  }

  Future<void> _handleCreate() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _selectedDepartment.isEmpty ||
        _designationCtrl.text.isEmpty ||
        _qualificationCtrl.text.isEmpty ||
        _experienceCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_generatedId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select department to generate ID'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_passwordCtrl.text != _confirmPwdCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters!'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final userData = {
      'user_id': _generatedId,
      'username': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'email': _emailCtrl.text.trim(),
      'full_name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'user_type': 'mentor',
      'department': _selectedDepartment,
      'designation': _designationCtrl.text.trim(),
      'qualification': _qualificationCtrl.text.trim(),
      'experience': _experienceCtrl.text.trim(),
    };

    final error = await AuthService.instance.createUser(userData);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created successfully! Your Mentor ID: $_generatedId'), behavior: SnackBarBehavior.floating),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
                  constraints: const BoxConstraints(maxWidth: 560),
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
                        const SizedBox(height: 24),
                        Text(
                          'Create Mentor Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColorsExtension.of(context).textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in your details to create a new account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColorsExtension.of(context).textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Full Name *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(hintText: 'Enter your full name'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Department *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDepartment.isEmpty ? null : _selectedDepartment,
                          decoration: const InputDecoration(hintText: 'Select Department'),
                          items: _departments.keys.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                          onChanged: (v) {
                            setState(() => _selectedDepartment = v ?? '');
                            _generateMentorId();
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Generated Mentor ID',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: _generatedId.isEmpty ? 'Will be auto-generated' : _generatedId,
                            filled: true,
                            fillColor: AppColorsExtension.of(context).bgSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email Address *',
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
                          decoration: const InputDecoration(hintText: 'your.email@rit.edu'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Phone Number *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: '+91 98765 43210'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Designation *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _designationCtrl,
                          decoration: const InputDecoration(hintText: 'e.g., Professor'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Qualification *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _qualificationCtrl,
                          decoration: const InputDecoration(hintText: 'e.g., Ph.D, M.Tech'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Experience (years) *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _experienceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'e.g., 5'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(hintText: 'Min 6 characters'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Confirm Password *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _confirmPwdCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(hintText: 'Re-enter password'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleCreate,
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
                            child: const Text('Create Account'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                          child: const Text('Already have an account? Login'),
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