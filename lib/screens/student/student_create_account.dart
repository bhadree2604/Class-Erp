import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

/// Student create account — mirror of `student/create-account.html`.
class StudentCreateAccountScreen extends StatefulWidget {
  const StudentCreateAccountScreen({super.key});

  @override
  State<StudentCreateAccountScreen> createState() =>
      _StudentCreateAccountScreenState();
}

class _StudentCreateAccountScreenState extends State<StudentCreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _studentNumCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  String _selectedDepartment = '';
  String _selectedSemester = '';
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
    _phoneCtrl.dispose();
    _studentNumCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  void _generateStudentId() {
    if (_selectedDepartment.isEmpty || _studentNumCtrl.text.isEmpty) {
      setState(() => _generatedId = '');
      return;
    }
    final deptCode = _departments[_selectedDepartment];
    final year = DateTime.now().year.toString().substring(2);
    final num = _studentNumCtrl.text.padLeft(3, '0');
    setState(() => _generatedId = '9536$year$deptCode$num');
  }

  String? _validateGeneratedId(String id) {
    if (id.isEmpty) {
      return 'Please generate a Student ID';
    }
    final RegExp regExp = RegExp(r'^9536\d{8}$');
    if (!regExp.hasMatch(id)) {
      return 'Enter a valid Student ID in the format 9536YYDDDNNN';
    }
    return null;
  }

  Future<void> _handleCreate() async {
    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _selectedDepartment.isEmpty ||
        _selectedSemester.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_generatedId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select department and enter student number to generate ID'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final idError = _validateGeneratedId(_generatedId);
    if (idError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(idError), behavior: SnackBarBehavior.floating),
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

    final emailUsername = '${_generatedId}@ritrjpm.ac.in';
    final userData = {
      'user_id': _generatedId,
      'username': emailUsername,
      'password': _passwordCtrl.text,
      'email': emailUsername,
      'full_name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'user_type': 'student',
      'department': _selectedDepartment,
      'semester': _selectedSemester,
      'batch': '',
      'section': '',
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
      SnackBar(content: Text('Account created successfully! Your Student ID: $_generatedId'), behavior: SnackBarBehavior.floating),
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
                          'Create Student Account',
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
                            _generateStudentId();
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Student Number *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _studentNumCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '001'),
                          onChanged: (_) => _generateStudentId(),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Semester *',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSemester.isEmpty ? null : _selectedSemester,
                          decoration: const InputDecoration(hintText: 'Select Semester'),
                          items: List.generate(8, (i) => DropdownMenuItem(value: '${i + 1}', child: Text('${_ordinal(i + 1)} Semester'))),
                          onChanged: (v) => setState(() => _selectedSemester = v ?? ''),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Generated Student ID',
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary, fontSize: 14)),
      );

  static Widget _twoCol({required Widget left, required Widget right}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 480) {
          return Row(children: [Expanded(child: left), const SizedBox(width: 16), Expanded(child: right)]);
        }
        return Column(children: [left, const SizedBox(height: 16), right]);
      },
    );
  }

  static String _ordinal(int n) {
    switch (n) {
      case 1: return '1st';
      case 2: return '2nd';
      case 3: return '3rd';
      default: return '${n}th';
    }
  }
}