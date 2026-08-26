import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../lib/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Set up mock users - only admin
    final mockUsers = {
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [
        {
          'user_id': 'A0001',
          'username': 'admin',
          'password': 'admin123',
          'email': 'admin@admin.com',
          'full_name': 'System Administrator',
          'phone': '0000000000',
          'department': 'Administration',
          'user_type': 'admin',
        }
      ],
    };
    SharedPreferences.setMockInitialValues({
      'college_erp_users': jsonEncode(mockUsers),
      'users_initialized': true,
    });
    // Clear shared preferences before each test
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  test('login admin', () async {
    final auth = AuthService.instance;

    // Admin login
    final adminUser = await auth.login('admin', 'admin123');
    expect(adminUser, isNotNull);
    if (adminUser != null) {
      print('Admin login succeeded: ${adminUser.fullName} (${adminUser.email})');
    } else {
      print('Admin login failed');
    }

    // Logout
    await auth.logout();
    final current = await auth.getCurrentUser();
    expect(current, isNull);
    print('After admin logout, current user: $current');
  });

  test('create student, list shows it, login works', () async {
    final auth = AuthService.instance;

    // Create a student via the same path as Admin Create User form
    final studentData = {
      'username': 'test@ritrjpm.ac.in', // email is the login username
      'password': 'test1234',
      'email': 'test@ritrjpm.ac.in',
      'full_name': 'Test Student',
      'phone': '1234567890',
      'department': 'Computer Science',
      'user_type': 'student',
      'user_id': '953625104001',
    };
    final createError = await auth.createUser(studentData);
    expect(createError, isNull, reason: 'createUser should succeed');
    print('Student created successfully');

    // Verify list shows the student
    final students = await auth.getAllUsers('student');
    expect(students.length, 1, reason: 'getAllUsers should return 1 student');
    expect(students[0].userId, '953625104001');
    expect(students[0].fullName, 'Test Student');
    expect(students[0].email, 'test@ritrjpm.ac.in');
    print('Student appears in list: ${students[0].fullName} (${students[0].userId})');

    // Login with email as username (the way the form now works)
    final loginResult = await auth.login('test@ritrjpm.ac.in', 'test1234');
    expect(loginResult, isNotNull, reason: 'login should succeed with email');
    expect(loginResult!.fullName, 'Test Student');
    expect(loginResult.isStudent, isTrue);
    print('Login succeeded: ${loginResult.fullName} (${loginResult.userType})');
  });

  test('create mentor, list shows it, login works', () async {
    final auth = AuthService.instance;

    // Create a mentor
    final mentorData = {
      'username': 'mentor@ritrjpm.ac.in',
      'password': 'mentor1234',
      'email': 'mentor@ritrjpm.ac.in',
      'full_name': 'Test Mentor',
      'phone': '0987654321',
      'department': 'Electronics',
      'designation': 'Professor',
      'qualification': 'Ph.D',
      'experience': '5',
      'user_type': 'mentor',
      'user_id': 'M2024002',
    };
    final createError = await auth.createUser(mentorData);
    expect(createError, isNull, reason: 'createUser should succeed');
    print('Mentor created successfully');

    // Verify list shows the mentor
    final mentors = await auth.getAllUsers('mentor');
    expect(mentors.length, 1, reason: 'getAllUsers should return 1 mentor');
    expect(mentors[0].userId, 'M2024002');
    expect(mentors[0].fullName, 'Test Mentor');
    print('Mentor appears in list: ${mentors[0].fullName} (${mentors[0].userId})');

    // Login with email as username
    final loginResult = await auth.login('mentor@ritrjpm.ac.in', 'mentor1234');
    expect(loginResult, isNotNull, reason: 'login should succeed with email');
    expect(loginResult!.fullName, 'Test Mentor');
    expect(loginResult.isMentor, isTrue);
    print('Login succeeded: ${loginResult.fullName} (${loginResult.userType})');
  });
}