import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_routes.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorSettingsScreen extends StatefulWidget {
  const MentorSettingsScreen({super.key});

  @override
  State<MentorSettingsScreen> createState() => _MentorSettingsScreenState();
}

class _MentorSettingsScreenState extends State<MentorSettingsScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _emailAlerts = true;
  bool _emailMeetings = true;
  bool _smsUrgent = false;
  bool _weeklyReports = true;
  bool _showProfile = true;
  bool _allowScheduling = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _currentPwdCtrl.dispose(); _newPwdCtrl.dispose(); _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _emailAlerts = prefs.getBool('mentor_notif_emailAlerts') ?? true;
      _emailMeetings = prefs.getBool('mentor_notif_emailMeetings') ?? true;
      _smsUrgent = prefs.getBool('mentor_notif_smsUrgent') ?? false;
      _weeklyReports = prefs.getBool('mentor_notif_weeklyReports') ?? true;
      _showProfile = prefs.getBool('mentor_privacy_showProfile') ?? true;
      _allowScheduling = prefs.getBool('mentor_privacy_allowScheduling') ?? true;
      _loading = false;
    });
  }

  Future<void> _changePassword() async {
    if (_currentPwdCtrl.text.isEmpty || _newPwdCtrl.text.isEmpty || _confirmPwdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields'), behavior: SnackBarBehavior.floating));
      return;
    }
    if (_newPwdCtrl.text != _confirmPwdCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match!'), behavior: SnackBarBehavior.floating));
      return;
    }
    if (_newPwdCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New password must be at least 6 characters!'), behavior: SnackBarBehavior.floating));
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
    _currentPwdCtrl.clear(); _newPwdCtrl.clear(); _confirmPwdCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully! Please login again.'), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _exportData() async {
    try {
      final jsonString = await DataService.instance.exportAllData();
      await SharePlus.instance.share(ShareParams(text: jsonString, subject: 'RIT ERP Data Backup'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported successfully!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _importData() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste the JSON data from a previous export. This will OVERWRITE all current data.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Paste exported JSON here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Import (Overwrite)'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.isNotEmpty) {
      try {
        final count = await DataService.instance.importAllData(controller.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported $count data keys successfully!'), behavior: SnackBarBehavior.floating),
          );
          _load();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final currentMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    return PortalScaffold(
      role: 'mentor',
      title: 'Settings',
      userName: _userName,
      currentRoute: AppRoutes.mentorSettings,
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
                    child: Text('Manage your account settings and preferences', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Backup & Restore',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _actionRow(
                          'Export All Data',
                          'Save a complete backup of all app data (profiles, certificates, grades, attendance, etc.)',
                          Icons.download,
                          _exportData,
                        ),
                        const SizedBox(height: 12),
                        _actionRow(
                          'Import Data',
                          'Restore from a previously exported backup file (OVERWRITES current data)',
                          Icons.upload,
                          _importData,
                          isDestructive: true,
                        ),
                      ],
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
                    heading: 'Account Information',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _infoRow('Mentor ID', 'M2024001'),
                        _infoRow('Name', 'Dr. Maha'),
                        _infoRow('Email', 'Maha@rit.edu'),
                        _infoRow('Phone', '+91 98765 43210'),
                        _infoRow('Department', 'Computer Science'),
                        _infoRow('Office', 'Room 305, CS Block'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Change Password',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Current Password'),
                        TextField(controller: _currentPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Current Password')),
                        const SizedBox(height: 12),
                        _label('New Password'),
                        TextField(controller: _newPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'New Password')),
                        const SizedBox(height: 12),
                        _label('Confirm New Password'),
                        TextField(controller: _confirmPwdCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Confirm New Password')),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: _changePassword, child: const Text('Update Password')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Notification Preferences',
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      _toggleRow('Email notifications for student alerts', _emailAlerts, (v) {
                        setState(() => _emailAlerts = v);
                        _savePref('mentor_notif_emailAlerts', v);
                      }),
                      _toggleRow('Email notifications for meeting reminders', _emailMeetings, (v) {
                        setState(() => _emailMeetings = v);
                        _savePref('mentor_notif_emailMeetings', v);
                      }),
                      _toggleRow('SMS notifications for urgent matters', _smsUrgent, (v) {
                        setState(() => _smsUrgent = v);
                        _savePref('mentor_notif_smsUrgent', v);
                      }),
                      _toggleRow('Weekly performance summary reports', _weeklyReports, (v) {
                        setState(() => _weeklyReports = v);
                        _savePref('mentor_notif_weeklyReports', v);
                      }),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Privacy Settings',
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      _toggleRow('Show my profile to students', _showProfile, (v) {
                        setState(() => _showProfile = v);
                        _savePref('mentor_privacy_showProfile', v);
                      }),
                      _toggleRow('Allow students to schedule meetings', _allowScheduling, (v) {
                        setState(() => _allowScheduling = v);
                        _savePref('mentor_privacy_allowScheduling', v);
                      }),
                    ]),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        SizedBox(width: 160, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary))),
        Expanded(child: Text(value, style: TextStyle(color: AppColorsExtension.of(context).textSecondary))),
      ]),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label, style: TextStyle(color: AppColorsExtension.of(context).textPrimary))),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
      ]),
    );
  }

  Widget _actionRow(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isDestructive ? Colors.red.withValues(alpha: 0.3) : AppColorsExtension.of(context).bgTertiary),
          borderRadius: BorderRadius.circular(12),
          color: isDestructive ? Colors.red.withValues(alpha: 0.05) : AppColorsExtension.of(context).bgSecondary,
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red : AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDestructive ? Colors.red : AppColorsExtension.of(context).textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColorsExtension.of(context).textLight),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary)));
}
