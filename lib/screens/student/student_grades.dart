import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';
import '../../widgets/stat_card.dart';

/// Student grades — mirror of `student/grades.html`.
class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  String _userName = 'Student';
  bool _loading = true;
  List<Map<String, dynamic>> _grades = const [];
  double _cgpa = 0;
  double _semesterGpa = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final grades = DataService.instance.getDefaultGrades();
    double totalPoints = 0;
    int totalCredits = 0;
    for (final g in grades) {
      totalPoints += g.gradePoint * g.credits;
      totalCredits += g.credits;
    }
    final gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _grades = grades
          .map((g) => {
                'subject': g.subject,
                'credits': g.credits,
                'grade': g.grade,
                'gradePoint': g.gradePoint,
              })
          .toList();
      _cgpa = gpa;
      _semesterGpa = gpa;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Grades',
      userName: _userName,
      currentRoute: AppRoutes.studentGrades,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Academic Performance',
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'View your grades and CGPA',
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
                              label: 'Current CGPA',
                              value: _cgpa.toStringAsFixed(1),
                              subtitle: 'Overall performance',
                              icon: Icons.school,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: StatCard(
                              label: 'Semester GPA',
                              value: _semesterGpa.toStringAsFixed(1),
                              subtitle: 'Current semester',
                              icon: Icons.grade,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Current Semester Grades',
                    child: _grades.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No grades available yet.',
                              style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                            ),
                          )
                        : Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
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
                                  _HeaderCell('Credits'),
                                  _HeaderCell('Grade'),
                                  _HeaderCell('Points'),
                                ],
                              ),
                              for (final g in _grades)
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppColorsExtension.of(context).bgTertiary),
                                    ),
                                  ),
                                  children: [
                                    _BodyCell(g['subject'], strong: true),
                                    _BodyCell('${g['credits']}'),
                                    _gradeCell(g['grade']),
                                    _BodyCell('${g['gradePoint']}'),
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

  Widget _gradeCell(String grade) {
    Color color;
    switch (grade) {
      case 'A+':
        color = AppColors.success;
        break;
      case 'A':
        color = AppColors.info;
        break;
      case 'B+':
        color = AppColors.warning;
        break;
      default:
        color = AppColorsExtension.of(context).textSecondary;
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          grade,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
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
  final bool strong;
  const _BodyCell(this.text, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}