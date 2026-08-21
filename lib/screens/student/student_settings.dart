import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_routes.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Student settings — mirror of `student/settings.html`.
class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  String _userName = 'Student';
  bool _loading = true;

  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _emailGrades = true;
  bool _smsAttendance = false;
  bool _announcements = true;
  bool _showProfile = true;
  bool _allowContact = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _emailGrades = prefs.getBool('stud_notif_emailGrades') ?? true;
      _smsAttendance = prefs.getBool('stud_notif_smsAttendance') ?? false;
      _announcements = prefs.getBool('stud_notif_announcements') ?? true;
      _showProfile = prefs.getBool('stud_privacy_showProfile') ?? true;
      _allowContact = prefs.getBool('stud_privacy_allowContact') ?? false;
      _loading = false;
    });
  }

  Future<void> _changePassword() async {
    if (_currentPwdCtrl.text.isEmpty ||
        _newPwdCtrl.text.isEmpty ||
        _confirmPwdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_newPwdCtrl.text != _confirmPwdCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match!'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_newPwdCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters!'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final error = await AuthService.instance.changePassword(
      _currentPwdCtrl.text,
      _newPwdCtrl.text,
    );
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }
    _currentPwdCtrl.clear();
    _newPwdCtrl.clear();
    _confirmPwdCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully! Please login again.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _saveNotificationPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final currentMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    return PortalScaffold(
      role: 'student',
      title: 'Settings',
      userName: _userName,
      currentRoute: AppRoutes.studentSettings,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Settings',
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Manage your account settings and preferences',
                      style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Appearance',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _themeOption('Light', ThemeMode.light, currentMode),
                        _themeOption('Dark', ThemeMode.dark, currentMode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Account Settings',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _fieldLabel('Current Password'),
                        TextField(controller: _currentPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Current Password')),
                        const SizedBox(height: 12),
                        _fieldLabel('New Password'),
                        TextField(controller: _newPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'New Password')),
                        const SizedBox(height: 12),
                        _fieldLabel('Confirm New Password'),
                        TextField(controller: _confirmPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Confirm New Password')),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _changePassword,
                          child: const Text('Update Password'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Notification Preferences',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _toggleRow('Email notifications for grades', _emailGrades, (v) {
                          setState(() => _emailGrades = v);
                          _saveNotificationPref('stud_notif_emailGrades', v);
                        }),
                        _toggleRow('SMS notifications for attendance', _smsAttendance, (v) {
                          setState(() => _smsAttendance = v);
                          _saveNotificationPref('stud_notif_smsAttendance', v);
                        }),
                        _toggleRow('Announcement notifications', _announcements, (v) {
                          setState(() => _announcements = v);
                          _saveNotificationPref('stud_notif_announcements', v);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Privacy Settings',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _toggleRow('Show profile to other students', _showProfile, (v) {
                          setState(() => _showProfile = v);
                          _saveNotificationPref('stud_privacy_showProfile', v);
                        }),
                        _toggleRow('Allow contact from faculty', _allowContact, (v) {
                          setState(() => _allowContact = v);
                          _saveNotificationPref('stud_privacy_allowContact', v);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _themeOption(String label, ThemeMode mode, ThemeMode currentMode) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: currentMode,
      onChanged: (value) {
        if (value != null) {
          MyClassApp.setThemeMode(value);
        }
      },
      activeColor: AppColors.primary,
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppColorsExtension.of(context).textPrimary))),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary)),
    );
  }
}
