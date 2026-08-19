import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String userId;
  final String username;
  final String password;
  final String email;
  final String fullName;
  final String phone;
  final String userType;
  final Map<String, dynamic> extra;

  const User({
    required this.userId,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.userType,
    this.extra = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'password': password,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'user_type': userType,
      ...extra,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      userType: json['user_type'] as String? ?? '',
      extra: Map<String, dynamic>.from(json),
    );
  }

  String get department => extra['department'] as String? ?? '';
  String get semester => extra['semester'] as String? ?? '';
  String get batch => extra['batch'] as String? ?? '';
  String get section => extra['section'] as String? ?? '';
  String get designation => extra['designation'] as String? ?? '';
  String get qualification => extra['qualification'] as String? ?? '';
  String get experience => extra['experience'] as String? ?? '';

  bool get isStudent => userType == 'student';
  bool get isMentor => userType == 'mentor';
}

/// Port of `auth.js` — login/logout/createUser with two hardcoded demo
/// users, persisted via shared_preferences instead of localStorage/cookies.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _usersKey = 'college_erp_users';
  static const _usersInitializedKey = 'users_initialized';
  static const _currentUserKey = 'current_user';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Seeds the two demo users (same credentials as the web app):
  /// student  bhadree / bhadree123
  /// mentor   maha    / maha123
  Future<void> initialize() async {
    final prefs = await _store;
    final alreadySet = prefs.getBool(_usersInitializedKey) ?? false;
    final hasData = prefs.getString(_usersKey) != null;

    if (!alreadySet || !hasData) {
      final users = {
        'students': [
          {
            'user_id': '953625104001',
            'username': 'bhadree',
            'password': 'bhadree123',
            'email': 'bhadree@student.rit.edu',
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
            'username': 'maha',
            'password': 'maha123',
            'email': 'maha@rit.edu',
            'full_name': 'Dr. Maha',
            'phone': '9876543211',
            'department': 'Computer Science',
            'designation': 'Professor',
            'qualification': 'Ph.D',
            'experience': '10',
            'user_type': 'mentor',
          }
        ],
      };
      await prefs.setString(_usersKey, jsonEncode(users));
      await prefs.setBool(_usersInitializedKey, true);
    }
  }

  Future<Map<String, dynamic>?> _loadUsers() async {
    final prefs = await _store;
    final raw = prefs.getString(_usersKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _loadUsersOrSeed() async {
    await initialize();
    final users = await _loadUsers();
    if (users == null) {
      return {'students': <dynamic>[], 'mentors': <dynamic>[]};
    }
    return users;
  }

  /// Returns the logged-in user on success, or null on failure.
  Future<User?> login(String username, String password, String role) async {
    final users = await _loadUsersOrSeed();
    final listName = role == 'student' ? 'students' : 'mentors';
    final list = (users[listName] as List?) ?? const [];
    for (final raw in list) {
      final json = raw as Map<String, dynamic>;
      if (json['username'] == username && json['password'] == password) {
        final user = User.fromJson({...json, 'user_type': role});
        await saveCurrentUser(user);
        return user;
      }
    }
    return null;
  }

  Future<void> saveCurrentUser(User? user) async {
    final prefs = await _store;
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    }
  }

  Future<User?> getCurrentUser() async {
    final prefs = await _store;
    final raw = prefs.getString(_currentUserKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> logout() => saveCurrentUser(null);

  /// Mirrors `createUser` in auth.js. Returns an error string, or null on success.
  Future<String?> createUser(Map<String, dynamic> userData) async {
    final users = await _loadUsersOrSeed();
    final listName = userData['user_type'] == 'student' ? 'students' : 'mentors';
    final list = (users[listName] as List?) ?? [];

    for (final raw in list) {
      final json = raw as Map<String, dynamic>;
      if (json['username'] == userData['username'] ||
          json['email'] == userData['email'] ||
          json['user_id'] == userData['user_id']) {
        return 'User already exists';
      }
    }

    list.add(userData);
    users[listName] = list;
    final prefs = await _store;
    await prefs.setString(_usersKey, jsonEncode(users));
    return null;
  }

  Future<List<User>> getAllUsers(String role) async {
    final users = await _loadUsersOrSeed();
    final listName = role == 'student' ? 'students' : 'mentors';
    final list = (users[listName] as List?) ?? const [];
    return list
        .map((raw) => User.fromJson({
              ...(raw as Map<String, dynamic>),
              'user_type': role,
            }))
        .toList();
  }
}