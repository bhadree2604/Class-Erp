import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/assignment.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';
import '../../widgets/status_badge.dart';

/// Student assignments — mirror of `student/assignments.html`.
class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  String _userName = 'Student';
  List<Assignment> _assignments = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final assignments = await DataService.instance.getAssignments();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _assignments = assignments;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Assignments',
      userName: _userName,
      currentRoute: AppRoutes.studentAssignments,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Assignments',
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Manage and submit your assignments',
                      style: TextStyle(
                        color: AppColorsExtension.of(context).textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    heading: 'All Assignments',
                    child: _assignments.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No assignments available',
                              style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                            ),
                          )
                        : Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1.2),
                              1: FlexColumnWidth(1.4),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(0.8),
                              5: FlexColumnWidth(0.8),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                ),
                                children: [
                                  _HeaderCell('Subject'),
                                  _HeaderCell('Title'),
                                  _HeaderCell('Description'),
                                  _HeaderCell('Due Date'),
                                  _HeaderCell('Max Marks'),
                                  _HeaderCell('Status'),
                                ],
                              ),
                              for (final a in _assignments)
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppColorsExtension.of(context).bgTertiary),
                                    ),
                                  ),
                                  children: [
                                    _BodyCell(a.subject),
                                    _BodyCell(a.title),
                                    _BodyCell(a.description),
                                    _BodyCell(_formatDate(a.dueDate)),
                                    _BodyCell(a.maxMarks),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: StatusBadge(
                                        status: _isOverdue(a)
                                            ? 'Overdue'
                                            : 'Pending',
                                      ),
                                    ),
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

  bool _isOverdue(Assignment a) {
    final due = DateTime.tryParse(a.dueDate);
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
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}