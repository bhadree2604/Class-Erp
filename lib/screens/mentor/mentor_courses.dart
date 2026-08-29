import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/course.dart';
import '../../models/course_catalog.dart';
import '../../models/mentor_student.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorCoursesScreen extends StatefulWidget {
  const MentorCoursesScreen({super.key});

  @override
  State<MentorCoursesScreen> createState() => _MentorCoursesScreenState();
}

class _MentorCoursesScreenState extends State<MentorCoursesScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  List<MentorStudent> _students = [];
  String? _selectedDepartment;
  String? _selectedSemester;
  final _nameCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  String? _addDept;
  String? _addSem;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
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

  void _showAddStudentDialog() {
    _nameCtrl.clear();
    _rollCtrl.clear();
    _addDept = null;
    _addSem = null;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Student Name', hintText: 'Enter student name')),
                const SizedBox(height: 12),
                TextField(controller: _rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number', hintText: 'Enter roll number')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _addDept,
                  hint: const Text('Select Department'),
                  items: const [
                    DropdownMenuItem(value: 'CSE', child: Text('CSE')),
                    DropdownMenuItem(value: 'IT', child: Text('IT')),
                    DropdownMenuItem(value: 'CSE-AIML', child: Text('CSE - AI & ML')),
                    DropdownMenuItem(value: 'AI&DS', child: Text('AI & Data Science')),
                    DropdownMenuItem(value: 'ECE', child: Text('ECE')),
                    DropdownMenuItem(value: 'EEE', child: Text('EEE')),
                    DropdownMenuItem(value: 'MECH', child: Text('Mechanical')),
                    DropdownMenuItem(value: 'CIVIL', child: Text('Civil')),
                  ],
                  onChanged: (v) => setDlgState(() => _addDept = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _addSem,
                  hint: const Text('Select Semester'),
                  items: List.generate(8, (i) => DropdownMenuItem(value: '${i + 1}', child: Text('Semester ${i + 1}'))),
                  onChanged: (v) => setDlgState(() => _addSem = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_nameCtrl.text.isEmpty || _rollCtrl.text.isEmpty || _addDept == null || _addSem == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                  return;
                }
                final error = await DataService.instance.addMentorStudent(
                  name: _nameCtrl.text.trim(),
                  rollNo: _rollCtrl.text.trim(),
                  department: _addDept!,
                  semester: int.parse(_addSem!),
                );
                if (error != null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
                  return;
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }

  List<Course> _getSemesterCourses(String dept, String sem) {
    final deptCourses = _departmentCourses[dept] ?? [];
    final semInt = int.tryParse(sem) ?? 0;
    final all = <Course>[];
    for (final code in deptCourses) {
      final c = getCourseByCode(code);
      if (c != null && c.semester == semInt) all.add(c);
    }
    return all;
  }

  Future<List<Course>> _getAssigned() async {
    final codes = <String>{};
    for (final s in _students) {
      final studentCodes = await DataService.instance.getStudentCourseCodes(s.rollNo);
      codes.addAll(studentCodes);
    }
    return codes.map((c) => getCourseByCode(c)).whereType<Course>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Course Management',
      userName: _userName,
      currentRoute: AppRoutes.mentorCourses,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Course Management',
                    padding: const EdgeInsets.all(24),
                    child: Text('Select and manage courses for your mentorship group', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Manage Students',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(onPressed: _showAddStudentDialog, icon: const Icon(Icons.add), label: const Text('Add Student')),
                        const SizedBox(height: 16),
                        if (_students.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No students added yet. Click "Add Student" to add students to your group.', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                          )
                        else
                          Table(
                            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1)},
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                                children: [
                                  _H('Roll No'), _H('Student Name'), _H('Department'), _H('Semester'), _H('Action'),
                                ],
                              ),
                              for (final s in _students)
                                TableRow(
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                                children: [
                                    _B(s.rollNo),
                                    _B(s.name),
                                    _B(s.department),
                                    _B('Sem ${s.semester}'),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: TextButton(
                                        onPressed: () async {
                                          await DataService.instance.removeMentorStudent(s.id);
                                          _load();
                                        },
                                        child: const Text('Remove', style: TextStyle(color: AppColors.danger)),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Assign Semester Courses',
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDepartment,
                          hint: const Text('-- Select Department --'),
                          items: const [
                            DropdownMenuItem(value: 'CSE', child: Text('Computer Science and Engineering (CSE)')),
                            DropdownMenuItem(value: 'IT', child: Text('Information Technology (IT)')),
                            DropdownMenuItem(value: 'CSE-AIML', child: Text('CSE - AI & ML')),
                            DropdownMenuItem(value: 'AI&DS', child: Text('AI & Data Science')),
                            DropdownMenuItem(value: 'ECE', child: Text('Electronics and Communication')),
                            DropdownMenuItem(value: 'EEE', child: Text('Electrical and Electronics')),
                            DropdownMenuItem(value: 'MECH', child: Text('Mechanical Engineering')),
                            DropdownMenuItem(value: 'CIVIL', child: Text('Civil Engineering')),
                          ],
                          onChanged: (v) => setState(() { _selectedDepartment = v; _selectedSemester = null; }),
                        ),
                        if (_selectedDepartment != null) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedSemester,
                            hint: const Text('-- Select Semester --'),
                            items: List.generate(8, (i) => DropdownMenuItem(value: '${i + 1}', child: Text('Semester ${i + 1}'))),
                            onChanged: (v) => setState(() => _selectedSemester = v),
                          ),
                        ],
                        if (_selectedDepartment != null && _selectedSemester != null) ...[
                          const SizedBox(height: 16),
                          Text('${_getSemesterCourses(_selectedDepartment!, _selectedSemester!).length} courses found', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final semCourses = _getSemesterCourses(_selectedDepartment!, _selectedSemester!);
                              for (final s in _students) {
                                if (s.department == _selectedDepartment && s.semester.toString() == _selectedSemester) {
                                  final existing = await DataService.instance.getStudentCourseCodes(s.rollNo);
                                  final merged = {...existing, ...semCourses.map((c) => c.code)}.toList();
                                  await DataService.instance.saveStudentCourseCodes(s.rollNo, merged);
                                }
                              }
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Courses assigned successfully!')));
                              setState(() {});
                            },
                            child: const Text('Assign All Courses to Students'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Currently Assigned Courses',
                    padding: const EdgeInsets.all(24),
                    child: FutureBuilder<List<Course>>(
                      future: _getAssigned(),
                      builder: (context, snapshot) {
                        final assigned = snapshot.data ?? [];
                        if (assigned.isEmpty) {
                          return Text('No courses assigned yet. Select department and semester from above.', style: TextStyle(color: AppColorsExtension.of(context).textSecondary));
                        }
                        return Table(
                          columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(2.5), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1.5), 4: FlexColumnWidth(1)},
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                              children: [_H('Code'), _H('Course Name'), _H('Credits'), _H('Enrolled'), _H('Action')],
                            ),
                            for (final c in assigned)
                              TableRow(
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                                children: [
                                  _B(c.code),
                                  _B(c.name),
                                  _B('${c.credits}'),
                                  _B('${_students.length}'),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: TextButton(
                                      onPressed: () async {
                                        for (final s in _students) {
                                          final existing = await DataService.instance.getStudentCourseCodes(s.rollNo);
                                          existing.remove(c.code);
                                          await DataService.instance.saveStudentCourseCodes(s.rollNo, existing);
                                        }
                                        setState(() {});
                                      },
                                      child: const Text('Remove', style: TextStyle(color: AppColors.danger)),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

const _departmentCourses = {
  'CSE': ['MA25C01', 'EN25C01', 'UC25H01', 'PH25C01', 'CY25C01', 'CS25C01', 'CS25C03', 'ME25C04', 'UC25A01', 'UC25A02',
    'MA25C02', 'EE25C01', 'CS25C06', 'UC25H02', 'PH25C03', 'CS25C07', 'EN25C02', 'ME25C05', 'UC25A03', 'UC25A04', 'UC25F01',
    'MA25C03', 'CS25C08', 'CS25C09', 'CS25C10', 'CS25C11', 'EN25C03', 'CS25C12',
    'MA25C04', 'CS25C13', 'CS25C14', 'CS25C15', 'CS25C16', 'CS25C17', 'CS25C18', 'EN25C04',
    'CS25C19', 'CS25C20', 'CS25PE1', 'CS25C21', 'CS25C22', 'CS25C23', 'CS25C24', 'CS25C25',
    'CS25C26', 'CS25PE2', 'CS25PE3', 'CS25OE1', 'CS25C27', 'CS25C28', 'CS25C29', 'CS25C30',
    'UC25C01', 'CS25PE4', 'CS25PE5', 'UC25C02', 'CS25C31', 'CS25C32',
    'CS25C33'],
  'IT': ['MA25C01', 'EN25C01', 'UC25H01', 'PH25C01', 'CY25C01', 'CS25C01', 'CS25C03', 'ME25C04', 'UC25A01', 'UC25A02',
    'MA25C02', 'UC25H02', 'EE25C01', 'PH25C03', 'IT25201', 'IT25202', 'EN25C02', 'ME25C05', 'UC25A03', 'UC25A04', 'UC25F01',
    'IT25301', 'IT25302', 'IT25303', 'IT25304', 'IT25305', 'IT25306', 'EN25C03',
    'IT25401', 'IT25402', 'IT25403', 'IT25404', 'IT25405', 'IT25406', 'EN25C04',
    'IT25PE1', 'IT25PE2', 'IT25501', 'IT25502', 'IT25503', 'IT25504', 'IT25505', 'IT25506',
    'IT25601', 'IT25PE3', 'IT25OE1', 'IT25602', 'IT25603', 'IT25604', 'IT25605', 'IT25606', 'IT25607',
    'UC25C02', 'UC25C01', 'IT25PE4', 'IT25PE5', 'IT25701', 'IT25702',
    'IT25801'],
};

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
