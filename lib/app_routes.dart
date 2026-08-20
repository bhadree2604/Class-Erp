/// Centralized named-route table, mirroring the HTML pages of the web app.
class AppRoutes {
  AppRoutes._();

  static const landing = '/';
  static const login = '/login';

  // Student portal
  static const studentDashboard = '/student/dashboard';
  static const studentAttendance = '/student/attendance';
  static const studentGrades = '/student/grades';
  static const studentCourses = '/student/courses';
  static const studentAssignments = '/student/assignments';
  static const studentEvents = '/student/events';
  static const studentCertificates = '/student/certificates';
  static const studentParentReport = '/student/parent-report';
  static const studentProfile = '/student/profile';
  static const studentProfileEdit = '/student/profile-edit';
  static const studentSettings = '/student/settings';
  static const studentForgotPassword = '/student/forgot-password';
  static const studentCreateAccount = '/student/create-account';

  // Mentor portal
  static const mentorDashboard = '/mentor/dashboard';
  static const mentorStudents = '/mentor/students';
  static const mentorCourses = '/mentor/courses';
  static const mentorAssignments = '/mentor/assignments';
  static const mentorEvents = '/mentor/events';
  static const mentorCertificates = '/mentor/certificates';
  static const mentorReports = '/mentor/reports';
  static const mentorMeetings = '/mentor/meetings';
  static const mentorPerformance = '/mentor/performance';
  static const mentorParentReport = '/mentor/parent-report';
  static const mentorProfile = '/mentor/profile';
  static const mentorProfileEdit = '/mentor/profile-edit';
  static const mentorSettings = '/mentor/settings';
  static const mentorForgotPassword = '/mentor/forgot-password';
  static const mentorCreateAccount = '/mentor/create-account';
}