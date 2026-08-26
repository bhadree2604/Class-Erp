import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/portal_scaffold.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  late Future<List<User>> _studentsFuture;
  final _searchController = TextEditingController();
  List<User> _allStudents = [];
  List<User> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
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

  void _refresh() => _loadStudents();

  void _filterStudents() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((student) {
          return student.userId.toLowerCase().contains(query) ||
              student.fullName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showStudentDetails(User student) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(student.userId.substring(0, 2).toUpperCase()),
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
              _detailRow('Roll Number', student.userId),
              _detailRow('Full Name', student.fullName),
              _detailRow('Email', student.email),
              _detailRow('Phone', student.phone),
              _detailRow('Department', student.department),
              _detailRow('Semester', student.semester),
              _detailRow('Batch', student.batch),
              _detailRow('Section', student.section),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'admin',
      title: 'All Students',
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<User>>(
          future: _studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            _allStudents = snapshot.data ?? [];
            if (_filteredStudents.isEmpty && _searchController.text.isEmpty) {
              _filteredStudents = _allStudents;
            }
            if (_filteredStudents.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No students found.'),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _searchController.clear(),
                              child: const Text('Clear search'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
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
                      suffixIcon: _searchController.text.isNotEmpty
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
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(student.userId.substring(0, 2).toUpperCase()),
                          ),
                          title: Text(student.fullName),
                          subtitle: Text('Roll: ${student.userId} | Dept: ${student.department}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () => _showStudentDetails(student),
                          ),
                          onLongPress: () {
                            _showStudentOptions(context, student);
                          },
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
                _showStudentDetails(student);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Student'),
              onTap: () {
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit student ${student.fullName} - coming soon')),
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
                  final error = await AuthService.instance.deleteUser(student.userId);
                  if (!mounted) return;
                  if (error == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student deleted')),
                    );
                    _refresh();
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
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