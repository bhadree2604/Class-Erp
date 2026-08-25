import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/student_profile.dart';
import '../../models/mentor_student.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';
import '../../widgets/stat_card.dart';

/// Mentor dashboard — mirror of `mentor/dashboard.html`.
class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  String _userName = 'Mentor';
  String _mentorId = '';
  String _department = '';
  int _studentCount = 0;
  bool _loading = true;

  // Stats for averaging
  double _avgAttendance = 0.0;
  double _avgCgpa = 0.0;
  bool _loadingStats = true;

  static const _quickActions = [
    (Icons.person, 'View Students', 'Check student info and records',
    AppRoutes.mentorStudents),
    (Icons.event_outlined, 'Manage Events', 'Add or edit events',
    AppRoutes.mentorEvents),
    (Icons.description_outlined, 'Parent Reports', 'Write parent report notes',
    AppRoutes.mentorParentReport),
    (Icons.event_available_outlined, 'Schedule Meeting',
    'Schedule meetings with students', AppRoutes.mentorMeetings),
  ];

  static const _schedule = [];

  static const _activity = [];

  static const _deadlines = [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadStats();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final students = await DataService.instance.getMentorStudents();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _mentorId = user?.userId ?? 'M2024001';
      _department = user?.department ?? 'Computer Science';
      _studentCount = students.length;
      _loading = false;
    });
  }

  Future<void> _loadStats() async {
    final students = await DataService.instance.getMentorStudents();
    double totalAttendance = 0;
    double totalCgpa = 0;
    int count = 0;
    for (final ms in students) {
      try {
        final profile = await DataService.instance.getStudentData(ms.rollNo);
        totalAttendance += profile.attendance;
        totalCgpa += profile.cgpa;
        count++;
      } catch (_) {
        // ignore errors
      }
    }
    if (!mounted) return;
    setState(() {
      _avgAttendance = count > 0 ? totalAttendance / count : 0.0;
      _avgCgpa = count > 0 ? totalCgpa / count : 0.0;
      _loadingStats = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Dashboard',
      userName: _userName,
      currentRoute: AppRoutes.mentorDashboard,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _welcomeBanner(),
            const SizedBox(height: 24),
            _metricsGrid(),
            const SizedBox(height: 24),
            _quickActionsCard(),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 900;
                final performance = _performanceCard();
                final schedule = _scheduleCard();
                if (twoCol) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: performance),
                      const SizedBox(width: 24),
                      Expanded(child: schedule),
                    ],
                  );
                }
                return Column(children: [performance, schedule]);
              },
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 900;
                final activity = _activityCard();
                final deadlines = _deadlinesCard();
                if (twoCol) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: activity),
                      const SizedBox(width: 24),
                      Expanded(child: deadlines),
                    ],
                  );
                }
                return Column(children: [activity, deadlines]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back, $_userName!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mentor ID: $_mentorId | Department: $_department',
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          );
          final count = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_studentCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Students Under Mentorship',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          );
          if (constraints.maxWidth >= 600) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [info, count],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [info, const SizedBox(height: 16), count],
          );
        },
      ),
    );
  }

  Widget _metricsGrid() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool sideBySide = constraints.maxWidth >= 600;
        return Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Avg Attendance',
                value: '${_avgAttendance.toStringAsFixed(1)}%',
                subtitle: 'Average across all students',
                icon: Icons.calendar_today,
                color: AppColors.primary,
              ),
            ),
            if (sideBySide) const SizedBox(width: 24),
            if (sideBySide)
              Expanded(
                child: StatCard(
                  label: 'Avg CGPA',
                  value: _avgCgpa.toStringAsFixed(2),
                  subtitle: 'Average across all students',
                  icon: Icons.grade,
                  color: AppColors.success,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _quickActionsCard() {
    return AppCard(
      heading: 'Quick Actions',
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 1000
              ? (constraints.maxWidth - 80) / 6
              : constraints.maxWidth >= 640
              ? (constraints.maxWidth - 24) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final a in _quickActions)
                SizedBox(
                  width: width,
                  child: _quickAction(a.$1, a.$2, a.$3, a.$4),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _quickAction(
      IconData icon, String title, String desc, String route) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorsExtension.of(context).bgPrimary,
          border: Border.all(
              color: AppColorsExtension.of(context).bgTertiary, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColorsExtension.of(context).textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _performanceCard() {
    return AppCard(
      heading: 'Class Performance Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomPaint(
              painter: _PerformanceChartPainter(),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _ChartLegend(color: AppColors.primary, label: 'Attendance %'),
              SizedBox(width: 24),
              _ChartLegend(color: AppColors.accent, label: 'CGPA (x10)'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile('18', 'Excellent (>8.5)', AppColors.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile('5', 'Good (7-8.5)', AppColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                _MetricTile('2', 'Need Attention (<7)', AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard() {
    return AppCard(
      heading: "Today's Schedule",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _schedule.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorsExtension.of(context).bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: _schedule[i].$4, width: 4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _schedule[i].$1,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _schedule[i].$2,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColorsExtension.of(context).textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _schedule[i].$3,
                    style: TextStyle(
                      color: _schedule[i].$4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _activityCard() {
    return AppCard(
      heading: 'Recent Activity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _activity.length; i++) ...[
            if (i > 0) const Divider(height: 16),
            ListTile(
              leading: Icon(_activity[i].$1, color: AppColors.primary),
              title: Text(_activity[i].$2),
              subtitle: Text(_activity[i].$3),
              trailing: const Icon(Icons.more_vert),
            ),
          ],
        ],
      ),
    );
  }

  Widget _deadlinesCard() {
    return AppCard(
      heading: 'Upcoming Deadlines',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _deadlines.length; i++) ...[
            if (i > 0) const Divider(height: 16),
            ListTile(
              leading: const Icon(Icons.event_available, color: AppColors.accent),
              title: Text(_deadlines[i].$1),
              subtitle: Text(_deadlines[i].$2),
              trailing: Text(_deadlines[i].$3),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerformanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    final w = size.width;
    final h = size.height;
    for (int i = 0; i < 12; i++) {
      final x = (i / 11) * w;
      final y = h - ((((i % 3) + 1) * 10) / 100 * h);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
    paint.color = AppColors.accent;
    paint.strokeWidth = 2;
    final path2 = Path();
    for (int i = 0; i < 12; i++) {
      final x = (i / 11) * w;
      final y = h - ((((i % 2) + 1) * 15) / 100 * h);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricTile(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsExtension.of(context).bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorsExtension.of(context).bgTertiary),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColorsExtension.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}