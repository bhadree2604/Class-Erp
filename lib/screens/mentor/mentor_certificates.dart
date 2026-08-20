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
  bool _showForm = false;
  String? _selectedStudent;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _selectedCategory = 'Academic Excellence';
  List<Certificate> _certificates = [];

  static const _categories = ['Academic Excellence', 'Sports Achievement', 'Cultural Event', 'Technical Competition', 'Leadership', 'Perfect Attendance', 'Other'];
  List<MentorStudent> _students = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final students = await DataService.instance.getMentorStudents();
    final allCerts = <Certificate>[];
    for (final s in students) {
      final certs = await DataService.instance.getCertificates(s.rollNo);
      allCerts.addAll(certs.where((c) => c.uploadedBy == 'Mentor'));
    }
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _students = students;
      _certificates = allCerts;
      _loading = false;
    });
  }

  Future<void> _issue() async {
    if (_selectedStudent == null || _titleCtrl.text.isEmpty || _descCtrl.text.isEmpty || _dateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating));
      return;
    }
    final cert = Certificate(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      category: _selectedCategory,
      issuedBy: 'RIT College - Mentor',
      date: _dateCtrl.text.trim(),
      dateIssued: _dateCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      uploadedBy: 'Mentor',
      uploadedAt: DateTime.now().toIso8601String(),
    );
    await DataService.instance.addCertificate(_selectedStudent!, cert);
    _titleCtrl.clear();
    _descCtrl.clear();
    _dateCtrl.clear();
    setState(() => _showForm = false);
    _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Certificate issued to $_selectedStudent!'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Certificate Management',
      userName: _userName,
      currentRoute: AppRoutes.mentorCertificates,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Certificate Management',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Issue certificates to students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(onPressed: () => setState(() => _showForm = !_showForm), icon: Icon(_showForm ? Icons.close : Icons.add), label: Text(_showForm ? 'Cancel' : 'Issue Certificate')),
                      ],
                    ),
                  ),
                  if (_showForm) ...[
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Issue Certificate to Student',
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Select Student *'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStudent,
                            hint: const Text('-- Select Student --'),
                            items: _students.map((s) => DropdownMenuItem(value: s.rollNo, child: Text('${s.name} (${s.rollNo})'))).toList(),
                            onChanged: (v) => setState(() => _selectedStudent = v),
                          ),
                          const SizedBox(height: 16),
                          _label('Certificate Title *'),
                          TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'e.g., Best Student Award 2026')),
                          const SizedBox(height: 16),
                          _label('Category *'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                          ),
                          const SizedBox(height: 16),
                          _label('Issue Date *'),
                          TextField(controller: _dateCtrl, decoration: const InputDecoration(hintText: 'YYYY-MM-DD')),
                          const SizedBox(height: 16),
                          _label('Description *'),
                          TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Certificate description...')),
                          const SizedBox(height: 24),
                          Row(children: [
                            TextButton(onPressed: () => setState(() => _showForm = false), child: const Text('Cancel')),
                            const SizedBox(width: 12),
                            ElevatedButton(onPressed: _issue, child: const Text('Issue Certificate')),
                          ]),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Recently Issued Certificates',
                    padding: const EdgeInsets.all(24),
                    child: _certificates.isEmpty
                        ? Text('No certificates issued yet', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                        : Table(
                            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(2.5), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1.5)},
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                                children: [_H('Student'), _H('Title'), _H('Category'), _H('Date')],
                              ),
                              for (final c in _certificates)
                                TableRow(
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColorsExtension.of(context).bgTertiary))),
                                  children: [_B(c.issuedBy), _B(c.title), _B(c.category), _B(c.date)],
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