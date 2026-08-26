import 'package:flutter/material.dart';

import '../../app_routes.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMentors();
    _searchController.addListener(() => mounted ? setState(() {}) : null);
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

  bool get _hasQuery => _searchController.text.trim().isNotEmpty;

  void _showMentorDetails(BuildContext rowContext, User mentor) {
    showDialog<void>(
      context: rowContext,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                mentor.userId.isNotEmpty
                    ? mentor.userId.substring(0, 2).toUpperCase()
                    : '?',
              ),
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
              _detailRow(dialogContext, 'Mentor ID', mentor.userId),
              _detailRow(dialogContext, 'Full Name', mentor.fullName),
              _detailRow(dialogContext, 'Login Email', mentor.username),
              _detailRow(dialogContext, 'Email', mentor.email),
              _detailRow(dialogContext, 'Phone', mentor.phone),
              _detailRow(dialogContext, 'Department', mentor.department),
              _detailRow(dialogContext, 'Designation', mentor.designation),
              _detailRow(dialogContext, 'Qualification', mentor.qualification),
              _detailRow(
                dialogContext,
                'Experience',
                mentor.experience.isEmpty ? '' : '${mentor.experience} years',
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
                  searching ? Icons.search_off : Icons.person_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(searching
                    ? 'No mentors match your search.'
                    : 'No mentors yet.'),
                const SizedBox(height: 4),
                Text(
                  searching
                      ? 'Try a different mentor ID or name.'
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
                    label: const Text('Create Mentor'),
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
      title: 'All Mentors',
      body: RefreshIndicator(
        onRefresh: () async => _loadMentors(),
        child: FutureBuilder<List<User>>(
          future: _mentorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final allMentors = snapshot.data ?? [];
            // Pure filter computed per build — always reflects fresh data.
            final query = _searchController.text.toLowerCase().trim();
            final visible = query.isEmpty
                ? allMentors
                : allMentors
                    .where((m) =>
                        m.userId.toLowerCase().contains(query) ||
                        m.fullName.toLowerCase().contains(query))
                    .toList();

            if (visible.isEmpty) {
              // Distinguish genuinely-empty vs no-search-results.
              return _emptyState(searching: allMentors.isNotEmpty);
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
                      final mentor = visible[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              mentor.userId.isNotEmpty
                                  ? mentor.userId
                                      .substring(0, 2)
                                      .toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(mentor.fullName),
                          subtitle: Text(
                              'ID: ${mentor.userId} | Dept: ${mentor.department}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            tooltip: 'View Details',
                            onPressed: () =>
                                _showMentorDetails(context, mentor),
                          ),
                          onLongPress: () =>
                              _showMentorOptions(context, mentor),
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
                _showMentorDetails(context, mentor);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Mentor'),
              onTap: () {
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Edit mentor ${mentor.fullName} - coming soon')),
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
                  final error =
                      await AuthService.instance.deleteUser(mentor.userId);
                  if (!mounted) return;
                  if (error == null) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Mentor deleted')),
                    );
                    _loadMentors();
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