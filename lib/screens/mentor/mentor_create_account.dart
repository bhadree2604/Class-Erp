import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';

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
    setState(() => _generatedId = 'M$year$deptCode001');
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
                    Text('Create Mentor Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                    const SizedBox(height: 8),
                    Text('Fill in your details to create a new account', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
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
                          onChanged: (v) { _selectedDepartment = v ?? ''; _generateMentorId(); },
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _label('Generated Mentor ID'),
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: _generatedId.isEmpty ? 'Will be auto-generated' : _generatedId,
                        filled: true,
                        fillColor: AppColorsExtension.of(context).bgSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Email Address *'),
                        TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'your.email@rit.edu')),
                      ]),
                      right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Phone Number *'),
                        TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 98765 43210')),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Designation *'),
                        TextField(controller: _designationCtrl, decoration: const InputDecoration(hintText: 'e.g., Professor')),
                      ]),
                      right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Qualification *'),
                        TextField(controller: _qualificationCtrl, decoration: const InputDecoration(hintText: 'e.g., Ph.D, M.Tech')),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Experience (years) *'),
                        TextField(controller: _experienceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g., 5')),
                      ]),
                      right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Password *'),
                        TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Min 6 characters')),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _twoCol(
                      left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Confirm Password *'),
                        TextField(controller: _confirmPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Re-enter password')),
                      ]),
                      right: Container(), // spacer
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
}