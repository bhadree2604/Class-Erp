import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rit_erp/main.dart';
import 'package:rit_erp/services/auth_service.dart';
import 'package:rit_erp/screens/login_screen.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AuthService.authOverride = MockFirebaseAuth();
    AuthService.firestoreOverride = MockFirebaseFirestore();
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/google_sign_in'), null);
    AuthService.instance.testSignInWithCredential = null;
    AuthService.instance.testSignOut = null;
    AuthService.authOverride = null;
    AuthService.firestoreOverride = null;
  });

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
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString('college_erp_users', jsonEncode(users));
    await prefs.setBool('users_initialized', true);
  }

  void _mockGoogleChannel(WidgetTester tester, {required String email}) {
    // No-op
  }

  testWidgets('Login screen shows dark-theme layout', (WidgetTester tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    await tester.pumpWidget(MyClassApp(startPage: const LoginScreen(), key: myAppKey));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Please login to continue'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('OR WITH EMAIL'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));

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
      (WidgetTester tester) async {
    await _seedStorage({
      'students': <dynamic>[],
      'mentors': <dynamic>[],
      'admins': [_admin],
    });

    await tester.pumpWidget(MyClassApp(startPage: const LoginScreen(), key: myAppKey));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter college email and password.'),
        findsOneWidget);
  });

  testWidgets('Email/password login still works end-to-end',
      (WidgetTester tester) async {
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

    await tester.pumpWidget(MyClassApp(startPage: const LoginScreen(), key: myAppKey));
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
}