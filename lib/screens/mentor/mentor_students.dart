import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/course.dart';
import '../../models/course_catalog.dart';
import '../../models/mentor_student.dart';
import '../../models/semester_report.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Mentor students — mirror of `mentor/students.html`.
class MentorStudentsScreen extends StatefulWidget {
  const MentorStudentsScreen({super.key});

  @override
  State<MentorStudentsScreen> createState() => _MentorStudentsScreenState();
}

class _MentorStudentsScreenState extends State<MentorStudentsScreen> {
  String _userName = 'Mentor';
  List<MentorStudent> _students = const [];
  bool _loading = true;

  static const _departments = [
    ('CSE', 'Computer Science and Engineering'),
    ('IT', 'Information Technology'),
    ('CSE-AIML', 'CSE - AI & ML'),
    ('AI&DS', 'B.Tech - AI & Data Science'),
    ('ECE', 'Electronics and Communication'),
    ('EEE', 'Electrical and Electronics'),
    ('MECH', 'Mechanical Engineering'),
    ('CIVIL', 'Civil Engineering'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _showAddStudent() async {
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    String department = '';
    int semester = 0;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add New Student',
                style: TextStyle(color: AppColors.textPrimary)),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Student Name'),
                    TextField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(hintText: 'Enter student name'),
                    ),
                    const SizedBox(height: 12),
                    _label('Roll Number'),
                    TextField(
                      controller: rollCtrl,
                      decoration:
                          const InputDecoration(hintText: 'Enter roll number'),
                    ),
                    const SizedBox(height: 12),
                    _label('Department'),
                    DropdownButtonFormField<String>(
                      initialValue: department.isEmpty ? null : department,
                      items: [
                        for (final d in _departments)
                          DropdownMenuItem(value: d.$1, child: Text(d.$2)),
                      ],
                      onChanged: (v) => setState(() => department = v ?? ''),
                      decoration: const InputDecoration(
                          hintText: '-- Select Department --'),
                    ),
                    const SizedBox(height: 12),
                    _label('Current Semester'),
                    DropdownButtonFormField<int>(
                      initialValue: semester == 0 ? null : semester,
                      items: [
                        for (var s = 1; s <= 8; s++)
                          DropdownMenuItem(value: s, child: Text('Semester $s')),
                      ],
                      onChanged: (v) => setState(() => semester = v ?? 0),
                      decoration: const InputDecoration(
                          hintText: '-- Select Semester --'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('add'),
                child: const Text('Add Student'),
              ),
            ],
          ),
        );
      },
    );

    if (result == 'add') {
      final error = await DataService.instance.addMentorStudent(
        name: nameCtrl.text.trim(),
        rollNo: rollCtrl.text.trim(),
        department: department,
        semester: semester,
      );
      if (!mounted) return;
      if (error != null) {
        _showMessage(error);
      } else {
        _showMessage('Student "${nameCtrl.text.trim()}" added successfully!');
        await _load();
      }
    }
  }

  Future<void> _viewDetails(MentorStudent student) async {
    final codes = await DataService.instance.getStudentCourseCodes(student.id);
    final reports =
        await DataService.instance.getAcademicReport(student);
    if (!mounted) return;

    final courses = codes
        .map(getCourseByCode)
        .whereType<Course>()
        .toList();
    final core = courses.where((c) => c.type != 'Elective').toList();
    final electives = courses.where((c) => c.type == 'Elective').toList();
    final theory = courses.where((c) => c.type == 'Theory').length;
    final lab = courses.where((c) => c.type == 'LIT').length;

    final completed =
        reports.where((r) => r.isCompleted && r.gpa != '-').toList();
    final cgpa = completed.isEmpty
        ? '-'
        : (completed.fold<double>(0, (s, r) => s + double.parse(r.gpa)) /
                completed.length)
            .toStringAsFixed(2);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        student.name.isEmpty
                            ? '?'
                            : student.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Roll No: ${student.rollNo}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _detailsHeader('Academic Information', Icons.school),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _infoTile(
                              student.department,
                              'Department',
                              const Color(0xFFe3f2fd),
                              const Color(0xFF0d47a1)),
                          _infoTile(
                              'Semester ${student.semester}',
                              'Current Semester',
                              const Color(0xFFf3e5f5),
                              const Color(0xFF4a148c)),
                          _infoTile(
                              '${courses.length} Courses',
                              'Total Courses',
                              const Color(0xFFe8f5e9),
                              const Color(0xFF1b5e20)),
                          _infoTile(
                              cgpa,
                              'CGPA',
                              const Color(0xFFfff9c4),
                              const Color(0xFFf57f17)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _detailsHeader('Academic Report', Icons.bar_chart),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.bgTertiary, width: 2),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < reports.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _semesterRow(reports[i]),
                            ],
                          ],
                        ),
                      ),
                      if (courses.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _detailsHeader('Course Distribution', Icons.pie_chart),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _countTile(
                                  '${core.length}', 'Core Courses',
                                  AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _countTile('${electives.length}',
                                  'Electives', const Color(0xFFe67e22)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _countTile('$theory', 'Theory',
                                  AppColors.info),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _countTile('$lab', 'Lab/LIT',
                                  AppColors.success),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _detailsHeader('Assigned Courses', Icons.menu_book),
                        const SizedBox(height: 12),
                        for (final c in courses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _assignedCourseRow(c),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailsHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String value, String label, Color bg, Color fg) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bg, bg.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: fg.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _semesterRow(SemesterReport r) {
    final completed = r.isCompleted;
    final bg = completed ? AppColors.bgSecondary : const Color(0xFFFFF3E0);
    final border = completed ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: border, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Semester ${r.semester}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFd4edda)
                      : const Color(0xFFfff3cd),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  r.status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: completed
                        ? const Color(0xFF155724)
                        : const Color(0xFF856404),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'GPA / Percentage',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
              Text(
                r.percentage != '-' ? '${r.gpa} / ${r.percentage}%' : r.gpa,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countTile(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bgTertiary),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _assignedCourseRow(Course c) {
    final isElective = c.type == 'Elective';
    final color = isElective ? const Color(0xFFe67e22) : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isElective ? const Color(0xFFFFF3E0) : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.code,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(c.name,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${c.credits} Credits',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeStudent(MentorStudent student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
            'Are you sure you want to remove "${student.name}" from your mentorship group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DataService.instance.removeMentorStudent(student.id);
      if (!mounted) return;
      _showMessage('Student removed successfully!');
      await _load();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'My Students',
      userName: _userName,
      currentRoute: AppRoutes.mentorStudents,
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
                          children: const [
                            Text(
                              'My Students',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Students assigned to you this semester',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddStudent,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Student'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Student List',
                    child: _students.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No students added yet. Click "Add Student" to add students to your group.',
                                style: TextStyle(color: AppColors.textLight),
                              ),
                            ),
                          )
                        : Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.8),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1.2),
                              3: FlexColumnWidth(0.8),
                              4: FlexColumnWidth(1.2),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                ),
                                children: [
                                  _HeaderCell('Roll No'),
                                  _HeaderCell('Name'),
                                  _HeaderCell('Department'),
                                  _HeaderCell('Semester'),
                                  _HeaderCell('Action'),
                                ],
                              ),
                              for (final s in _students)
                                TableRow(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.bgTertiary),
                                    ),
                                  ),
                                  children: [
                                    _BodyCell(s.rollNo, strong: true),
                                    _nameCell(s),
                                    _pillCell(s.department,
                                        const Color(0xFFe3f2fd),
                                        const Color(0xFF1976d2)),
                                    _pillCell('Semester ${s.semester}',
                                        const Color(0xFFf3e5f5),
                                        const Color(0xFF7b1fa2)),
                                    _actionCell(s),
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

  Widget _nameCell(MentorStudent s) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              s.name.isEmpty ? '?' : s.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              FutureBuilder(
                future:
                    DataService.instance.getStudentCourseCodes(s.id),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Text(
                    '$count courses assigned',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillCell(String text, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCell(MentorStudent s) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: [
          ElevatedButton(
            onPressed: () => _viewDetails(s),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text('View Details',
                style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () => _removeStudent(s),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text('Remove', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final bool strong;
  const _BodyCell(this.text, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}