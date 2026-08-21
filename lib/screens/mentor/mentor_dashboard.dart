import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

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
    final metrics = [
      (Icons.calendar_today, 'Avg Attendance','\u2191 2% from last month',
          const [AppColors.primary, AppColors.primaryDark]),
      (Icons.bar_chart, 'Avg CGPA','\u2191 0.3 improvement',
          const [Color(0xFFdc2626), Color(0xFFb91c1c)]),
      (Icons.groups, 'Meetings','Scheduled this week',
          const [Color(0xFF16a34a), Color(0xFF15803d)]),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 900
            ? (constraints.maxWidth - 72) / 4
            : (constraints.maxWidth - 24) / 2;
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final m in metrics)
              SizedBox(
                width: width,
              ),
          ],
        );
      },
    );
  }

  Widget _metricCard(String label, String value, String sub, IconData icon,
      List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 32),
        ],
      ),
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
                  child: _quickAction(
                      a.$1, a.$2, a.$3, a.$4),
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
          border: Border.all(color: AppColorsExtension.of(context).bgTertiary, width: 2),
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
            if (i > 0) const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorsExtension.of(context).bgSecondary,
                borderRadius: BorderRadius.circular(5),
                border: Border(
                  left: BorderSide(color: _activity[i].$4, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _activity[i].$1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _activity[i].$2,
                    style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                  ),
                  Text(
                    _activity[i].$3,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColorsExtension.of(context).textLight,
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

  Widget _deadlinesCard() {
    return AppCard(
      heading: 'Upcoming Deadlines',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _deadlines.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _deadlines[i].$5,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: _deadlines[i].$4, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _deadlines[i].$1,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _deadlines[i].$2,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    _deadlines[i].$3,
                    style: TextStyle(
                      fontSize: 13,
                      color: _deadlines[i].$6,
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
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MetricTile(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtension.of(context).bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textLight),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: AppColorsExtension.of(context).textPrimary)),
      ],
    );
  }
}

class _PerformanceChartPainter extends CustomPainter {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _attendance = [82.0, 85.0, 84.0, 87.0, 86.0, 87.0];
  static const _cgpa = [7.8, 8.0, 8.1, 8.2, 8.15, 8.2];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFe0e0e0)
      ..strokeWidth = 1;

    for (var i = 0; i <= 5; i++) {
      final y = (size.height - 40) * (i / 5) + 20;
      canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);
    }

    void line(List<double> data, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (var i = 0; i < data.length; i++) {
        final x = 40 + (size.width - 60) * (i / (data.length - 1));
        final y = size.height - 40 - ((data[i] - 70) / 30) * (size.height - 60);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    line(_attendance, AppColors.primary);
    line(_cgpa.map((v) => v * 10).toList(), AppColors.accent);

    for (var i = 0; i < _months.length; i++) {
      final x = 40 + (size.width - 60) * (i / (_months.length - 1));
      final tp = TextPainter(
        text: TextSpan(
          text: _months[i],
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 30));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



