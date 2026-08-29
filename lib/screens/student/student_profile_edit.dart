import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Student profile edit — mirror of `student/profile-edit.html`.
class StudentProfileEditScreen extends StatefulWidget {
  const StudentProfileEditScreen({super.key});

  @override
  State<StudentProfileEditScreen> createState() =>
      _StudentProfileEditScreenState();
}

class _StudentProfileEditScreenState extends State<StudentProfileEditScreen> {
  String _userName = 'Student';
  String _studentId = '';
  bool _loading = true;
  StudentProfile? _profile;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _permanentAddressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _permanentAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final profile = await DataService.instance.getStudentData(
      user?.userId ?? DataService.defaultStudentId,
    );
    _nameCtrl.text = profile.fullName;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone;
    _addressCtrl.text = profile.currentAddress;
    _permanentAddressCtrl.text = profile.permanentAddress;
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? profile.fullName;
      _studentId = user?.userId ?? profile.userId;
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _savePersonalInfo() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final updated = _profile!.copyWith(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    await DataService.instance.saveStudentProfile(_studentId, updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal information saved successfully!'), behavior: SnackBarBehavior.floating),
    );
    setState(() => _profile = updated);
  }

  Future<void> _saveAddress() async {
    if (_addressCtrl.text.isEmpty || _permanentAddressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final updated = _profile!.copyWith(
      currentAddress: _addressCtrl.text.trim(),
      permanentAddress: _permanentAddressCtrl.text.trim(),
    );
    await DataService.instance.saveStudentProfile(_studentId, updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address information saved successfully!'), behavior: SnackBarBehavior.floating),
    );
    setState(() => _profile = updated);
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Edit Profile',
      userName: _userName,
      currentRoute: AppRoutes.studentProfileEdit,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                            SizedBox(height: 4),
                            Text('Update your personal information', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Profile'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Personal Information',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _fieldLabel('Full Name *'),
                        TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Enter your full name')),
                        const SizedBox(height: 16),
                        _fieldLabel('Student ID'),
                        TextField(enabled: false, decoration: InputDecoration(hintText: _studentId)),
                        const SizedBox(height: 16),
                        _fieldLabel('Email Address *'),
                        TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'your.email@student.rit.edu')),
                        const SizedBox(height: 16),
                        _fieldLabel('Phone Number *'),
                        TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 98765 43210')),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                            const SizedBox(width: 12),
                            ElevatedButton(onPressed: _savePersonalInfo, child: const Text('Save Changes')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Address Information',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _fieldLabel('Current Address *'),
                        TextField(controller: _addressCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Hostel Block A, Room 205')),
                        const SizedBox(height: 16),
                        _fieldLabel('Permanent Address *'),
                        TextField(controller: _permanentAddressCtrl, maxLines: 3, decoration: const InputDecoration(hintText: '123 Main Street, City, State - 123456')),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                            const SizedBox(width: 12),
                            ElevatedButton(onPressed: _saveAddress, child: const Text('Save Address')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary)),
    );
  }
}
