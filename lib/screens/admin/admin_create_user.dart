import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/portal_scaffold.dart';

class AdminCreateUserScreen extends StatefulWidget {
  const AdminCreateUserScreen({super.key});

  @override
  State<AdminCreateUserScreen> createState() => _AdminCreateUserScreenState();
}

class _AdminCreateUserScreenState extends State<AdminCreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _semesterController = TextEditingController(); // only for student
  String _selectedRole = 'student';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final userData = {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'email': _emailController.text.trim(),
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'department': _departmentController.text.trim(),
      'user_type': _selectedRole,
    };
    if (_selectedRole == 'student') {
      final semester = _semesterController.text.trim();
      if (semester.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Semester is required for students';
        });
        return;
      }
      userData['semester'] = semester;
      // Validate roll number format (username will be used as roll number?)
      // We'll treat username as roll number for student
      final roll = _usernameController.text.trim();
      if (!RegExp(r'^9536\d{8}$').hasMatch(roll)) {
        setState(() {
          _loading = false;
          _error = 'Roll number must be in format 9536YYDDDNNN';
        });
        return;
      }
      userData['user_id'] = roll;
    } else {
      // mentor: use username as user_id
      userData['user_id'] = _usernameController.text.trim();
    }
    final error = await AuthService.instance.createUser(userData);
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (error == null) {
      // clear form
      _formKey.currentState!.reset();
      setState(() {
        _selectedRole = 'student';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
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
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: _selectedRole == 'student' ? 'Roll Number' : 'Mentor ID',
                  hintText: _selectedRole == 'student'
                      ? 'Enter 9536YYDDDNNN'
                      : 'Enter mentor ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ${_selectedRole == 'student' ? 'roll number' : 'mentor ID'}';
                  }
                  if (_selectedRole == 'student' &&
                      !RegExp(r'^9536\d{8}$').hasMatch(value)) {
                    return 'Roll number must be in format 9536YYDDDNNN';
                  }
                  return null;
                },
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
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  // simple email check
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
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
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedRole == 'student')
                TextFormField(
                  controller: _semesterController,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter semester';
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