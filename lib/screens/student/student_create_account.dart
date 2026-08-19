import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';

/// Student create account — mirror of `student/create-account.html`.
class StudentCreateAccountScreen extends StatefulWidget {
  const StudentCreateAccountScreen({super.key});

  @override
  State<StudentCreateAccountScreen> createState() =>
      _StudentCreateAccountScreenState();
}

class _StudentCreateAccountScreenState extends State<StudentCreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
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
    _emailCtrl.dispose();
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

  void _handleCreate() {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created successfully! Your Student ID: $_generatedId'), behavior: SnackBarBehavior.floating),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/rit_logo.jpg', height: 80, width: 80, fit: BoxFit.contain),
                    const SizedBox(height: 24),
                    const Text('Create Student Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('Fill in your details to create a new account', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 32),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Full Name *'),
                        TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Enter your full name')),
                      ]),
                      right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Department *'),
                        DropdownButtonFormField<String>(
                          initialValue: null,
                          hint: const Text('Select Department'),
                          items: _departments.keys.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                          onChanged: (v) { _selectedDepartment = v ?? ''; _generateStudentId(); },
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Student Number *'),
                        TextField(
                          controller: _studentNumCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '001'),
                          onChanged: (_) => _generateStudentId(),
                        ),
                      ]),
                      right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Semester *'),
                        DropdownButtonFormField<String>(
                          initialValue: null,
                          hint: const Text('Select Semester'),
                          items: List.generate(8, (i) => DropdownMenuItem(value: '${i + 1}', child: Text('${_ordinal(i + 1)} Semester'))),
                          onChanged: (v) => setState(() => _selectedSemester = v ?? ''),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _label('Generated Student ID'),
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: _generatedId.isEmpty ? 'Will be auto-generated' : _generatedId,
                        filled: true,
                        fillColor: AppColors.bgSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Email Address *'),
                        TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'your.email@student.rit.edu')),
                      ]),
                      right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Phone Number *'),
                        TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 98765 43210')),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Password *'),
                        TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Min 6 characters')),
                      ]),
                      right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Confirm Password *'),
                        TextField(controller: _confirmPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Re-enter password')),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _handleCreate, child: const Text('Create Account'))),
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
    );
  }

  static Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
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