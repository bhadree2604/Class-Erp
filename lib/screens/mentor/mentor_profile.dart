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
  User? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _userName = user?.fullName ?? 'Mentor';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    final extra = u?.extra ?? {};
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
                    child: Text('View and update your profile information', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
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
                              (u?.fullName ?? 'M')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(u?.fullName ?? 'Mentor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                          Text(u?.userId ?? '', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _infoCard('Personal Information', [
                    ('Mentor ID', u?.userId ?? '-'),
                    ('Name', u?.fullName ?? '-'),
                    ('Email', u?.email ?? '-'),
                    ('Phone', u?.phone ?? '-'),
                    ('Date of Birth', extra['dob'] as String? ?? '-'),
                    ('Gender', extra['gender'] as String? ?? '-'),
                    ('Blood Group', extra['bloodGroup'] as String? ?? '-'),
                    ('Nationality', extra['nationality'] as String? ?? '-'),
                  ]),
                  const SizedBox(height: 24),
                  _infoCard('Professional Information', [
                    ('Department', u?.department ?? '-'),
                    ('Designation', extra['designation'] as String? ?? '-'),
                    ('Qualification', extra['qualification'] as String? ?? '-'),
                    ('Specialization', extra['specialization'] as String? ?? '-'),
                    ('Experience', extra['experience'] as String? ?? '-'),
                    ('Joining Date', extra['joiningDate'] as String? ?? '-'),
                    ('Office', extra['office'] as String? ?? '-'),
                    ('Employee ID', extra['employeeId'] as String? ?? '-'),
                  ]),
                  const SizedBox(height: 24),
                  _infoCard('Address Information', [
                    ('Current Address', extra['currentAddress'] as String? ?? '-'),
                    ('Permanent Address', extra['permanentAddress'] as String? ?? '-'),
                    ('City', extra['city'] as String? ?? '-'),
                    ('State', extra['state'] as String? ?? '-'),
                    ('Pincode', extra['pincode'] as String? ?? '-'),
                    ('Country', extra['country'] as String? ?? '-'),
                  ]),
                  const SizedBox(height: 24),
                  _infoCard('Emergency Contact', [
                    ('Contact Name', extra['emergencyName'] as String? ?? '-'),
                    ('Relationship', extra['emergencyRelation'] as String? ?? '-'),
                    ('Phone', extra['emergencyPhone'] as String? ?? '-'),
                    ('Email', extra['emergencyEmail'] as String? ?? '-'),
                  ]),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(AppRoutes.mentorProfileEdit);
                        _load();
                      },
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
                    Expanded(
                    flex: 2,
                    child: Text('${row.$1}:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary)),
                  ),
                  Expanded(child: Text(row.$2, style: TextStyle(color: AppColorsExtension.of(context).textSecondary))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
