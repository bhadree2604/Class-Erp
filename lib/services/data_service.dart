import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance.dart';
import '../models/certificate.dart';
import '../models/event.dart';
import '../models/meeting.dart';
import '../models/grade.dart';
import '../models/mentor_student.dart';
import '../models/parent_message.dart';
import '../models/semester_report.dart';
import '../models/student_profile.dart';

/// Port of `shared-data.js` (the DataSync object).
/// All data is persisted via shared_preferences using the same storage keys
/// as the legacy web app.
class DataService {
  DataService._();

  static final DataService instance = DataService._();

  static const _studentsKey = 'allStudentsData';
  static const _eventsKey = 'events';
  static const _meetingsKey = 'meetings';
  static const _seededKey = 'data_seeded';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> initialize() async { final prefs = await _store; if (prefs.getBool(_seededKey) ?? false) return; await prefs.setBool(_seededKey, true); }

  static const defaultStudentId = 'RIT2024CS001';

  static StudentProfile _defaultProfile() { return const StudentProfile( userId: '', username: '', email: '', fullName: '', phone: '', department: '', semester: '', batch: '', section: '', cgpa: 0.0, gpa: 0.0, arrears: 0, attendance: 0, profilePicture: null, currentAddress: '', permanentAddress: '', activities: const [], certificates: const [], parentReportMessages: const [], ); }

  // ---------- Student profile ----------

  Future<Map<String, dynamic>> _loadStudentsMap() async {
    final prefs = await _store;
    final raw = prefs.getString(_studentsKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<StudentProfile> getStudentData(String studentId) async {
    final all = await _loadStudentsMap();
    final json = all[studentId];
    if (json != null) {
      return StudentProfile.fromJson(json as Map<String, dynamic>);
    }
    final def = _defaultProfile();
    return def.copyWith(userId: studentId);
  }

  Future<void> saveStudentData(String studentId, Map<String, dynamic> data) async {
    final prefs = await _store;
    final all = await _loadStudentsMap();
    final existing = all[studentId];
    if (existing is Map<String, dynamic>) {
      all[studentId] = {...existing, ...data};
    } else {
      all[studentId] = data;
    }
    await prefs.setString(_studentsKey, jsonEncode(all));
  }

  Future<void> saveStudentProfile(String studentId, StudentProfile profile) {
    return saveStudentData(studentId, profile.toJson());
  }

  Future<void> saveProfilePicture(String studentId, String imageData) async {
    final profile = await getStudentData(studentId);
    await saveStudentProfile(studentId, profile.copyWith(profilePicture: imageData));
  }

  Future<String?> getProfilePicture(String studentId) async {
    final profile = await getStudentData(studentId);
    return profile.profilePicture;
  }

  // ---------- Certificates ----------

  Future<void> addCertificate(String studentId, Certificate certificate) async {
    final profile = await getStudentData(studentId);
    final certificates = [...profile.certificates, certificate];
    await saveStudentProfile(
        studentId, profile.copyWith(certificates: certificates));
  }

  Future<List<Certificate>> getCertificates(String studentId) async {
    final profile = await getStudentData(studentId);
    return profile.certificates;
  }

  // ---------- Events ----------

  Future<List<Event>> getEvents() async {
    final prefs = await _store;
    final raw = prefs.getString(_eventsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEvents(List<Event> events) async {
    final prefs = await _store;
    await prefs.setString(
        _eventsKey, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  Future<void> addEvent(Event event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  Future<void> deleteEvent(int id) async {
    final events = await getEvents();
    events.removeWhere((e) => e.id == id);
    await saveEvents(events);
  }

  // ---------- Meetings ----------

  Future<List<Meeting>> getMeetings() async {
    final prefs = await _store;
    final raw = prefs.getString(_meetingsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMeetings(List<Meeting> meetings) async {
    final prefs = await _store;
    await prefs.setString(
        _meetingsKey, jsonEncode(meetings.map((e) => e.toJson()).toList()));
  }

  Future<void> addMeeting(Meeting meeting) async {
    final meetings = await getMeetings();
    meetings.add(meeting);
    await saveMeetings(meetings);
  }

  Future<void> updateMeeting(Meeting meeting) async {
    final meetings = await getMeetings();
    final idx = meetings.indexWhere((m) => m.id == meeting.id);
    if (idx != -1) {
      meetings[idx] = meeting;
      await saveMeetings(meetings);
    }
  }

  Future<void> deleteMeeting(int id) async {
    final meetings = await getMeetings();
    meetings.removeWhere((m) => m.id == id);
    await saveMeetings(meetings);
  }

  // ---------- Parent report messages ----------

  Future<void> addParentReportMessage(
      String studentId, ParentMessage message) async {
    final profile = await getStudentData(studentId);
    final messages = [...profile.parentReportMessages, message];
    await saveStudentProfile(
        studentId, profile.copyWith(parentReportMessages: messages));
  }

  Future<List<ParentMessage>> getParentReportMessages(String studentId) async {
    final profile = await getStudentData(studentId);
    return profile.parentReportMessages;
  }

  // ---------- Attendance ----------

  String _attendanceKey(String studentId) => 'attendance_$studentId';

  Future<List<AttendanceRecord>> getAttendance(String studentId) async {
    final prefs = await _store;
    final raw = prefs.getString(_attendanceKey(studentId));
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAttendanceRecord(String studentId, AttendanceRecord record) async {
    final records = await getAttendance(studentId);
    records.add(record);
    final prefs = await _store;
    await prefs.setString(
        _attendanceKey(studentId), jsonEncode(records.map((e) => e.toJson()).toList()));
  }

  // ---------- Grades ----------

  static const _gradesKey = 'studentGrades';

  String _gradeStudentKey(String studentId) => studentId;

  Future<List<Grade>> getGrades(String studentId) async {
    final prefs = await _store;
    final raw = prefs.getString(_gradesKey);
    if (raw == null) return [];
    final all = jsonDecode(raw) as Map<String, dynamic>;
    final entry = all[_gradeStudentKey(studentId)];
    if (entry is List) {
      return entry.map((e) => Grade.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> saveGrades(String studentId, List<Grade> grades) async {
    final prefs = await _store;
    final raw = prefs.getString(_gradesKey);
    final all = raw != null ? jsonDecode(raw) as Map<String, dynamic> : <String, dynamic>{};
    all[_gradeStudentKey(studentId)] = grades.map((e) => e.toJson()).toList();
    await prefs.setString(_gradesKey, jsonEncode(all));
  }

  // ---------- Mentor: students ----------

  static const _mentorStudentsKey = 'mentorStudents';
  static const _academicReportsKey = 'studentAcademicReports';
  static const _courseAssignmentsKey = 'studentCourseAssignments';

  Future<List<MentorStudent>> getMentorStudents() async {
    final prefs = await _store;
    final raw = prefs.getString(_mentorStudentsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => MentorStudent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMentorStudents(List<MentorStudent> students) async {
    final prefs = await _store;
    await prefs.setString(
        _mentorStudentsKey, jsonEncode(students.map((e) => e.toJson()).toList()));
  }

  /// Returns an error message, or null on success. Mirrors mentor/students.html.
  Future<String?> addMentorStudent({
    required String name,
    required String rollNo,
    required String department,
    required int semester,
  }) async {
    if (name.isEmpty || rollNo.isEmpty || department.isEmpty || semester <= 0) {
      return 'Please fill in all fields!';
    }
    final students = await getMentorStudents();
    if (students.any((s) => s.rollNo == rollNo)) {
      return 'A student with this roll number already exists!';
    }
    students.add(MentorStudent(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      rollNo: rollNo,
      department: department,
      semester: semester,
      addedDate: DateTime.now().toIso8601String(),
    ));
    await saveMentorStudents(students);
    return null;
  }

  Future<void> removeMentorStudent(int studentId) async {
    final students = await getMentorStudents();
    final removed = students.firstWhere((s) => s.id == studentId, orElse: () => students.first);
    await saveMentorStudents(
        students.where((s) => s.id != studentId).toList());

    final prefs = await _store;
    final assignments = jsonDecode(prefs.getString(_courseAssignmentsKey) ?? '{}')
        as Map<String, dynamic>;
    assignments.remove(removed.rollNo);
    await prefs.setString(_courseAssignmentsKey, jsonEncode(assignments));
  }

  /// Loads the per-semester academic report for a student, generating a
  /// sample report (like the web app) when none exists yet.
  Future<List<SemesterReport>> getAcademicReport(MentorStudent student) async {
    final prefs = await _store;
    final all = jsonDecode(prefs.getString(_academicReportsKey) ?? '{}')
        as Map<String, dynamic>;

    final existing = all['${student.id}'];
    if (existing is Map<String, dynamic> &&
        (existing['semesters'] as List?)?.isNotEmpty == true) {
      return ((existing['semesters'] as List? ?? const []))
          .map((e) => SemesterReport.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final rand = Random(student.id);
    final reports = <SemesterReport>[];
    for (var i = 1; i < student.semester; i++) {
      reports.add(SemesterReport(
        semester: i,
        gpa: (rand.nextDouble() * 2 + 7).toStringAsFixed(2),
        percentage: (rand.nextDouble() * 15 + 70).toStringAsFixed(1),
        status: 'Completed',
      ));
    }
    if (student.semester <= 8) {
      reports.add(SemesterReport(
        semester: student.semester,
        gpa: '-',
        percentage: '-',
        status: 'In Progress',
      ));
    }

    all['${student.id}'] = {'semesters': reports.map((e) => e.toJson()).toList()};
    await prefs.setString(_academicReportsKey, jsonEncode(all));
    return reports;
  }

  /// Course codes assigned to each student (mentor-side assignment).
  Future<List<String>> getStudentCourseCodes(String studentId) async {
    final prefs = await _store;
    final all = jsonDecode(prefs.getString(_courseAssignmentsKey) ?? '{}')
        as Map<String, dynamic>;
    final entry = all[studentId];
    if (entry is Map<String, dynamic>) {
      return (entry['courses'] as List? ?? const [])
          .map((e) => e.toString())
          .toList();
    }
    return [];
  }

  Future<void> saveStudentCourseCodes(String studentId, List<String> codes) async {
    final prefs = await _store;
    final all = jsonDecode(prefs.getString(_courseAssignmentsKey) ?? '{}')
        as Map<String, dynamic>;
    all[studentId] = {'courses': codes};
    await prefs.setString(_courseAssignmentsKey, jsonEncode(all));
  }

  /// Same logic as DataSync.calculateGPA — simple average of grade points.
  static double calculateGPA(List<Grade> grades) {
    if (grades.isEmpty) return 0;
    final total = grades.fold<double>(0, (sum, g) => sum + g.gradePoint);
    return double.parse((total / grades.length).toStringAsFixed(2));
  }
}


