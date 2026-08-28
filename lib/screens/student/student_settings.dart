import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../services/preference_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  String _userName = 'Student';
  String _userEmail = '';
  bool _loading = true;
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  NotificationPreferences _notifPrefs = NotificationPreferences(
    emailEnabled: true,
    pushEnabled: false,
    newsletter: false,
  );

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
    final prefs = await PreferenceService.instance.getPreferences();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _userEmail = user?.email ?? '';
      _notifPrefs = prefs;
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

  Future<void> _updateNotifPrefs(NotificationPreferences updated) async {
    await PreferenceService.instance.savePreferences(updated);
    if (mounted) setState(() => _notifPrefs = updated);
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
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text('Manage your account and preferences', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                  const SizedBox(height: 24),

                  AppCard(
                    heading: 'Account',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSettingRow(Icons.person, 'Profile', () => Navigator.of(context).pushNamed(AppRoutes.studentProfile)),
                        const Divider(),
                        _buildSettingRow(Icons.lock, 'Change Password', _changePassword),
                        const Divider(),
                        _buildSettingRow(Icons.email, 'Email: $_userEmail', null),
                      ],
                    ),
                  ),

                  AppCard(
                    heading: 'Notifications',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Email notifications for grades'),
                          value: _notifPrefs.emailEnabled,
                          onChanged: (v) => _updateNotifPrefs(_notifPrefs.copyWith(emailEnabled: v)),
                          activeThumbColor: AppColors.primary,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Push notifications'),
                          value: _notifPrefs.pushEnabled,
                          onChanged: (v) => _updateNotifPrefs(_notifPrefs.copyWith(pushEnabled: v)),
                          activeThumbColor: AppColors.primary,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Newsletter'),
                          value: _notifPrefs.newsletter,
                          onChanged: (v) => _updateNotifPrefs(_notifPrefs.copyWith(newsletter: v)),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  AppCard(
                    heading: 'Data Management',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSettingRow(Icons.download, 'Export Data', _exportData),
                        const Divider(),
                        _buildSettingRow(Icons.upload, 'Import Data', _importData),
                      ],
                    ),
                  ),

                  AppCard(
                    heading: 'About & Support',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSettingRow(Icons.info, 'About', () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('About'),
                                content: const Text('RIT ERP App\nVersion 1.0.0+1'),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                              ),
                            )),
                        const Divider(),
                        _buildSettingRow(Icons.help, 'Help & Support', () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Help & Support'),
                                content: const Text('Contact support@rit.edu'),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                              ),
                            )),
                        const Divider(),
                        _buildSettingRow(Icons.description, 'Version 1.0.0+1', null),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService.instance.logout();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingRow(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColorsExtension.of(context).textPrimary),
      title: Text(title, style: TextStyle(color: AppColorsExtension.of(context).textPrimary)),
      trailing: onTap != null ? Icon(Icons.chevron_right, color: AppColorsExtension.of(context).textLight) : null,
      onTap: onTap ?? () {},
    );
  }
}
