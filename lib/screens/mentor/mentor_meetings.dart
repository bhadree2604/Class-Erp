import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorMeetingsScreen extends StatefulWidget {
  const MentorMeetingsScreen({super.key});

  @override
  State<MentorMeetingsScreen> createState() => _MentorMeetingsScreenState();
}

class _MentorMeetingsScreenState extends State<MentorMeetingsScreen> {
  String _userName = 'Mentor';
  bool _loading = true;

  static const _upcoming = [
    ('March 27, 2026 - 10:00 AM', 'Rahul Kumar', '2024CS015', 'Attendance Discussion', 'Scheduled'),
    ('March 28, 2026 - 2:00 PM', 'Amit Patel', '2024CS008', 'Academic Performance', 'Scheduled'),
    ('March 29, 2026 - 11:00 AM', 'Priya Sharma', '2024CS022', 'Career Guidance', 'Scheduled'),
  ];

  static const _past = [
    ('March 20, 2026', 'Bhadree', 'Progress Review'),
    ('March 18, 2026', 'Vikram Singh', 'Project Discussion'),
  ];

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
      title: 'Student Meetings',
      userName: _userName,
      currentRoute: AppRoutes.mentorMeetings,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Student Meetings',
                    padding: const EdgeInsets.all(24),
                    child: const Text('Schedule and manage one-on-one meetings with students', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Upcoming Meetings',
                    padding: const EdgeInsets.all(24),
                    child: Table(
                      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.2), 3: FlexColumnWidth(2), 4: FlexColumnWidth(1)},
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                          children: [_H('Date & Time'), _H('Student'), _H('Roll No'), _H('Purpose'), _H('Status')],
                        ),
                        for (final m in _upcoming)
                          TableRow(
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.bgTertiary))),
                            children: [
                              _B(m.$1),
                              _B(m.$2),
                              _B(m.$3),
                              _B(m.$4),
                              Padding(padding: const EdgeInsets.all(12), child: Text(m.$5, style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600))),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Past Meetings',
                    padding: const EdgeInsets.all(24),
                    child: Table(
                      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1.5)},
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                          children: [_H('Date'), _H('Student'), _H('Purpose'), _H('Notes')],
                        ),
                        for (final m in _past)
                          TableRow(
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.bgTertiary))),
                            children: [
                              _B(m.$1),
                              _B(m.$2),
                              _B(m.$3),
                              const Padding(padding: EdgeInsets.all(12), child: Text('View Notes', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
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
}

class _H extends StatelessWidget {
  final String t;
  const _H(this.t);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(12), child: Text(t.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1)));
}

class _B extends StatelessWidget {
  final String t;
  const _B(this.t);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(12), child: Text(t, style: const TextStyle(color: AppColors.textPrimary)));
}