import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/assignment.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorAssignmentsScreen extends StatefulWidget {
  const MentorAssignmentsScreen({super.key});

  @override
  State<MentorAssignmentsScreen> createState() => _MentorAssignmentsScreenState();
}

class _MentorAssignmentsScreenState extends State<MentorAssignmentsScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  bool _showForm = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  final _maxMarksCtrl = TextEditingController();
  String _selectedSubject = 'Data Structures';
  List<Assignment> _assignments = [];

  static const _subjects = ['Data Structures', 'Database Management', 'Web Development', 'Software Engineering', 'Computer Networks'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dueDateCtrl.dispose();
    _maxMarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final assignments = await DataService.instance.getAssignments();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _assignments = assignments;
      _loading = false;
    });
  }

  Future<void> _create() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty || _dueDateCtrl.text.isEmpty || _maxMarksCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating));
      return;
    }
    final a = Assignment(
      id: DateTime.now().millisecondsSinceEpoch,
      subject: _selectedSubject,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: _dueDateCtrl.text.trim(),
      maxMarks: _maxMarksCtrl.text.trim(),
      status: 'Active',
      createdBy: 'Mentor',
      createdAt: DateTime.now().toIso8601String(),
    );
    await DataService.instance.addAssignment(a);
    _titleCtrl.clear();
    _descCtrl.clear();
    _dueDateCtrl.clear();
    _maxMarksCtrl.clear();
    setState(() => _showForm = false);
    _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment created successfully!'), behavior: SnackBarBehavior.floating));
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Assignment?'), content: const Text('Are you sure you want to delete this assignment?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger)))]));
    if (confirm == true) {
      await DataService.instance.deleteAssignment(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Assignment Management',
      userName: _userName,
      currentRoute: AppRoutes.mentorAssignments,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Assignment Management',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create and manage assignments for your students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(onPressed: () => setState(() => _showForm = !_showForm), icon: Icon(_showForm ? Icons.close : Icons.add), label: Text(_showForm ? 'Cancel' : 'Create New Assignment')),
                      ],
                    ),
                  ),
                  if (_showForm) ...[
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Create New Assignment',
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Subject *'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedSubject,
                            items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _selectedSubject = v ?? _selectedSubject),
                          ),
                          const SizedBox(height: 16),
                          _label('Assignment Title *'),
                          TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'e.g., Binary Tree Implementation')),
                          const SizedBox(height: 16),
                          _label('Description *'),
                          TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Assignment details and requirements...')),
                          const SizedBox(height: 16),
                          _label('Due Date *'),
                          TextField(controller: _dueDateCtrl, decoration: const InputDecoration(hintText: 'YYYY-MM-DD')),
                          const SizedBox(height: 16),
                          _label('Max Marks *'),
                          TextField(controller: _maxMarksCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '100')),
                          const SizedBox(height: 24),
                          Row(children: [
                            TextButton(onPressed: () => setState(() => _showForm = false), child: const Text('Cancel')),
                            const SizedBox(width: 12),
                            ElevatedButton(onPressed: _create, child: const Text('Create Assignment')),
                          ]),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'All Assignments',
                    padding: const EdgeInsets.all(24),
                    child: _assignments.isEmpty
                        ? Text('No assignments created yet', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                        : Table(
                            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2.5), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1)},
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                                children: [_H('Subject'), _H('Title'), _H('Due Date'), _H('Marks'), _H('Action')],
                              ),
                              for (final a in _assignments)
                                TableRow(
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                                  children: [
                                    _B(a.subject),
                                    _B(a.title),
                                    _B(a.dueDate),
                                    _B(a.maxMarks),
                                    Padding(padding: const EdgeInsets.all(8), child: TextButton(onPressed: () => _delete(a.id), child: const Text('Delete', style: TextStyle(color: AppColors.danger)))),
                                  ],
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary, fontSize: 14)));
}

class _H extends StatelessWidget {
  final String t;
  const _H(this.t);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(12), child: Text(t.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1)));
}

class _B extends StatelessWidget {
  final String t;
  const _B(this.t);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(12), child: Text(t, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
}