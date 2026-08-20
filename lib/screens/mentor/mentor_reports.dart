import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';
import '../../widgets/stat_card.dart';

class MentorReportsScreen extends StatefulWidget {
  const MentorReportsScreen({super.key});

  @override
  State<MentorReportsScreen> createState() => _MentorReportsScreenState();
}

class _MentorReportsScreenState extends State<MentorReportsScreen> {
  String _userName = 'Mentor';
  bool _loading = true;

  static const _recentReports = [
    ('Monthly Report', 'March 20, 2026', 'February 2026'),
    ('Attendance Report', 'March 15, 2026', 'Semester 6'),
    ('Performance Report', 'March 10, 2026', 'Q1 2026'),
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
      title: 'Reports',
      userName: _userName,
      currentRoute: AppRoutes.mentorReports,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Generate Reports',
                    padding: const EdgeInsets.all(24),
                    child: Text('Create and download various reports for your students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth >= 700 ? (constraints.maxWidth - 48) / 3 : (constraints.maxWidth - 24) / 2;
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          SizedBox(width: w, child: const StatCard(label: 'Monthly Report', value: 'Generate', subtitle: 'Comprehensive monthly performance', icon: Icons.assessment, color: AppColors.primary)),
                          SizedBox(width: w, child: const StatCard(label: 'Attendance Report', value: 'Generate', subtitle: 'Attendance summary for all students', icon: Icons.calendar_today, color: AppColors.success)),
                          SizedBox(width: w, child: const StatCard(label: 'Performance Report', value: 'Generate', subtitle: 'Academic performance analysis', icon: Icons.trending_up, color: AppColors.warning)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Recent Reports',
                    padding: const EdgeInsets.all(24),
                    child: Table(
                      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1)},
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                          children: [_H('Report Type'), _H('Generated On'), _H('Period'), _H('Action')],
                        ),
                        for (final r in _recentReports)
                          TableRow(
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                            children: [
                              _B(r.$1),
                              _B(r.$2),
                              _B(r.$3),
                              const Padding(padding: EdgeInsets.all(12), child: Text('Download', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
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
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(12), child: Text(t, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
}