import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/student_profile.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../widgets/portal_scaffold.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  late Future<List<User>> _studentsFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(() => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    setState(() {
      _studentsFuture = AuthService.instance.getAllUsers('student');
    });
  }

  bool get _hasQuery => _searchController.text.trim().isNotEmpty;

  void _showStudentDetails(BuildContext rowContext, User student) {
    showDialog<void>(
      context: rowContext,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                student.userId.isNotEmpty
                    ? student.userId.substring(0, 2).toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(student.fullName)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(dialogContext, 'Roll Number', student.userId),
              _detailRow(dialogContext, 'Full Name', student.fullName),
              _detailRow(dialogContext, 'Login Email', student.username),
              _detailRow(dialogContext, 'Email', student.email),
              _detailRow(dialogContext, 'Phone', student.phone),
              _detailRow(dialogContext, 'Department', student.department),
              // Academic data lives in DataService (StudentProfile), not the
              // auth users table — load it for this specific roll number.
              FutureBuilder<StudentProfile>(
                future:
                    DataService.instance.getStudentData(student.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final profile = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(
                          dialogContext, 'Semester', profile?.semester ?? ''),
                      _detailRow(dialogContext, 'Batch', profile?.batch ?? ''),
                      _detailRow(
                          dialogContext, 'Section', profile?.section ?? ''),
                      _detailRow(dialogContext, 'Attendance',
                          '${profile?.attendance ?? 0}%'),
                      _detailRow(dialogContext, 'CGPA',
                          (profile?.cgpa ?? 0).toStringAsFixed(2)),
                      _detailRow(dialogContext, 'GPA',
                          (profile?.gpa ?? 0).toStringAsFixed(2)),
                      _detailRow(dialogContext, 'Arrears',
                          '${profile?.arrears ?? 0}'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required bool searching}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searching ? Icons.search_off : Icons.school_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(searching
                    ? 'No students match your search.'
                    : 'No students yet.'),
                const SizedBox(height: 4),
                Text(
                  searching
                      ? 'Try a different roll number or name.'
                      : 'Create one to get started.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (searching)
                  TextButton.icon(
                    onPressed: () => _searchController.clear(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear search'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.adminCreateUser),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Create Student'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'admin',
      title: 'All Students',
      body: RefreshIndicator(
        onRefresh: () async => _loadStudents(),
        child: FutureBuilder<List<User>>(
          future: _studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final allStudents = snapshot.data ?? [];
            // Pure filter computed per build — never mutated state, so it
            // always reflects fresh data after create/delete/refresh.
            final query = _searchController.text.toLowerCase().trim();
            final visible = query.isEmpty
                ? allStudents
                : allStudents
                    .where((s) =>
                        s.userId.toLowerCase().contains(query) ||
                        s.fullName.toLowerCase().contains(query))
                    .toList();

            if (visible.isEmpty) {
              // Distinguish genuinely-empty vs no-search-results.
              return _emptyState(searching: allStudents.isNotEmpty);
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Roll Number or Name',
                      hintText: 'Enter roll number (e.g., 104001) or name',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _hasQuery
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final student = visible[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              student.userId.isNotEmpty
                                  ? student.userId
                                      .substring(0, 2)
                                      .toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(student.fullName),
                          subtitle: Text(
                              'Roll: ${student.userId} | Dept: ${student.department}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            tooltip: 'View Details',
                            onPressed: () =>
                                _showStudentDetails(context, student),
                          ),
                          onLongPress: () =>
                              _showStudentOptions(context, student),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showStudentOptions(BuildContext context, User student) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showStudentDetails(context, student);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Student'),
              onTap: () {
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Edit student ${student.fullName} - coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Student',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Student'),
                    content: Text(
                        'Are you sure you want to delete ${student.fullName}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final error =
                      await AuthService.instance.deleteUser(student.userId);
                  if (!mounted) return;
                  if (error == null) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Student deleted')),
                    );
                    _loadStudents();
                  } else {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}