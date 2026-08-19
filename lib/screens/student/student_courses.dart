import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/course.dart';
import '../../models/course_catalog.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Student courses — mirror of `student/courses.html`.
class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  String _userName = 'Student';
  List<Course> _courses = const [];
  String _semesterInfo = '';
  bool _loading = true;

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

    final semester = _semesterOf(profile, user?.semester ?? '');
    _courses = CSE_COURSES.where((c) => c.semester == semester).toList();
    _semesterInfo = 'Semester $semester - Computer Science and Engineering (CSE)';
    _userName = user?.fullName ?? profile.fullName;

    if (!mounted) return;
    setState(() => _loading = false);
  }

  int _semesterOf(StudentProfile profile, String userSemester) {
    final raw = userSemester.isNotEmpty ? userSemester : profile.semester;
    final parsed = int.tryParse(raw);
    return (parsed != null && parsed > 0) ? parsed : 2;
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Courses',
      userName: _userName,
      currentRoute: AppRoutes.studentCourses,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'My Courses',
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _semesterInfo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (_courses.isEmpty)
                    const AppCard(
                      heading: 'No courses',
                      child: Text(
                        'No courses assigned yet. Please contact your mentor.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else ...[
                    _sectionHeader('Core Courses', Icons.menu_book,
                        const [AppColors.primary, AppColors.primaryDark]),
                    _courseGrid(_courses.where((c) => c.type != 'Elective')),
                    _sectionHeader('Elective Courses', Icons.adjust,
                        const [Color(0xFFdc2626), Color(0xFFb91c1c)]),
                    _courseGrid(_courses.where((c) => c.type == 'Elective')),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, List<Color> gradient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseGrid(Iterable<Course> courses) {
    final list = courses.toList();
    if (list.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= 720;
        final items = list.map((c) => _courseCard(c)).toList();
        if (twoCol) {
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final item in items)
                SizedBox(width: (constraints.maxWidth - 24) / 2, child: item),
            ],
          );
        }
        return Column(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: item,
              ),
          ],
        );
      },
    );
  }

  Widget _courseCard(Course course) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _infoRow('Code', course.code),
          _infoRow('Credits', '${course.credits}'),
          _infoRow('Type', course.type),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}