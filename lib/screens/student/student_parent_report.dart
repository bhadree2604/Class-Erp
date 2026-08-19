import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';
import '../../widgets/stat_card.dart';

/// Student parent report — mirror of `student/parent-report.html`.
class StudentParentReportScreen extends StatefulWidget {
  const StudentParentReportScreen({super.key});

  @override
  State<StudentParentReportScreen> createState() =>
      _StudentParentReportScreenState();
}

class _StudentParentReportScreenState extends State<StudentParentReportScreen> {
  String _userName = 'Student';
  StudentProfile? _profile;
  bool _loading = true;

  static const _academicPerformance = [
    ('Data Structures', 'A', 'Excellent performance'),
    ('Database Management', 'A-', 'Good understanding'),
    ('Web Development', 'B+', 'Needs improvement'),
    ('Software Engineering', 'A', 'Outstanding work'),
    ('Computer Networks', 'B+', 'Good progress'),
  ];

  static const _teacherComments = [
    ('Class Teacher',
        'Bhadree is a dedicated student who shows great interest in learning. Regular attendance and active participation in class.'),
    ('Subject Teacher - Data Structures',
        'Excellent problem-solving skills. Shows strong understanding of complex algorithms.'),
    ('Subject Teacher - Web Development',
        'Good practical skills. Encourage more practice on responsive design concepts.'),
  ];

  static const _activities = [
    ('Sports', 'Participated in inter-college cricket tournament'),
    ('Technical Events', 'Won 2nd prize in coding competition'),
    ('Cultural Activities', 'Active member of college drama club'),
  ];

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
    return PortalScaffold(
      role: 'student',
      title: 'Parent Report',
      userName: _userName,
      currentRoute: AppRoutes.studentParentReport,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Parent Report',
                    padding: const EdgeInsets.all(24),
                    child: const Text(
                      'Comprehensive report for parents about student performance',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth >= 760
                          ? (constraints.maxWidth - 72) / 4
                          : (constraints.maxWidth - 24) / 2;
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          SizedBox(width: w, child: const StatCard(label: 'Overall Performance', value: 'A', subtitle: 'Grade this semester', icon: Icons.school, color: AppColors.primary)),
                          SizedBox(width: w, child: StatCard(label: 'Attendance', value: '${_profile?.attendance ?? 85}%', subtitle: 'Overall attendance', icon: Icons.calendar_today, color: AppColors.success)),
                          SizedBox(width: w, child: StatCard(label: 'CGPA', value: '${_profile?.cgpa ?? 8.5}', subtitle: 'Current semester', icon: Icons.grade, color: AppColors.warning)),
                          SizedBox(width: w, child: const StatCard(label: 'Behavior', value: 'Excellent', subtitle: 'Conduct rating', icon: Icons.star, color: AppColors.info)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoCol = constraints.maxWidth >= 720;
                      final academic = _academicCard();
                      final comments = _commentsCard();
                      if (twoCol) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: academic),
                            const SizedBox(width: 24),
                            Expanded(child: comments),
                          ],
                        );
                      }
                      return Column(children: [academic, comments]);
                    },
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoCol = constraints.maxWidth >= 720;
                      final activities = _activitiesCard();
                      final disciplinary = _disciplinaryCard();
                      if (twoCol) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: activities),
                            const SizedBox(width: 24),
                            Expanded(child: disciplinary),
                          ],
                        );
                      }
                      return Column(children: [activities, disciplinary]);
                    },
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Download Report',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Generate and download comprehensive parent report',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Parent report downloaded successfully!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download PDF Report'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _academicCard() {
    return AppCard(
      heading: 'Academic Performance',
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(2),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          const TableRow(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
            ),
            children: [
              _HeaderCell('Subject'),
              _HeaderCell('Grade'),
              _HeaderCell('Remarks'),
            ],
          ),
          for (final row in _academicPerformance)
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.bgTertiary)),
              ),
              children: [
                _BodyCell(row.$1),
                _BodyCell(row.$2),
                _BodyCell(row.$3),
              ],
            ),
        ],
      ),
    );
  }

  Widget _commentsCard() {
    return AppCard(
      heading: 'Teacher Comments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _teacherComments.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            Text(
              _teacherComments[i].$1,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              _teacherComments[i].$2,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _activitiesCard() {
    return AppCard(
      heading: 'Co-curricular Activities',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _activities.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            Text(
              _activities[i].$1,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              _activities[i].$2,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _disciplinaryCard() {
    return AppCard(
      heading: 'Disciplinary Record',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No disciplinary issues reported',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Student maintains good conduct and follows all college rules and regulations.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
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
      child: Text(text.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1)),
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
      child: Text(text, style: const TextStyle(color: AppColors.textPrimary)),
    );
  }
}