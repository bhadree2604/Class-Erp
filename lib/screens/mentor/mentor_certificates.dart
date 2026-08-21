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
  bool _showForm = false;

  final _titleCtrl = TextEditingController();
  final _issuedByCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String _category = '';
  DateTime? _issueDate;

  static const _categories = [
    'Academic Excellence',
    'Sports Achievement',
    'Cultural Event',
    'Technical Competition',
    'Workshop/Training',
    'Internship',
    'Other',
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
    _titleCtrl.dispose();
    _issuedByCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _issueCertificate() async {
    if (_selectedStudent == null ||
        _titleCtrl.text.isEmpty ||
        _category.isEmpty ||
        _issuedByCtrl.text.isEmpty ||
        _issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final student = _students.firstWhere((s) => '${s.name} (${s.rollNo})' == _selectedStudent);
    final dateStr = _issueDate!.toIso8601String().split('T')[0];
    final cert = Certificate(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      category: _category,
      issuedBy: _issuedByCtrl.text.trim(),
      date: dateStr,
      dateIssued: dateStr,
      description: _descriptionCtrl.text.trim().isEmpty ? 'No description provided' : _descriptionCtrl.text.trim(),
      fileData: null,
      fileName: null,
      uploadedBy: 'Mentor',
      uploadedAt: DateTime.now().toIso8601String(),
    );

    await DataService.instance.addCertificate(student.rollNo, cert);
    _titleCtrl.clear();
    _issuedByCtrl.clear();
    _descriptionCtrl.clear();
    setState(() {
      _showForm = false;
      _category = '';
      _issueDate = null;
    });
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certificate issued successfully!'), behavior: SnackBarBehavior.floating),
    );
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Certificate Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                            const SizedBox(height: 4),
                            Text('Issue and manage certificates for your students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _showForm = !_showForm),
                        icon: Icon(_showForm ? Icons.close : Icons.add),
                        label: Text(_showForm ? 'Cancel' : 'Issue Certificate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_showForm) _issueFormCard(),
                  AppCard(
                    heading: 'Filter by Student',
                    padding: const EdgeInsets.all(24),
                    child: _students.isEmpty
                        ? Text('No students added yet', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
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

  Widget _issueFormCard() {
    return AppCard(
      heading: 'Issue Certificate',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Select Student *'),
          DropdownButtonFormField<String>(
            initialValue: _selectedStudent,
            hint: const Text('-- Select a student --'),
            items: _students.map((s) => DropdownMenuItem(value: '${s.name} (${s.rollNo})', child: Text('${s.name} (${s.rollNo})'))).toList(),
            onChanged: (v) => setState(() => _selectedStudent = v),
          ),
          const SizedBox(height: 16),
          _label('Certificate Title *'),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'e.g., Best Student Award 2026')),
          const SizedBox(height: 16),
          _label('Category *'),
          DropdownButtonFormField<String>(
            initialValue: _category.isEmpty ? null : _category,
            items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => _category = v ?? ''),
            decoration: const InputDecoration(hintText: '-- Select Category --'),
          ),
          const SizedBox(height: 16),
          _label('Issued By *'),
          TextField(controller: _issuedByCtrl, decoration: const InputDecoration(hintText: 'e.g., RIT College / Organization Name')),
          const SizedBox(height: 16),
          _label('Issue Date *'),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(hintText: 'Select date', suffixIcon: Icon(Icons.calendar_today)),
              child: Text(
                _issueDate != null ? '${_issueDate!.day}/${_issueDate!.month}/${_issueDate!.year}' : '',
                style: TextStyle(
                  color: _issueDate != null ? AppColorsExtension.of(context).textPrimary : AppColorsExtension.of(context).textLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('Description'),
          TextField(controller: _descriptionCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Brief description of the certificate...')),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _showForm = false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _issueCertificate, child: const Text('Issue Certificate')),
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
