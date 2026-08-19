import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({super.key});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  String _userName = 'Mentor';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Mentor Profile',
      userName: _userName,
      currentRoute: AppRoutes.mentorProfile,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Mentor Profile',
                    padding: const EdgeInsets.all(24),
                    child: const Text('View and update your profile information', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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
                            child: const Icon(Icons.person, size: 50, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text('Dr. Rajesh Kumar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const Text('M2024001', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _infoCard('Personal Information', [
                    ('Mentor ID', 'M2024001'),
                    ('Name', 'Dr. Rajesh Kumar'),
                    ('Email', 'rajesh.kumar@rit.edu'),
                    ('Phone', '+91 98765 43210'),
                    ('Date of Birth', 'May 15, 1980'),
                    ('Gender', 'Male'),
                    ('Blood Group', 'B+'),
                    ('Nationality', 'Indian'),
                  ]),
                  const SizedBox(height: 24),
                  _infoCard('Professional Information', [
                    ('Department', 'Computer Science'),
                    ('Designation', 'Assistant Professor'),
                    ('Qualification', 'Ph.D'),
                    ('Specialization', 'Data Science, ML'),
                    ('Experience', '10 Years'),
                    ('Joining Date', 'July 1, 2014'),
                    ('Office', 'Room 305, CS Block'),
                    ('Employee ID', 'EMP2024001'),
                  ]),
                  const SizedBox(height: 24),
                  _infoCard('Address Information', [
                    ('Current Address', '123 Main Street, Apartment 4B'),
                    ('Permanent Address', '456 Home Street, City, State'),
                    ('City', 'Chennai'),
                    ('State', 'Tamil Nadu'),
                    ('Pincode', '600001'),
                    ('Country', 'India'),
                  ]),
                  const SizedBox(height: 24),
                  _infoCard('Emergency Contact', [
                    ('Contact Name', 'Family Member'),
                    ('Relationship', 'Spouse'),
                    ('Phone', '+91 98765 43210'),
                    ('Email', 'emergency@email.com'),
                  ]),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.mentorProfileEdit),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Information'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoCard(String title, List<(String, String)> rows) {
    return AppCard(
      heading: title,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: Text('${row.$1}:', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ),
                  Expanded(child: Text(row.$2, style: const TextStyle(color: AppColors.textSecondary))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}