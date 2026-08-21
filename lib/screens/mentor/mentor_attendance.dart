import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/attendance.dart';
import '../../models/mentor_student.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorAttendanceScreen extends StatefulWidget {
  const MentorAttendanceScreen({super.key});

  @override
  State<MentorAttendanceScreen> createState() => _MentorAttendanceScreenState();
}

class _MentorAttendanceScreenState extends State<MentorAttendanceScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  List<MentorStudent> _students = [];
  MentorStudent? _selectedStudent;
  List<AttendanceRecord> _records = [];
  bool _showForm = false;

  final _subjectCtrl = TextEditingController();
  String _status = 'Present';

  static const _subjects = [
    'Data Structures',
    'Database Management',
    'Operating Systems',
    'Computer Networks',
    'Algorithms',
    'Software Engineering',
    'Web Development',
    'Python Programming',
    'Java Programming',
    'Machine Learning',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final students = await DataService.instance.getMentorStudents();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _students = students;
      _loading = false;
    });
  }

  Future<void> _loadRecords() async {
    if (_selectedStudent == null) return;
    final records = await DataService.instance.getAttendance(_selectedStudent!.rollNo);
    setState(() => _records = records);
  }

  Future<void> _markAttendance() async {
    if (_selectedStudent == null || _subjectCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student and subject'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final record = AttendanceRecord(
      subject: _subjectCtrl.text.trim(),
      date: DateTime.now().toIso8601String().split('T')[0],
      status: _status,
      markedBy: _userName,
      timestamp: DateTime.now().toIso8601String(),
    );

    await DataService.instance.addAttendanceRecord(_selectedStudent!.rollNo, record);

    final profile = await DataService.instance.getStudentData(_selectedStudent!.rollNo);
    final allRecords = await DataService.instance.getAttendance(_selectedStudent!.rollNo);
    final summary = AttendanceSummary.fromRecords(allRecords);
    await DataService.instance.saveStudentProfile(
      _selectedStudent!.rollNo,
      profile.copyWith(attendance: summary.percentage.round()),
    );

    _subjectCtrl.clear();
    setState(() {
      _status = 'Present';
      _showForm = false;
    });
    await _loadRecords();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance marked successfully!'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Attendance',
      userName: _userName,
      currentRoute: AppRoutes.mentorAttendance,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Attendance Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                            const SizedBox(height: 4),
                            Text('Mark attendance for your students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                          ],
                        ),
                      ),
                      if (_selectedStudent != null)
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _showForm = !_showForm),
                          icon: Icon(_showForm ? Icons.close : Icons.add),
                          label: Text(_showForm ? 'Cancel' : 'Mark Attendance'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Select Student',
                    padding: const EdgeInsets.all(24),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStudent?.rollNo,
                      hint: const Text('-- Select a student --'),
                      items: _students.map((s) => DropdownMenuItem(value: s.rollNo, child: Text('${s.name} (${s.rollNo})'))).toList(),
                      onChanged: (v) {
                        setState(() => _selectedStudent = v != null ? _students.firstWhere((s) => s.rollNo == v) : null);
                        _loadRecords();
                      },
                    ),
                  ),
                  if (_showForm && _selectedStudent != null) ...[
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Mark Attendance',
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Subject *'),
                          DropdownButtonFormField<String>(
                            initialValue: _subjectCtrl.text.isEmpty ? null : _subjectCtrl.text,
                            items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _subjectCtrl.text = v ?? ''),
                            decoration: const InputDecoration(hintText: '-- Select Subject --'),
                          ),
                          const SizedBox(height: 16),
                          _label('Status *'),
                          DropdownButtonFormField<String>(
                            initialValue: _status,
                            items: const [
                              DropdownMenuItem(value: 'Present', child: Text('Present')),
                              DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                              DropdownMenuItem(value: 'Late', child: Text('Late')),
                              DropdownMenuItem(value: 'Excused', child: Text('Excused')),
                            ],
                            onChanged: (v) => setState(() => _status = v ?? 'Present'),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(onPressed: _markAttendance, child: const Text('Mark Attendance')),
                        ],
                      ),
                    ),
                  ],
                  if (_selectedStudent != null) ...[
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Attendance Records',
                      padding: const EdgeInsets.all(24),
                      child: _records.isEmpty
                          ? Text('No attendance records yet', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                          : Table(
                              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                                  children: [_H('Subject'), _H('Date'), _H('Status'), _H('Marked By')],
                                ),
                                for (final r in _records)
                                  TableRow(
                                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                                    children: [_B(r.subject), _B(r.date), _B(r.status), _B(r.markedBy)],
                                  ),
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
