import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/admin/admin_create_user.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_mentors.dart';
import 'screens/admin/admin_students.dart';
import 'screens/login_screen.dart';
import 'screens/mentor/mentor_certificates.dart';
import 'screens/mentor/mentor_courses.dart';
import 'screens/mentor/mentor_dashboard.dart';
import 'screens/mentor/mentor_events.dart';
import 'screens/mentor/mentor_grades.dart';
import 'screens/mentor/mentor_attendance.dart';
import 'screens/mentor/mentor_forgot_password.dart';
import 'screens/mentor/mentor_meetings.dart';
import 'screens/mentor/mentor_parent_report.dart';
import 'screens/mentor/mentor_performance.dart';
import 'screens/mentor/mentor_profile.dart';
import 'screens/mentor/mentor_profile_edit.dart';
import 'screens/mentor/mentor_reports.dart';
import 'screens/mentor/mentor_settings.dart';
import 'screens/mentor/mentor_students.dart';
import 'screens/student/student_attendance.dart';
import 'screens/student/student_certificates.dart';
import 'screens/student/student_courses.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/student_events.dart';
import 'screens/student/student_forgot_password.dart';
import 'screens/student/student_grades.dart';
import 'screens/student/student_meetings.dart';
import 'screens/student/student_parent_report.dart';
import 'screens/student/student_profile.dart';
import 'screens/student/student_profile_edit.dart';
import 'screens/student/student_settings.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.initialize();

  // DEBUG: Print users map to verify admin account exists
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('college_erp_users');
  if (raw != null) {
    print('=== DEBUG: Users map after initialize ===');
    print(raw);
    print('==========================================');
  }

  await DataService.instance.initialize();
  // Check for existing session
  final currentUser = await AuthService.instance.getCurrentUser();
  Widget startPage;
  if (currentUser != null) {
    if (currentUser.isStudent) {
      startPage = const StudentDashboardScreen();
    } else if (currentUser.isMentor) {
      startPage = const MentorDashboardScreen();
    } else if (currentUser.isAdmin) {
      startPage = const AdminDashboardScreen();
    } else {
      startPage = const LoginScreen();
    }
  } else {
    startPage = const LoginScreen();
  }
  runApp(MyClassApp(startPage: startPage, key: myAppKey));
}

final GlobalKey<MyClassAppState> myAppKey = GlobalKey<MyClassAppState>();

class MyClassApp extends StatefulWidget {
  final Widget startPage;

  const MyClassApp({Key? key, required this.startPage}) : super(key: key);

  static void setThemeMode(ThemeMode mode) {
    myAppKey.currentState?.setThemeMode(mode);
  }

  @override
  State<MyClassApp> createState() => MyClassAppState();
}

class MyClassAppState extends State<MyClassApp> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme_mode') ?? 'light';
    setState(() {
      _themeMode = _themeModeFromString(value);
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeModeToString(mode));
    setState(() {
      _themeMode = mode;
    });
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'light';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RIT College ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        // Student portal
        AppRoutes.studentDashboard: (_) => const StudentDashboardScreen(),
        AppRoutes.studentAttendance: (_) => const StudentAttendanceScreen(),
        AppRoutes.studentGrades: (_) => const StudentGradesScreen(),
        AppRoutes.studentCourses: (_) => const StudentCoursesScreen(),
        AppRoutes.studentMeetings: (_) => const StudentMeetingsScreen(),
        AppRoutes.studentEvents: (_) => const StudentEventsScreen(),
        AppRoutes.studentCertificates: (_) => const StudentCertificatesScreen(),
        AppRoutes.studentParentReport: (_) => const StudentParentReportScreen(),
        AppRoutes.studentProfile: (_) => const StudentProfileScreen(),
        AppRoutes.studentProfileEdit: (_) => const StudentProfileEditScreen(),
        AppRoutes.studentSettings: (_) => const StudentSettingsScreen(),
        AppRoutes.studentForgotPassword: (_) => const StudentForgotPasswordScreen(),
        // Mentor portal
        AppRoutes.mentorDashboard: (_) => const MentorDashboardScreen(),
        AppRoutes.mentorStudents: (_) => const MentorStudentsScreen(),
        AppRoutes.mentorCourses: (_) => const MentorCoursesScreen(),
        AppRoutes.mentorEvents: (_) => const MentorEventsScreen(),
        AppRoutes.mentorCertificates: (_) => const MentorCertificatesScreen(),
        AppRoutes.mentorReports: (_) => const MentorReportsScreen(),
        AppRoutes.mentorMeetings: (_) => const MentorMeetingsScreen(),
        AppRoutes.mentorPerformance: (_) => const MentorPerformanceScreen(),
        AppRoutes.mentorGrades: (_) => const MentorGradesScreen(),
        AppRoutes.mentorAttendance: (_) => const MentorAttendanceScreen(),
        AppRoutes.mentorParentReport: (_) => const MentorParentReportScreen(),
        AppRoutes.mentorProfile: (_) => const MentorProfileScreen(),
        AppRoutes.mentorProfileEdit: (_) => const MentorProfileEditScreen(),
        AppRoutes.mentorSettings: (_) => const MentorSettingsScreen(),
        AppRoutes.mentorForgotPassword: (_) => const MentorForgotPasswordScreen(),
        // Admin portal
        AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
        AppRoutes.adminStudents: (_) => const AdminStudentsScreen(),
        AppRoutes.adminMentors: (_) => const AdminMentorsScreen(),
        AppRoutes.adminCreateUser: (_) => const AdminCreateUserScreen(),
      },
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.2).toDouble(),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
