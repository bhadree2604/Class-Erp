import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';


/// Student parent report — mirror of `student/parent-report.html`.
class StudentParentReportScreen extends StatefulWidget {
  const StudentParentReportScreen({super.key});

  @override
  State<StudentParentReportScreen> createState() =>
      _StudentParentReportScreenState();
}

class _StudentParentReportScreenState extends State<StudentParentReportScreen> {
  String _userName = 'Student';
  bool _loading = true;

  static const _academicPerformance = [

  ];

  static const _teacherComments = [

  ];

  static const _activities = [

  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                    child: Text(
                      'Comprehensive report for parents about student performance',
                      style: TextStyle(
                        color: AppColorsExtension.of(context).textSecondary,
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
                        Text(
                          'Generate and download comprehensive parent report',
                          style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
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
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary)),
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
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              _teacherComments[i].$2,
              style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14),
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
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              _activities[i].$2,
              style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14),
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
        children: [
          const Padding(
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
            style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14),
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
      child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}