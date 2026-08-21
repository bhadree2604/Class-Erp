import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/certificate.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Student certificates — view only.
class StudentCertificatesScreen extends StatefulWidget {
  const StudentCertificatesScreen({super.key});

  @override
  State<StudentCertificatesScreen> createState() =>
      _StudentCertificatesScreenState();
}

class _StudentCertificatesScreenState extends State<StudentCertificatesScreen> {
  String _userName = 'Student';
  List<Certificate> _certificates = const [];
  bool _loading = true;

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
    final certs = await DataService.instance.getCertificates(
      user?.userId ?? DataService.defaultStudentId,
    );
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _certificates = certs;
      _loading = false;
    });
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
                  Text(
                    'My Certificates',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColorsExtension.of(context).textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View certificates issued by your mentor',
                    style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (_certificates.isEmpty)
                    AppCard(
                      child: Column(
                        children: [
                          SizedBox(height: 32),
                          Icon(Icons.emoji_events_outlined,
                              size: 64, color: AppColorsExtension.of(context).textLight),
                          SizedBox(height: 16),
                          Text(
                            'No Certificates Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColorsExtension.of(context).textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Certificates issued by your mentor will appear here',
                            style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  if (_certificates.isNotEmpty)
                    ..._certificates.map((c) => _certificateCard(c)),
                ],
              ),
            ),
    );
  }

  Widget _certificateCard(Certificate cert) {
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColorsExtension.of(context).textPrimary,
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
              style: TextStyle(
                color: AppColorsExtension.of(context).textSecondary,
                fontSize: 14,
              ),
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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColorsExtension.of(context).textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
