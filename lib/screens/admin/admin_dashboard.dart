import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/portal_scaffold.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<int> _studentCountFuture;
  late Future<int> _mentorCountFuture;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    setState(() {
      _studentCountFuture = AuthService.instance.getAllUsers('student')
          .then((list) => list.length);
      _mentorCountFuture = AuthService.instance.getAllUsers('mentor')
          .then((list) => list.length);
    });
  }

  void _refresh() {
    setState(() {
      _loadCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'admin',
      title: 'Admin Dashboard',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _studentCountFuture,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _summaryCard(
                        title: 'Students',
                        value: count.toString(),
                        icon: Icons.people_outline,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _mentorCountFuture,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _summaryCard(
                        title: 'Mentors',
                        value: count.toString(),
                        icon: Icons.person_outline,
                        color: Colors.green,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}