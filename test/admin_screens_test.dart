import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rit_erp/screens/admin/admin_create_user.dart';
import 'package:rit_erp/screens/admin/admin_mentors.dart';
import 'package:rit_erp/screens/admin/admin_students.dart';
import 'package:rit_erp/services/auth_service.dart';
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

/// Single live prefs instance shared by every test. AuthService and
/// DataService cache their SharedPreferences forever (process-wide
/// singletons), so ALL seeding must go through the exact same instance.
/// Cache the RESOLVED instance, never the Future: awaiting a Future
/// created in an earlier testWidgets' FakeAsync zone deadlocks.
SharedPreferences? _livePrefs;

Future<void> _seedStorage(
  Map<String, dynamic> users, {
  Map<String, dynamic> profiles = const {},
}) async {
  var prefs = _livePrefs;
  if (prefs == null) {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = _livePrefs = await SharedPreferences.getInstance();
  }
  await prefs.clear();
  await prefs.setString('college_erp_users', jsonEncode(users));
  await prefs.setString('allStudentsData', jsonEncode(profiles));
  // Prevent AuthService.initialize() from treating storage as fresh and
  // overwriting our seeded users with its admin-only seed.
  await prefs.setBool('users_initialized', true);
}

const _studentProfile = {
  'user_id': '953625104001',
  'semester': '6',
  'batch': '2025-2029',
  'section': 'A',
  'attendance': 87,
  'cgpa': 8.65,
  'gpa': 8.9,
  'arrears': 0,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.light, home: child);

  final Finder detailsArrow = find.byTooltip('View Details');

  testWidgets(
      'View Details dialog shows REAL student data incl. attendance & CGPA',
      (tester) async {
    await _seedStorage(
      {
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
      },
      profiles: {'953625104001': _studentProfile},
    );

    await tester.pumpWidget(wrap(const AdminStudentsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Ravi Kumar'), findsOneWidget);

    await tester.tap(detailsArrow);
    await tester.pumpAndSettle();

    // Real per-user values from the auth record (name appears 3x: list row
    // behind dialog + dialog title + detail row):
    expect(find.text('953625104001'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsNWidgets(3));
    // Login Email and Email rows show the same string (create flow uses
    // email as username), so it legitimately appears twice.
    expect(find.text('test@ritrjpm.ac.in'), findsNWidgets(2));
    expect(find.text('9876500001'), findsOneWidget);
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
    // Login Email + Email rows share the same string (username == email).
    expect(find.text('mentor@ritrjpm.ac.in'), findsNWidgets(2));
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

  testWidgets(
      'REAL create flow: student created via form shows real data in View Details',
      (tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    // Route stack so Navigator.pop(true) after creation lands somewhere.
    // NOTE: keep everything in ONE tree — after a pop, pumpWidget with a
    // fresh root fails to replace the tree (flutter_test quirk), so the
    // list screen is reached via pushNamed below instead.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      initialRoute: '/create',
      routes: {
        '/': (context) => const Scaffold(body: Text('admin-home')),
        '/create': (context) => const AdminCreateUserScreen(),
        '/students': (context) => const AdminStudentsScreen(),
        '/mentors': (context) => const AdminMentorsScreen(),
      },
    ));
    // Tall surface so the lazy ListView builds the submit button.
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpAndSettle();

    // Student is the default role. Form field order:
    // [roll, email, name, phone, password].
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '953625104012');
    await tester.enterText(fields.at(1), 'anita@ritrjpm.ac.in');
    await tester.enterText(fields.at(2), 'Anita Rani');
    await tester.enterText(fields.at(3), '9876511111');
    await tester.enterText(fields.at(4), 'secret123');

    // Department dropdown is the second dropdown on the form.
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Computer Science').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('CREATE USER'));
    await tester.pumpAndSettle();

    // Confirm creation really happened through the live AuthService.
    final created = await AuthService.instance.getAllUsers('student');
    expect(created.length, 1);
    expect(created.single.fullName, 'Anita Rani');

    // Now the actual user action: open All Students and tap View Details.
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/students');
    await tester.pumpAndSettle();
    expect(find.text('Anita Rani'), findsOneWidget);

    await tester.tap(detailsArrow);
    await tester.pumpAndSettle();

    // Real values entered at creation (name 3x: list row + dialog title +
    // detail row; email 2x: login email + email rows).
    expect(find.text('953625104012'), findsOneWidget);
    expect(find.text('Anita Rani'), findsNWidgets(3));
    expect(find.text('anita@ritrjpm.ac.in'), findsNWidgets(2));
    expect(find.text('9876511111'), findsOneWidget);
    expect(find.text('Computer Science'), findsOneWidget);
    // No academic profile exists yet — dialog honestly shows stored
    // defaults (0% attendance / 0.00 CGPA+GPA), not fake numbers.
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0.00'), findsNWidgets(2));

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'REAL create flow: mentor created via form shows real data in View Details',
      (tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    // Route stack so Navigator.pop(true) after creation lands somewhere.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      initialRoute: '/create',
      routes: {
        '/': (context) => const Scaffold(body: Text('admin-home')),
        '/create': (context) => const AdminCreateUserScreen(),
        '/students': (context) => const AdminStudentsScreen(),
        '/mentors': (context) => const AdminMentorsScreen(),
      },
    ));
    // Tall surface so the lazy ListView builds the submit button.
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpAndSettle();

    // Switch role to Mentor; roll field is replaced by Mentor ID.
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mentor').last);
    await tester.pumpAndSettle();

    // Field order now: [mentorId, email, name, phone, password].
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'M2026001');
    await tester.enterText(fields.at(1), 'suresh@ritrjpm.ac.in');
    await tester.enterText(fields.at(2), 'Suresh Babu');
    await tester.enterText(fields.at(3), '9876522222');
    await tester.enterText(fields.at(4), 'mentor123');

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mechanical').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('CREATE USER'));
    await tester.pumpAndSettle();

    final created = await AuthService.instance.getAllUsers('mentor');
    expect(created.length, 1);
    expect(created.single.fullName, 'Suresh Babu');

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/mentors');
    await tester.pumpAndSettle();
    expect(find.text('Suresh Babu'), findsOneWidget);

    await tester.tap(detailsArrow);
    await tester.pumpAndSettle();

    // Real values from the record the create flow wrote.
    expect(find.text('M2026001'), findsOneWidget);
    expect(find.text('Suresh Babu'), findsNWidgets(3));
    expect(find.text('suresh@ritrjpm.ac.in'), findsNWidgets(2));
    expect(find.text('9876522222'), findsOneWidget);
    expect(find.text('Mechanical'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });
}