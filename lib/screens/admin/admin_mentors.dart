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
  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  void _loadMentors() {
    setState(() {
      _mentorsFuture = AuthService.instance.getAllUsers('mentor');
    });
  }

  void _refresh() => _loadMentors();

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
            final mentors = snapshot.data ?? [];
            if (mentors.isEmpty) {
              return const Center(child: Text('No mentors found.'));
            }
            return ListView.builder(
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                final mentor = mentors[index];
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
                      onPressed: () {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('View details for ${mentor.fullName}')),
                        );
                      },
                    ),
                    onLongPress: () {
                      _showMentorOptions(context, mentor);
                    },
                  ),
                );
              },
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
              leading: const Icon(Icons.edit),
              title: const Text('Edit Mentor'),
              onTap: () {
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit mentor ${mentor.fullName}')),
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