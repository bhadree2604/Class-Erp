import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/certificate.dart';
import '../../models/mentor_student.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorCertificatesScreen extends StatefulWidget {
  const MentorCertificatesScreen({super.key});

  @override
  State<MentorCertificatesScreen> createState() => _MentorCertificatesScreenState();
}

class _MentorCertificatesScreenState extends State<MentorCertificatesScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  String? _selectedStudent;
  List<MentorStudent> _students = [];
  List<Certificate> _allCertificates = [];
  List<String> _certStudentNames = [];

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

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final students = await DataService.instance.getMentorStudents();
    final allCerts = <Certificate>[];
    final studentNames = <String>[];
    for (final s in students) {
      final certs = await DataService.instance.getCertificates(s.rollNo);
      for (final c in certs) {
        allCerts.add(c);
        studentNames.add('${s.name} (${s.rollNo})');
      }
    }
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _students = students;
      _allCertificates = allCerts;
      _certStudentNames = studentNames;
      _loading = false;
    });
  }

  List<Certificate> get _filteredCertificates {
    if (_selectedStudent == null) return _allCertificates;
    final result = <Certificate>[];
    for (var i = 0; i < _allCertificates.length; i++) {
      if (_certStudentNames[i] == _selectedStudent) {
        result.add(_allCertificates[i]);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final certs = _filteredCertificates;

    return PortalScaffold(
      role: 'mentor',
      title: 'Certificates',
      userName: _userName,
      currentRoute: AppRoutes.mentorCertificates,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Certificate Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                      const SizedBox(height: 4),
                      Text('View certificates for your assigned students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Filter by Student',
                    padding: const EdgeInsets.all(24),
                    child: _students.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No students added yet', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                              const SizedBox(height: 8),
                              Text(
                                'Add students in "My Students" to view their certificates here.',
                                style: TextStyle(color: AppColorsExtension.of(context).textLight, fontSize: 13),
                              ),
                            ],
                          )
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedStudent,
                            hint: const Text('-- All Students --'),
                            items: _students.map((s) => DropdownMenuItem(value: '${s.name} (${s.rollNo})', child: Text('${s.name} (${s.rollNo})'))).toList(),
                            onChanged: (v) => setState(() => _selectedStudent = v),
                          ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Certificates',
                    padding: const EdgeInsets.all(24),
                    child: certs.isEmpty
                        ? Text('No certificates found', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                        : Table(
                            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(2.5), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1.5)},
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                                children: [_H('Student'), _H('Title'), _H('Category'), _H('Date')],
                              ),
                              for (var i = 0; i < certs.length; i++)
                                TableRow(
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                                  children: [_B(_certStudentNames[i]), _B(certs[i].title), _B(certs[i].category), _B(certs[i].date)],
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }
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
