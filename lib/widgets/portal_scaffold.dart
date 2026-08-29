import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem(this.label, this.icon, this.route);
}

/// Shared app shell: AppBar + role-based sidebar drawer + body.
/// Mirrors the sidebar navigation from the web project's styles.css/script.js.
class PortalScaffold extends StatelessWidget {
  final String role;
  final String title;
  final String? userName;
  final Widget body;
  final String? currentRoute;

  const PortalScaffold({
    super.key,
    required this.role,
    required this.title,
    this.userName,
    required this.body,
    this.currentRoute,
  });

  static const _studentNav = <_NavItem>[
    _NavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.studentDashboard),
    _NavItem('Attendance', Icons.calendar_today_outlined, AppRoutes.studentAttendance),
    _NavItem('Grades', Icons.grade_outlined, AppRoutes.studentGrades),
    _NavItem('Courses', Icons.menu_book_outlined, AppRoutes.studentCourses),

    _NavItem('Meetings', Icons.event_available_outlined, AppRoutes.studentMeetings),
    _NavItem('Events', Icons.event_outlined, AppRoutes.studentEvents),
    _NavItem('Certificates', Icons.workspace_premium_outlined, AppRoutes.studentCertificates),
    _NavItem('Parent Report', Icons.family_restroom_outlined, AppRoutes.studentParentReport),
    _NavItem('Profile', Icons.person_outline, AppRoutes.studentProfile),
    _NavItem('Settings', Icons.settings_outlined, AppRoutes.studentSettings),
  ];

  static const _mentorNav = <_NavItem>[
    _NavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.mentorDashboard),
    _NavItem('My Students', Icons.people_outline, AppRoutes.mentorStudents),
    _NavItem('Courses', Icons.menu_book_outlined, AppRoutes.mentorCourses),

    _NavItem('Events', Icons.event_outlined, AppRoutes.mentorEvents),
    _NavItem('Grades', Icons.grade_outlined, AppRoutes.mentorGrades),
    _NavItem('Attendance', Icons.calendar_today_outlined, AppRoutes.mentorAttendance),
    _NavItem('Certificates', Icons.workspace_premium_outlined, AppRoutes.mentorCertificates),
    _NavItem('Reports', Icons.description_outlined, AppRoutes.mentorReports),
    _NavItem('Meetings', Icons.event_available_outlined, AppRoutes.mentorMeetings),
    _NavItem('Parent Report', Icons.family_restroom_outlined, AppRoutes.mentorParentReport),
    _NavItem('Profile', Icons.person_outline, AppRoutes.mentorProfile),
    _NavItem('Settings', Icons.settings_outlined, AppRoutes.mentorSettings),
  ];

  static const _adminNav = <_NavItem>[
    _NavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.adminDashboard),
    _NavItem('Students', Icons.people_outline, AppRoutes.adminStudents),
    _NavItem('Mentors', Icons.person_outline, AppRoutes.adminMentors),
    _NavItem('Create User', Icons.person_add_outlined, AppRoutes.adminCreateUser),
  ];

  List<_NavItem> get _navItems {
    if (role == 'student') return _studentNav;
    if (role == 'mentor') return _mentorNav;
    if (role == 'admin') return _adminNav;
    return const [];
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isStudent = role == 'student';
    final isAdmin = role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/rit_logo.jpg',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userName != null ? 'Welcome, $userName' : title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Material(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _logout(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isStudent
                      ? [AppColors.primary, AppColors.primaryDark]
                      : isAdmin
                          ? [Colors.indigo, Colors.indigoAccent]
                          : [const Color(0xFF2e7d32), const Color(0xFF1b5e20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/rit_logo.jpg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RIT College ERP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    isStudent
                        ? 'Student Portal'
                        : isAdmin
                            ? 'Admin Portal'
                            : 'Mentor Portal',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final item in _navItems)
                    ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      selected: item.route == currentRoute,
                      selectedTileColor: scheme.secondaryContainer,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (item.route != currentRoute) {
                          Navigator.of(context).pushReplacementNamed(item.route);
                        }
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
