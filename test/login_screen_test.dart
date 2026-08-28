import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rit_erp/main.dart';
import 'package:rit_erp/services/auth_service.dart';

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

/// Single live prefs instance shared by every test (services cache their
/// SharedPreferences forever; cache the RESOLVED instance, never the
/// Future — awaiting a Future from an earlier FakeAsync zone deadlocks).
SharedPreferences? _livePrefs;

Future<void> _seedStorage(Map<String, dynamic> users) async {
  var prefs = _livePrefs;
  if (prefs == null) {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = _livePrefs = await SharedPreferences.getInstance();
  }
  await prefs.clear();
  await prefs.setString('college_erp_users', jsonEncode(users));
  await prefs.setBool('users_initialized', true);
}

/// Mocks the google_sign_in platform channel. [email] null simulates the
/// user closing the account chooser.
void _mockGoogleChannel(WidgetTester tester, {String? email}) {
  const channel = MethodChannel('plugins.flutter.io/google_sign_in');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (call) async {
      switch (call.method) {
        case 'init':
        case 'isSignedIn':
          return true;
        case 'signInSilently':
          return null;
        case 'signIn':
          return email == null
              ? null
              : <String, dynamic>{
                  'id': 'google-id-1',
                  'email': email,
                  'displayName': 'G User',
                  'photoUrl': null,
                };
        case 'getTokens':
          return <String, dynamic>{
            'accessToken': 'mock-access-token',
            'idToken': 'mock-id-token',
          };
        case 'clearAuthCache':
          return true;
        case 'signOut':
        case 'disconnect':
          return true;
        default:
          return null;
      }
    },
  );
}

// Use the real app so all dashboard routes exist for post-login navigation.
Widget _wrap() => MyClassApp(startPage: const LoginScreen(), key: myAppKey);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/google_sign_in'), null);
    AuthService.instance.testSignInWithCredential = null;
    AuthService.instance.testSignOut = null;
  });

  testWidgets(
      'Login screen shows dark-theme layout: Google button, divider, fields, eye icon, Sign in',
      (tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // Existing elements preserved.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Please login to continue'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    // New elements.
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('OR WITH EMAIL'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
    // Google button + Sign in button.
    expect(find.byType(ElevatedButton), findsNWidgets(2));

    // Eye toggle flips visibility.
    final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Enter your password').last);
    expect(field.obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    final field2 = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Enter your password').last);
    expect(field2.obscureText, isFalse);
  });

  testWidgets('Email/password login validation unchanged: empty -> error',
      (tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter college email and password.'),
        findsOneWidget);
  });

  testWidgets('Email/password login still works end-to-end', (tester) async {
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

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Enter your college email'),
        'test@ritrjpm.ac.in');
    await tester.enterText(
        find.widgetWithText(TextField, 'Enter your password').last,
        'test1234');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final current = await AuthService.instance.getCurrentUser();
    expect(current, isNotNull);
    expect(current!.fullName, 'Ravi Kumar');
    expect(current.isStudent, isTrue);
  });

  testWidgets(
      'Google sign-in with UNKNOWN email shows "No account found", does not log in',
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
    _mockGoogleChannel(tester, email: 'stranger@gmail.com');
    AuthService.instance.testSignInWithCredential = (_) async {};
    AuthService.instance.testSignOut = () async {};

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    expect(find.textContaining('No account found for this email'),
        findsOneWidget);

    final current = await AuthService.instance.getCurrentUser();
    expect(current, isNull); // nobody was silently logged in
  });

  testWidgets(
      'Google sign-in with MATCHING email logs into that existing account',
      (tester) async {
    await _seedStorage({
      'students': [
        {
          'user_id': '953625104001',
          'username': 'test@ritrjpm.ac.in',
          'password': 'test1234',
          'email': 'ravi@gmail.com',
          'full_name': 'Ravi Kumar',
          'phone': '9876500001',
          'department': 'Computer Science',
          'user_type': 'student',
        }
      ],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });
    _mockGoogleChannel(tester, email: 'Ravi@gmail.com'); // case-insensitive
    AuthService.instance.testSignInWithCredential = (_) async {};
    AuthService.instance.testSignOut = () async {};

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final current = await AuthService.instance.getCurrentUser();
    expect(current, isNotNull);
    expect(current!.fullName, 'Ravi Kumar');
    expect(current.isStudent, isTrue);
    expect(current.email.toLowerCase(), 'ravi@gmail.com');
  });

  test('findUserByEmail matches case-insensitively across roles', () async {
    await _seedStorage({
      'students': [
        {
          'user_id': '953625104001',
          'username': 'test@ritrjpm.ac.in',
          'password': 'x',
          'email': 'Test@RitrJpm.ac.in',
          'full_name': 'Ravi Kumar',
          'phone': '',
          'user_type': 'student',
        }
      ],
      'mentors': [
        {
          'user_id': 'M2024002',
          'username': 'm@ritrjpm.ac.in',
          'password': 'x',
          'email': 'mentor@ritrjpm.ac.in',
          'full_name': 'Priya',
          'phone': '',
          'user_type': 'mentor',
        }
      ],
      'admins': [_admin],
    });

    final s = await AuthService.instance.findUserByEmail('TEST@ritrjpm.ac.in');
    expect(s, isNotNull);
    expect(s!.isStudent, isTrue);

    final m =
        await AuthService.instance.findUserByEmail('MENTOR@ritrjpm.ac.in');
    expect(m, isNotNull);
    expect(m!.isMentor, isTrue);

    final none = await AuthService.instance.findUserByEmail('nope@x.com');
    expect(none, isNull);
  });
}
