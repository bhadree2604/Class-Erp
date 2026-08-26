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
}