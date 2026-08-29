import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/portal_scaffold.dart';

class AdminCreateUserScreen extends StatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  State<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedDepartment = '';
  String _selectedRole = 'student';
  bool _loading = false;
  String? _error;

  static const _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    String userId;
    String username;
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please enter email';
      });
      return;
    }

    if (_selectedRole == 'student') {
      final localPart = email.substring(0, email.indexOf('@'));
      if (!RegExp(r'^\d+$').hasMatch(localPart)) {
        setState(() {
          _loading = false;
          _error = 'Student email must contain only numbers before @';
        });
        return;
      }
      userId = localPart;
      username = email; // login uses email as username
    } else {
      // mentor
      final users = await AuthService.instance.getUsersData();
      final mentorId = AuthService.getNextMentorId(users);
      userId = mentorId;
      username = email; // login uses email as username
    }

    final userData = {
      'username': username,
      'password': _passwordController.text,
      'email': email,
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'department': _selectedDepartment,
      'user_type': _selectedRole,
      'user_id': userId,
    };
    final error = await AuthService.instance.createUser(userData);
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
      Navigator.of(context).pop(true); // return true to signal refresh needed
    } else {
      if (!mounted) return;
      setState(() {
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'admin',
      title: 'Create User',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'mentor', child: Text('Mentor')),
                ],
                initialValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                    _selectedDepartment = '';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (used for login)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Department'),
                initialValue: _selectedDepartment.isEmpty ? null : _selectedDepartment,
                items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('CREATE USER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
