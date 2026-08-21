import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/meeting.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class StudentMeetingsScreen extends StatefulWidget {
  const StudentMeetingsScreen({super.key});

  @override
  State<StudentMeetingsScreen> createState() => _StudentMeetingsScreenState();
}

class _StudentMeetingsScreenState extends State<StudentMeetingsScreen> {
  String _userName = 'Student';
  bool _loading = true;
  List<Meeting> _meetings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final allMeetings = await DataService.instance.getMeetings();
    final myMeetings = allMeetings.where((m) => m.studentRollNo == (user?.userId ?? '')).toList();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _meetings = myMeetings;
      _loading = false;
    });
  }

  List<Meeting> get _upcoming => _meetings.where((m) => m.status != 'Completed' && m.status != 'Cancelled').toList();
  List<Meeting> get _past => _meetings.where((m) => m.status == 'Completed' || m.status == 'Cancelled').toList();

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Meetings',
      userName: _userName,
      currentRoute: AppRoutes.studentMeetings,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('My Meetings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                    const SizedBox(height: 4),
                    Text('View meetings scheduled by your mentor', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Upcoming Meetings',
                      padding: const EdgeInsets.all(24),
                      child: _upcoming.isEmpty
                          ? Text('No upcoming meetings', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                          : Column(
                              children: [
                                for (final m in _upcoming) ...[
                                  _meetingCard(m),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Past Meetings',
                      padding: const EdgeInsets.all(24),
                      child: _past.isEmpty
                          ? Text('No past meetings', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                          : Column(
                              children: [
                                for (final m in _past) ...[
                                  _meetingCard(m),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _meetingCard(Meeting m) {
    final isCompleted = m.status == 'Completed';
    final statusColor = isCompleted ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtension.of(context).bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColorsExtension.of(context).bgTertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.topic, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColorsExtension.of(context).textPrimary)),
                    const SizedBox(height: 4),
                    Text('Mentor: ${m.createdBy}', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(m.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColorsExtension.of(context).textLight),
              const SizedBox(width: 4),
              Text(m.date, style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textSecondary)),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: AppColorsExtension.of(context).textLight),
              const SizedBox(width: 4),
              Text(m.time, style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textSecondary)),
            ],
          ),
          if (m.agenda.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(m.agenda, style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textSecondary)),
          ],
          if (m.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Notes: ${m.notes}', style: TextStyle(fontSize: 12, color: AppColorsExtension.of(context).textLight)),
          ],
        ],
      ),
    );
  }
}
