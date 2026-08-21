import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/grade.dart';
import '../../models/mentor_student.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorGradesScreen extends StatefulWidget {
  const MentorGradesScreen({super.key});

  @override
  State<MentorGradesScreen> createState() => _MentorGradesScreenState();
}

class _MentorGradesScreenState extends State<MentorGradesScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  List<MentorStudent> _students = [];
  MentorStudent? _selectedStudent;
  List<Grade> _grades = [];
  bool _showForm = false;

  final _subjectCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();
  final _gradePointCtrl = TextEditingController();
  int? _editIndex;

  static const _gradeOptions = ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F'];

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
    _creditsCtrl.dispose();
    _gradeCtrl.dispose();
    _gradePointCtrl.dispose();
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

  Future<void> _loadGrades() async {
    if (_selectedStudent == null) return;
    final grades = await DataService.instance.getGrades(_selectedStudent!.rollNo);
    setState(() => _grades = grades);
  }

  void _clearForm() {
    _subjectCtrl.clear();
    _creditsCtrl.clear();
    _gradeCtrl.clear();
    _gradePointCtrl.clear();
    _editIndex = null;
  }

  Future<void> _saveGrade() async {
    if (_selectedStudent == null ||
        _subjectCtrl.text.isEmpty ||
        _creditsCtrl.text.isEmpty ||
        _gradeCtrl.text.isEmpty ||
        _gradePointCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final grade = Grade(
      subject: _subjectCtrl.text.trim(),
      credits: int.tryParse(_creditsCtrl.text.trim()) ?? 0,
      grade: _gradeCtrl.text.trim(),
      gradePoint: double.tryParse(_gradePointCtrl.text.trim()) ?? 0,
    );

    final updated = List<Grade>.from(_grades);
    if (_editIndex != null && _editIndex! < updated.length) {
      updated[_editIndex!] = grade;
    } else {
      updated.add(grade);
    }

    await DataService.instance.saveGrades(_selectedStudent!.rollNo, updated);
    _clearForm();
    setState(() => _showForm = false);
    await _loadGrades();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grade saved successfully!'), behavior: SnackBarBehavior.floating),
    );
  }

  void _editGrade(int index) {
    final g = _grades[index];
    _subjectCtrl.text = g.subject;
    _creditsCtrl.text = g.credits.toString();
    _gradeCtrl.text = g.grade;
    _gradePointCtrl.text = g.gradePoint.toString();
    setState(() {
      _editIndex = index;
      _showForm = true;
    });
  }

  Future<void> _deleteGrade(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: const Text('Are you sure you want to delete this grade?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && _selectedStudent != null) {
      final updated = List<Grade>.from(_grades)..removeAt(index);
      await DataService.instance.saveGrades(_selectedStudent!.rollNo, updated);
      await _loadGrades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Grade Management',
      userName: _userName,
      currentRoute: AppRoutes.mentorGrades,
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
                            Text('Grade Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                            const SizedBox(height: 4),
                            Text('Enter and manage grades for your students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                          ],
                        ),
                      ),
                      if (_selectedStudent != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            _clearForm();
                            setState(() => _showForm = !_showForm);
                          },
                          icon: Icon(_showForm ? Icons.close : Icons.add),
                          label: Text(_showForm ? 'Cancel' : 'Add Grade'),
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
                        _loadGrades();
                      },
                    ),
                  ),
                  if (_showForm && _selectedStudent != null) ...[
                    const SizedBox(height: 24),
                    _gradeFormCard(),
                  ],
                  if (_selectedStudent != null) ...[
                    const SizedBox(height: 24),
                    _gradesCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _gradeFormCard() {
    return AppCard(
      heading: _editIndex != null ? 'Edit Grade' : 'Add Grade',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Subject *'),
          TextField(controller: _subjectCtrl, decoration: const InputDecoration(hintText: 'e.g., Data Structures')),
          const SizedBox(height: 16),
          _label('Credits *'),
          TextField(controller: _creditsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g., 4')),
          const SizedBox(height: 16),
          _label('Grade *'),
          DropdownButtonFormField<String>(
            initialValue: _gradeCtrl.text.isEmpty ? null : _gradeCtrl.text,
            items: _gradeOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _gradeCtrl.text = v ?? ''),
            decoration: const InputDecoration(hintText: '-- Select Grade --'),
          ),
          const SizedBox(height: 16),
          _label('Grade Point *'),
          TextField(controller: _gradePointCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: 'e.g., 9.0')),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () { _clearForm(); setState(() => _showForm = false); }, child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _saveGrade, child: Text(_editIndex != null ? 'Update Grade' : 'Add Grade')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradesCard() {
    double totalPoints = 0;
    int totalCredits = 0;
    for (final g in _grades) {
      totalPoints += g.gradePoint * g.credits;
      totalCredits += g.credits;
    }
    final gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;

    return AppCard(
      heading: 'Grades (${_grades.length} subjects) - GPA: ${gpa.toStringAsFixed(2)}',
      padding: const EdgeInsets.all(24),
      child: _grades.isEmpty
          ? Text('No grades entered yet. Click "Add Grade" to begin.', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
          : Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1.5)},
              children: [
                const TableRow(
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                  children: [_H('Subject'), _H('Credits'), _H('Grade'), _H('Points'), _H('Action')],
                ),
                for (var i = 0; i < _grades.length; i++)
                  TableRow(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                    children: [
                      _B(_grades[i].subject),
                      _B('${_grades[i].credits}'),
                      _B(_grades[i].grade),
                      _B('${_grades[i].gradePoint}'),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 4,
                          children: [
                            TextButton(onPressed: () => _editGrade(i), child: const Text('Edit', style: TextStyle(color: AppColors.info))),
                            TextButton(onPressed: () => _deleteGrade(i), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
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
