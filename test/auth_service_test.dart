import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../lib/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Set up mock users first
    final mockUsers = {
      'students': [
        {
          'user_id': '953625104001',
          'username': '953625104029@ritrjpm.ac.in',
          'password': 'student123',
          'email': '953625104029@ritrjpm.ac.in',
          'full_name': 'Bhadree',
          'phone': '9876543210',
          'department': 'Computer Science',
          'semester': '6',
          'batch': '2025-2029',
          'section': 'A',
          'user_type': 'student',
        }
      ],
      'mentors': [
        {
          'user_id': 'M2024001',
          'username': 'maha@ritrjpm.ac.in',
          'password': 'mentor123',
          'email': 'maha@ritrjpm.ac.in',
          'full_name': 'Dr. Maha',
          'phone': '9876543211',
          'department': 'Computer Science',
          'designation': 'Professor',
          'qualification': 'Ph.D',
          'experience': '10',
          'user_type': 'mentor',
        }
      ],
      'admins': [
        {
          'user_id': 'A0001',
          'username': 'admin',
          'password': 'Admin123!',
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

  test('login admin, student, mentor', () async {
    final auth = AuthService.instance;

    // Admin login
    final adminUser = await auth.login('admin', 'Admin123!');
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

    // Student login
    final studentUser = await auth.login(
        '953625104029@ritrjpm.ac.in', 'student123');
    expect(studentUser, isNotNull);
    if (studentUser != null) {
      print('Student login succeeded: ${studentUser.fullName} (${studentUser.email})');
    } else {
      print('Student login failed');
    }

    // Logout
    await auth.logout();
    final current2 = await auth.getCurrentUser();
    expect(current2, isNull);
    print('After student logout, current user: $current2');

    // Mentor login
    final mentorUser = await auth.login('maha@ritrjpm.ac.in', 'mentor123');
    expect(mentorUser, isNotNull);
    if (mentorUser != null) {
      print('Mentor login succeeded: ${mentorUser.fullName} (${mentorUser.email})');
    } else {
      print('Mentor login failed');
    }

    // Logout
    await auth.logout();
    final current3 = await auth.getCurrentUser();
    expect(current3, isNull);
    print('After mentor logout, current user: $current3');
  });
}