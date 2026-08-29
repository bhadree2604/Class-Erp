import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Student profile — mirror of `student/profile.html`.
class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String _userName = 'Student';
  StudentProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final profile = await DataService.instance.getStudentData(
      user?.userId ?? DataService.defaultStudentId,
    );
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? profile.fullName;
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return PortalScaffold(
      role: 'student',
      title: 'Profile',
      userName: _userName,
      currentRoute: AppRoutes.studentProfile,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Student Profile',
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'View and manage your personal information',
                      style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              (p?.fullName ?? 'S')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                           Text(
                             p?.fullName ?? 'Student',
                             style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary),
                           ),
                           Text(
                             p?.userId ?? '',
                             style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                           ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoCol = constraints.maxWidth >= 720;
                      final personal = _personalInfoCard(p);
                      final academic = _academicInfoCard(p);
                      if (twoCol) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: personal),
                            const SizedBox(width: 24),
                            Expanded(child: academic),
                          ],
                        );
                      }
                      return Column(children: [personal, academic]);
                    },
                  ),
                  const SizedBox(height: 24),
                  _addressCard(p),
                  const SizedBox(height: 24),
                  _emergencyCard(),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.studentProfileEdit),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Information'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _personalInfoCard(StudentProfile? p) {
    return AppCard(
      heading: 'Personal Information',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Name', p?.fullName ?? '-'),
          _infoRow('Student ID', p?.userId ?? '-'),
          _infoRow('Email', p?.email ?? '-'),
          _infoRow('Phone', p?.phone ?? '-'),
          _infoRow('Department', p?.department ?? '-'),
          _infoRow('Semester', p?.semester ?? '-'),
          _infoRow('Batch', p?.batch ?? '-'),
          _infoRow('Section', p?.section ?? '-'),
        ],
      ),
    );
  }

  Widget _academicInfoCard(StudentProfile? p) {
    return AppCard(
      heading: 'Academic Information',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Branch', p?.department ?? '-'),
          _infoRow('Semester', p?.semester ?? '-'),
          _infoRow('Batch', p?.batch ?? '-'),
          _infoRow('CGPA', '${p?.cgpa ?? '-'}'),
          _infoRow('GPA', '${p?.gpa ?? '-'}'),
          _infoRow('Attendance', '${p?.attendance ?? 0}%'),
          _infoRow('Arrears', '${p?.arrears ?? 0}'),
        ],
      ),
    );
  }

  Widget _addressCard(StudentProfile? p) {
    return AppCard(
      heading: 'Address',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Current Address', p?.currentAddress ?? '-'),
          _infoRow('Permanent Address', p?.permanentAddress ?? '-'),
        ],
      ),
    );
  }

  Widget _emergencyCard() {
    return AppCard(
      heading: 'Emergency Contact',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Contact Name', 'Parent Name'),
          _infoRow('Relationship', 'Father'),
          _infoRow('Phone', '+91 98765 43210'),
          _infoRow('Email', 'parent@email.com'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
          ),
        ],
      ),
    );
  }
}
