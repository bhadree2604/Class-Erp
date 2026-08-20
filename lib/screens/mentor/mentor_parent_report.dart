import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/parent_message.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorParentReportScreen extends StatefulWidget {
  const MentorParentReportScreen({super.key});

  @override
  State<MentorParentReportScreen> createState() => _MentorParentReportScreenState();
}

class _MentorParentReportScreenState extends State<MentorParentReportScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  String? _selectedStudent;
  bool _showForm = false;
  final _messageCtrl = TextEditingController();
  String _selectedCategory = 'Academic Performance';
  List<ParentMessage> _messages = [];

  static const _categories = ['Academic Performance', 'Attendance', 'Behavior & Conduct', 'Co-curricular Activities', 'General Remarks'];
  static const _students = [
    ('RIT2024CS001', 'Bhadree'),
    ('RIT2024CS008', 'Amit Patel'),
    ('RIT2024CS015', 'Rahul Kumar'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _loading = false;
    });
  }

  Future<void> _loadMessages() async {
    if (_selectedStudent == null) return;
    final msgs = await DataService.instance.getParentReportMessages(_selectedStudent!);
    setState(() => _messages = msgs);
  }

  Future<void> _addMessage() async {
    if (_selectedStudent == null || _messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating));
      return;
    }
    final msg = ParentMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      category: _selectedCategory,
      message: _messageCtrl.text.trim(),
      addedBy: 'Mentor',
      date: DateTime.now().toIso8601String(),
    );
    await DataService.instance.addParentReportMessage(_selectedStudent!, msg);
    _messageCtrl.clear();
    _loadMessages();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message added successfully!'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Parent Report Management',
      userName: _userName,
      currentRoute: AppRoutes.mentorParentReport,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Parent Report Management',
                    padding: const EdgeInsets.all(24),
                    child: Text('Add messages and updates for parent reports', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Select Student',
                    padding: const EdgeInsets.all(24),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStudent,
                      hint: const Text('-- Select a student --'),
                      items: _students.map((s) => DropdownMenuItem(value: s.$1, child: Text('${s.$2} (${s.$1})'))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedStudent = v;
                          _showForm = v != null;
                        });
                        _loadMessages();
                      },
                    ),
                  ),
                  if (_showForm && _selectedStudent != null) ...[
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Add Parent Report Message',
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Category *'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                          ),
                          const SizedBox(height: 16),
                          _label('Message *'),
                          TextField(controller: _messageCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Enter message for parents...')),
                          const SizedBox(height: 24),
                          ElevatedButton(onPressed: _addMessage, child: const Text('Add Message')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Parent Report Messages',
                      padding: const EdgeInsets.all(24),
                      child: _messages.isEmpty
                          ? Text('No messages added yet', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                          : Column(
                              children: [
                                for (final m in _messages) ...[
                                  AppCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.category, style: TextStyle(fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                                        const SizedBox(height: 4),
                                        Text(m.message, style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                                        const SizedBox(height: 4),
                                        Text('Added on: ${m.date}', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary, fontSize: 14)));
}