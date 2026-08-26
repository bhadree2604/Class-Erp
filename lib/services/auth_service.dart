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
  bool get isAdmin => userType == 'admin';
}

/// Port of `auth.js` — login/logout/createUser with hardcoded demo
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

  /// Seeds the demo users (student, mentor) and a default admin account.
  /// student  student / student123
  /// mentor   mentor  / mentor123
  /// admin    admin   / Admin123!
  Future<void> initialize() async {
    final prefs = await _store;
    final alreadySet = prefs.getBool(_usersInitializedKey) ?? false;
    final hasData = prefs.getString(_usersKey) != null;

    if (!alreadySet || !hasData) {
      final users = {
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
      return {
        'students': <dynamic>[],
        'mentors': <dynamic>[],
        'admins': <dynamic>[]
      };
    }
    // Ensure admins key exists
    if (!users.containsKey('admins')) {
      users['admins'] = <dynamic>[];
    }
    return users;
  }

  /// Returns the logged-in user on success, or null on failure.
  /// Searches students, mentors, and admins lists.
  Future<User?> login(String username, String password) async {
    final users = await _loadUsersOrSeed();
    // search students
    final studentsList = (users['students'] as List?) ?? const [];
    for (final raw in studentsList) {
      final json = raw as Map<String, dynamic>;
      if (json['username'] == username && json['password'] == password) {
        final user = User.fromJson({...json, 'user_type': 'student'});
        await saveCurrentUser(user);
        return user;
      }
    }
    // search mentors
    final mentorsList = (users['mentors'] as List?) ?? const [];
    for (final raw in mentorsList) {
      final json = raw as Map<String, dynamic>;
      if (json['username'] == username && json['password'] == password) {
        final user = User.fromJson({...json, 'user_type': 'mentor'});
        await saveCurrentUser(user);
        return user;
      }
    }
    // search admins
    final adminsList = (users['admins'] as List?) ?? const [];
    for (final raw in adminsList) {
      final json = raw as Map<String, dynamic>;
      if (json['username'] == username && json['password'] == password) {
        final user = User.fromJson({...json, 'user_type': 'admin'});
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
    final listName = userData['user_type'] == 'student'
        ? 'students'
        : userData['user_type'] == 'mentor'
            ? 'mentors'
            : 'admins';
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
    String listName;
    if (role == 'student') {
      listName = 'students';
    } else if (role == 'mentor') {
      listName = 'mentors';
    } else if (role == 'admin') {
      listName = 'admins';
    } else {
      throw ArgumentError('Invalid role: $role');
    }
    final list = (users[listName] as List?) ?? const [];
    return list
        .map((raw) => User.fromJson({
              ...(raw as Map<String, dynamic>),
              'user_type': role,
            }))
        .toList();
  }

  /// Update any user's fields by userId.
  Future<String?> updateUser(String userId, Map<String, dynamic> fields) async {
    final users = await _loadUsersOrSeed();
    bool updated = false;
    // Determine which list the user belongs to by checking each list for userId
    for (final role in ['students', 'mentors', 'admins']) {
      final list = (users[role] as List?) ?? [];
      for (var i = 0; i < list.length; i++) {
        final json = list[i] as Map<String, dynamic>;
        if (json['user_id'] == userId) {
          json.addAll(fields);
          // Ensure user_type stays consistent
          json['user_type'] = role.substring(0, role.length - 1); // e.g., 'students' -> 'student'
          users[role] = list;
          updated = true;
          break;
        }
      }
      if (updated) break;
    }
    if (!updated) {
      return 'User not found';
    }
    final prefs = await _store;
    await prefs.setString(_usersKey, jsonEncode(users));
    return null;
  }

  /// Delete a user by userId.
  Future<String?> deleteUser(String userId) async {
    final users = await _loadUsersOrSeed();
    bool deleted = false;
    for (final role in ['students', 'mentors', 'admins']) {
      final list = (users[role] as List?) ?? [];
      final initialLength = list.length;
      final newList = list.where((json) => (json as Map<String, dynamic>)['user_id'] != userId).toList();
      if (newList.length != initialLength) {
        users[role] = newList;
        deleted = true;
        break;
      }
    }
    if (!deleted) {
      return 'User not found';
    }
    final prefs = await _store;
    await prefs.setString(_usersKey, jsonEncode(users));
    return null;
  }

  /// Verifies [currentPassword] for the logged-in user, then updates the
  /// stored password to [newPassword].  Returns null on success or an error
  /// string.
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return 'No user logged in';

    if (currentUser.password != currentPassword) {
      return 'Current password is incorrect';
    }
    if (newPassword.length < 6) {
      return 'New password must be at least 6 characters';
    }

    final users = await _loadUsersOrSeed();
    final listName = currentUser.isStudent
        ? 'students'
        : currentUser.isMentor
            ? 'mentors'
            : 'admins';
    final list = (users[listName] as List?) ?? [];

    for (var i = 0; i < list.length; i++) {
      final json = list[i] as Map<String, dynamic>;
      if (json['username'] == currentUser.username) {
        json['password'] = newPassword;
        break;
      }
    }

    final prefs = await _store;
    await prefs.setString(_usersKey, jsonEncode(users));

    final updatedUser = User(
      userId: currentUser.userId,
      username: currentUser.username,
      password: newPassword,
      email: currentUser.email,
      fullName: currentUser.fullName,
      phone: currentUser.phone,
      userType: currentUser.userType,
      extra: currentUser.extra,
    );
    await saveCurrentUser(updatedUser);
    return null;
  }

  /// Updates the stored user data (profile fields) for the current user.
  /// [fields] should contain only the fields to update.
  Future<void> updateUserFields(Map<String, dynamic> fields) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return;

    final users = await _loadUsersOrSeed();
    final listName = currentUser.isStudent
        ? 'students'
        : currentUser.isMentor
            ? 'mentors'
            : 'admins';
    final list = (users[listName] as List?) ?? [];

    for (var i = 0; i < list.length; i++) {
      final json = list[i] as Map<String, dynamic>;
      if (json['username'] == currentUser.username) {
        json.addAll(fields);
        break;
      }
    }

    final prefs = await _store;
    await prefs.setString(_usersKey, jsonEncode(users));

    final updatedJson = {...currentUser.toJson(), ...fields};
    await saveCurrentUser(User.fromJson(updatedJson));
  }
}