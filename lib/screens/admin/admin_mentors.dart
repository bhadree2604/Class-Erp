import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/portal_scaffold.dart';

class AdminMentorsScreen extends StatefulWidget {
  const AdminMentorsScreen({super.key});

  @override
  State<AdminMentorsScreen> createState() => _AdminMentorsScreenState();
}

class _AdminMentorsScreenState extends State<AdminMentorsScreen> {
  late Future<List<User>> _mentorsFuture;
  final _searchController = TextEditingController();
  List<User> _allMentors = [];
  List<User> _filteredMentors = [];

  @override
  void initState() {
    super.initState();
    _loadMentors();
    _searchController.addListener(_filterMentors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMentors() {
    setState(() {
      _mentorsFuture = AuthService.instance.getAllUsers('mentor');
    });
  }

  void _refresh() => _loadMentors();

  void _filterMentors() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredMentors = _allMentors;
      } else {
        _filteredMentors = _allMentors.where((mentor) {
          return mentor.userId.toLowerCase().contains(query) ||
              mentor.fullName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showMentorDetails(User mentor) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(mentor.userId.substring(0, 2).toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(mentor.fullName)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Mentor ID', mentor.userId),
              _detailRow('Full Name', mentor.fullName),
              _detailRow('Email', mentor.email),
              _detailRow('Phone', mentor.phone),
              _detailRow('Department', mentor.department),
              _detailRow('Designation', mentor.designation),
              _detailRow('Qualification', mentor.qualification),
              _detailRow('Experience', '${mentor.experience} years'),
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
      title: 'All Mentors',
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<User>>(
          future: _mentorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            _allMentors = snapshot.data ?? [];
            if (_filteredMentors.isEmpty && _searchController.text.isEmpty) {
              _filteredMentors = _allMentors;
            }
            if (_filteredMentors.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No mentors found.'),
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
                      labelText: 'Search by Mentor ID or Name',
                      hintText: 'Enter mentor ID or name',
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
                    itemCount: _filteredMentors.length,
                    itemBuilder: (context, index) {
                      final mentor = _filteredMentors[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(mentor.userId.substring(0, 2).toUpperCase()),
                          ),
                          title: Text(mentor.fullName),
                          subtitle: Text('ID: ${mentor.userId} | Dept: ${mentor.department}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () => _showMentorDetails(mentor),
                          ),
                          onLongPress: () {
                            _showMentorOptions(context, mentor);
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

  void _showMentorOptions(BuildContext context, User mentor) {
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
                _showMentorDetails(mentor);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Mentor'),
              onTap: () {
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit mentor ${mentor.fullName} - coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Mentor',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Mentor'),
                    content: Text(
                        'Are you sure you want to delete ${mentor.fullName}?'),
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
                  final error = await AuthService.instance.deleteUser(mentor.userId);
                  if (!mounted) return;
                  if (error == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mentor deleted')),
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