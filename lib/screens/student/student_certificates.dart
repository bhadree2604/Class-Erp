import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/certificate.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Student certificates — mirror of `student/certificates.html`.
class StudentCertificatesScreen extends StatefulWidget {
  const StudentCertificatesScreen({super.key});

  @override
  State<StudentCertificatesScreen> createState() =>
      _StudentCertificatesScreenState();
}

class _StudentCertificatesScreenState extends State<StudentCertificatesScreen> {
  String _userName = 'Student';
  String _studentId = '';
  List<Certificate> _certificates = const [];
  bool _loading = true;
  bool _showUploadForm = false;

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
  void dispose() {
    _titleCtrl.dispose();
    _issuedByCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final certs = await DataService.instance.getCertificates(
      user?.userId ?? DataService.defaultStudentId,
    );
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _studentId = user?.userId ?? DataService.defaultStudentId;
      _certificates = certs;
      _loading = false;
    });
  }

  void _toggleUploadForm() {
    setState(() => _showUploadForm = !_showUploadForm);
  }

  void _cancelUpload() {
    _titleCtrl.clear();
    _issuedByCtrl.clear();
    _descriptionCtrl.clear();
    setState(() {
      _showUploadForm = false;
      _category = '';
      _issueDate = null;
    });
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

  Future<void> _uploadCertificate() async {
    if (_titleCtrl.text.isEmpty ||
        _category.isEmpty ||
        _issuedByCtrl.text.isEmpty ||
        _issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dateStr = _issueDate!.toIso8601String().split('T')[0];
    final cert = Certificate(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      category: _category,
      issuedBy: _issuedByCtrl.text.trim(),
      date: dateStr,
      dateIssued: dateStr,
      description:
          _descriptionCtrl.text.trim().isEmpty
              ? 'No description provided'
              : _descriptionCtrl.text.trim(),
      fileData: null,
      fileName: null,
      uploadedBy: 'Student',
      uploadedAt: DateTime.now().toIso8601String(),
    );

    await DataService.instance.addCertificate(_studentId, cert);
    _cancelUpload();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate uploaded successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteCertificate(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: const Text(
            'Are you sure you want to delete this certificate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final certs = List<Certificate>.from(_certificates);
      certs.removeAt(index);
      final student =
          await DataService.instance.getStudentData(_studentId);
      await DataService.instance.saveStudentProfile(
          _studentId, student.copyWith(certificates: certs));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Certificates',
      userName: _userName,
      currentRoute: AppRoutes.studentCertificates,
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
                              'My Certificates',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'View, upload, and download your certificates',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _toggleUploadForm,
                        icon: Icon(
                            _showUploadForm ? Icons.close : Icons.add),
                        label: Text(_showUploadForm
                            ? 'Cancel'
                            : 'Upload Certificate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_showUploadForm) _uploadFormCard(),
                  if (_certificates.isEmpty && !_showUploadForm)
                    AppCard(
                      child: Column(
                        children: const [
                          SizedBox(height: 32),
                          Icon(Icons.emoji_events_outlined,
                              size: 64, color: AppColors.textLight),
                          SizedBox(height: 16),
                          Text(
                            'No Certificates Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload your certificates or wait for them to be issued by your mentor',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  if (_certificates.isNotEmpty)
                    ...List.generate(_certificates.length, (i) =>
                        _certificateCard(_certificates[i], i)),
                ],
              ),
            ),
    );
  }

  Widget _uploadFormCard() {
    return AppCard(
      heading: 'Upload Certificate',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel('Certificate Title *'),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g., Best Student Award 2026',
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Category *'),
          DropdownButtonFormField<String>(
            initialValue: _category.isEmpty ? null : _category,
            items: [
              for (final c in _categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v ?? ''),
            decoration: const InputDecoration(
              hintText: '-- Select Category --',
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Issued By *'),
          TextField(
            controller: _issuedByCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g., RIT College / Organization Name',
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Issue Date *'),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _issueDate != null
                    ? '${_issueDate!.day}/${_issueDate!.month}/${_issueDate!.year}'
                    : '',
                style: TextStyle(
                  color: _issueDate != null
                      ? AppColors.textPrimary
                      : AppColors.textLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Description'),
          TextField(
            controller: _descriptionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Brief description of the certificate...',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelUpload,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _uploadCertificate,
                child: const Text('Upload Certificate'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _certificateCard(Certificate cert, int index) {
    final uploadedBy = cert.uploadedBy;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events,
                    color: AppColors.warning, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cert.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _certInfoRow('Category', cert.category),
            _certInfoRow('Issued by', cert.issuedBy),
            _certInfoRow('Date', _formatDate(cert.date)),
            const SizedBox(height: 8),
            Text(
              cert.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Uploaded by: $uploadedBy',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (uploadedBy == 'Student')
                  OutlinedButton(
                    onPressed: () => _deleteCertificate(index),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _certInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
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

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}