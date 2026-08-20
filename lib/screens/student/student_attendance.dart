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

/// Student attendance — mirror of `student/attendance.html`.
class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  StudentProfile? _profile;
  String _userName = 'Student';
  bool _loading = true;
  String? _studentId;
  int _attendanceVersion = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshAttendance();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final profile = await DataService.instance.getStudentData(
      user?.userId ?? DataService.defaultStudentId,
    );
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _userName = user?.fullName ?? profile.fullName;
      _studentId = user?.userId ?? profile.userId;
      _loading = false;
    });
  }

  void _refreshAttendance() {
    setState(() {
      _attendanceVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return PortalScaffold(
      role: 'student',
      title: 'Attendance',
      userName: _userName,
      currentRoute: AppRoutes.studentAttendance,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Attendance Overview',
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Your attendance record across all subjects this semester',
                      style: TextStyle(
                        color: AppColorsExtension.of(context).textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth >= 640
                          ? 240.0
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          SizedBox(
                            width: width,
                            child: StatCard(
                              label: 'Overall Attendance',
                              value: '${p?.attendance ?? 0}%',
                              subtitle: 'Total classes attended',
                              icon: Icons.calendar_today,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: width,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _recordsCard(),
                ],
              ),
            ),
    );
  }

  Widget _recordsCard() {
    final studentId = _studentId ?? DataService.defaultStudentId;
    return FutureBuilder(
      key: ValueKey('attendance_$_attendanceVersion'),
      future: DataService.instance.getAttendance(studentId),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const [];
        return AppCard(
          heading: 'Recent Attendance Records',
          child: records.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No attendance records yet.',
                    style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                  ),
                )
              : Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.4),
                    1: FlexColumnWidth(1),
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
                        _HeaderCell('Date'),
                        _HeaderCell('Marked By'),
                        _HeaderCell('Status'),
                      ],
                    ),
                    for (final r in records)
                      TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary),
                          ),
                        ),
                        children: [
                          _BodyCell(r.subject),
                          _BodyCell(_formatDate(r.date)),
                          _BodyCell(r.markedBy),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: StatusBadge(status: r.status),
                          ),
                        ],
                      ),
                  ],
                ),
        );
      },
    );
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
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
