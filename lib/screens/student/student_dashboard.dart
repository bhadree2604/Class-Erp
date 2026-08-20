import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

/// Student dashboard — mirror of `student/dashboard.html`.
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  StudentProfile? _profile;
  String _userName = 'Student';
  String _studentId = '';
  int _pendingAssignments = 0;
  bool _loading = true;

  static const _announcements = [];

  static const _schedule = [];

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
    final assignments = await DataService.instance.getAssignments();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _userName = user?.fullName ?? profile.fullName;
      _studentId = user?.userId ?? profile.userId;
      _pendingAssignments = assignments.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return PortalScaffold(
      role: 'student',
      title: 'Dashboard',
      userName: _userName,
      currentRoute: AppRoutes.studentDashboard,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _welcomeBanner(),
                  const SizedBox(height: 24),
                  _statsGrid(p),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoCol = constraints.maxWidth >= 720;
                      final announcements = AppCard(
                        heading: 'Recent Announcements',
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < _announcements.length; i++) ...[
                              if (i > 0) const Divider(height: 16),
                              Text(
                                _announcements[i].$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _announcements[i].$2,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                      final schedule = AppCard(
                        heading: "Today's Schedule",
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < _schedule.length; i++) ...[
                              if (i > 0) const Divider(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _schedule[i].$1,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _schedule[i].$2,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                      if (twoCol) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: announcements),
                            const SizedBox(width: 24),
                            Expanded(child: schedule),
                          ],
                        );
                      }
                      return Column(
                        children: [announcements, schedule],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _upcomingAssignments(),
                ],
              ),
            ),
    );
  }

  Widget _welcomeBanner() {
    final p = _profile;
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, ${p?.fullName ?? ''}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Student ID: $_studentId | Semester: ${p?.semester ?? '-'} | '
            'Branch: ${p?.department ?? '-'}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(StudentProfile? p) {
    final stats = [
      StatCard(
        label: 'Attendance',
        value: '${p?.attendance ?? 0}%',
        subtitle: 'Overall attendance',
        icon: Icons.calendar_today,
        color: AppColors.primary,
      ),
      StatCard(
        label: 'CGPA',
        value: '${p?.cgpa ?? 0}',
        subtitle: 'Current semester',
        icon: Icons.grade,
        color: AppColors.success,
      ),
      StatCard(
        label: 'Assignments',
        value: '$_pendingAssignments',
        subtitle: 'Pending submissions',
        icon: Icons.assignment,
        color: AppColors.warning,
      ),
      const StatCard(
        label: 'Fees',
        value: 'Paid',
        subtitle: 'Current semester',
        icon: Icons.payments,
        color: AppColors.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 760
            ? 160.0
            : (constraints.maxWidth - 48) / 2;
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final s in stats)
              SizedBox(width: itemWidth, child: s),
          ],
        );
      },
    );
  }

  Widget _upcomingAssignments() {
    return FutureBuilder(
      future: DataService.instance.getAssignments(),
      builder: (context, snapshot) {
        final assignments = snapshot.data ?? const [];
        return AppCard(
          heading: 'Upcoming Assignments',
          child: assignments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No assignments available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1.4),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(0.8),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                      children: [
                        _HeaderCell('Subject'),
                        _HeaderCell('Assignment'),
                        _HeaderCell('Due Date'),
                        _HeaderCell('Status'),
                      ],
                    ),
                    for (final a in assignments)
                      TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.bgTertiary),
                          ),
                        ),
                        children: [
                          _BodyCell(a.subject),
                          _BodyCell(a.title),
                          _BodyCell(_formatDate(a.dueDate)),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: StatusBadge(
                                status: _isOverdue(a) ? 'Overdue' : 'Pending'),
                          ),
                        ],
                      ),
                  ],
                ),
        );
      },
    );
  }

  bool _isOverdue(dynamic assignment) {
    final due = DateTime.tryParse(assignment.dueDate);
    if (due == null) return false;
    return due.isBefore(DateTime.now());
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  const _BodyCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          color: text.isEmpty ? null : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


