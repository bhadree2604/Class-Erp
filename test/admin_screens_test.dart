import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rit_erp/screens/admin/admin_mentors.dart';
import 'package:rit_erp/screens/admin/admin_students.dart';
import 'package:rit_erp/theme.dart';

const _admin = {
  'user_id': 'A0001',
  'username': 'admin',
  'password': 'admin123',
  'email': 'admin@admin.com',
  'full_name': 'System Administrator',
  'phone': '0000000000',
  'department': 'Administration',
  'user_type': 'admin',
};

Future<void> _seedStorage(Map<String, dynamic> users) async {
  SharedPreferences.setMockInitialValues({
    'college_erp_users': jsonEncode(users),
    'users_initialized': true,
    // Academic profile for the seeded student (DataService storage).
    'allStudentsData': jsonEncode({
      '953625104001': {
        'user_id': '953625104001',
        'semester': '6',
        'batch': '2025-2029',
        'section': 'A',
        'attendance': 87,
        'cgpa': 8.65,
        'gpa': 8.9,
        'arrears': 0,
      }
    }),
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.light, home: child);

  final Finder detailsArrow = find.byTooltip('View Details');

  testWidgets(
      'View Details dialog shows REAL student data incl. attendance & CGPA',
      (tester) async {
    await _seedStorage({
      'students': [
        {
          'user_id': '953625104001',
          'username': 'test@ritrjpm.ac.in',
          'password': 'test1234',
          'email': 'test@ritrjpm.ac.in',
          'full_name': 'Ravi Kumar',
          'phone': '9876500001',
          'department': 'Computer Science',
          'user_type': 'student',
        }
      ],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    await tester.pumpWidget(wrap(const AdminStudentsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Ravi Kumar'), findsOneWidget);

    await tester.tap(detailsArrow);
    await tester.pumpAndSettle();

    // Real per-user values from the auth record:
    expect(find.text('953625104001'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsNWidgets(2)); // title + detail row
    expect(find.text('test@ritrjpm.ac.in'), findsOneWidget);
    expect(find.text('9876500001'), findsOneWidget);
    expect(find.text('Computer Science'), findsOneWidget);
    // Real academic values loaded from DataService profile:
    expect(find.text('6'), findsOneWidget); // semester
    expect(find.text('2025-2029'), findsOneWidget); // batch
    expect(find.text('A'), findsOneWidget); // section
    expect(find.text('87%'), findsOneWidget); // attendance
    expect(find.text('8.65'), findsOneWidget); // CGPA
    expect(find.text('8.90'), findsOneWidget); // GPA

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'View Details dialog shows REAL mentor data (designation, qualification, experience)',
      (tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': [
        {
          'user_id': 'M2024002',
          'username': 'mentor@ritrjpm.ac.in',
          'password': 'mentor1234',
          'email': 'mentor@ritrjpm.ac.in',
          'full_name': 'Dr. Priya',
          'phone': '9876500002',
          'department': 'Electronics',
          'designation': 'Associate Professor',
          'qualification': 'Ph.D',
          'experience': '7',
          'user_type': 'mentor',
        }
      ],
      'admins': [_admin],
    });

    await tester.pumpWidget(wrap(const AdminMentorsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Priya'), findsOneWidget);

    await tester.tap(detailsArrow);
    await tester.pumpAndSettle();

    expect(find.text('M2024002'), findsOneWidget);
    expect(find.text('mentor@ritrjpm.ac.in'), findsOneWidget);
    expect(find.text('9876500002'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Associate Professor'), findsOneWidget);
    expect(find.text('Ph.D'), findsOneWidget);
    expect(find.text('7 years'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Genuinely-empty list shows "No ... yet" WITHOUT Clear-search link',
      (tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    await tester.pumpWidget(wrap(const AdminStudentsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('No students yet.'), findsOneWidget);
    expect(find.text('Create one to get started.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing); // search bar hidden when empty
    expect(find.text('Clear search'), findsNothing);

    await tester.pumpWidget(wrap(const AdminMentorsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('No mentors yet.'), findsOneWidget);
    expect(find.text('Clear search'), findsNothing);
  });

  testWidgets(
      'Active search with zero matches shows no-results message WITH Clear search',
      (tester) async {
    await _seedStorage({
      'students': [
        {
          'user_id': '953625104001',
          'username': 'test@ritrjpm.ac.in',
          'password': 'test1234',
          'email': 'test@ritrjpm.ac.in',
          'full_name': 'Ravi Kumar',
          'phone': '9876500001',
          'department': 'Computer Science',
          'user_type': 'student',
        }
      ],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    await tester.pumpWidget(wrap(const AdminStudentsScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz-does-not-exist');
    await tester.pump();

    expect(find.text('No students match your search.'), findsOneWidget);
    expect(find.text('Try a different roll number or name.'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);
    // The true-empty message must NOT appear mid-search.
    expect(find.text('No students yet.'), findsNothing);
  });
}