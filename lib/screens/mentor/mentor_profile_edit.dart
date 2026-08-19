import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorProfileEditScreen extends StatefulWidget {
  const MentorProfileEditScreen({super.key});

  @override
  State<MentorProfileEditScreen> createState() => _MentorProfileEditScreenState();
}

class _MentorProfileEditScreenState extends State<MentorProfileEditScreen> {
  String _userName = 'Mentor';
  bool _loading = true;

  final _nameCtrl = TextEditingController(text: 'Dr. Rajesh Kumar');
  final _emailCtrl = TextEditingController(text: 'rajesh.kumar@rit.edu');
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');
  final _dobCtrl = TextEditingController(text: '1980-05-15');
  final _nationalityCtrl = TextEditingController(text: 'Indian');
  final _designationCtrl = TextEditingController(text: 'Assistant Professor');
  final _specializationCtrl = TextEditingController(text: 'Data Science, Machine Learning');
  final _expCtrl = TextEditingController(text: '10');
  final _joiningDateCtrl = TextEditingController(text: '2014-07-01');
  final _officeCtrl = TextEditingController(text: 'Room 305, CS Block');
  final _empIdCtrl = TextEditingController(text: 'EMP2024001');
  final _currentAddrCtrl = TextEditingController(text: '123 Main Street, Apartment 4B');
  final _permAddrCtrl = TextEditingController(text: '456 Home Street, City, State');
  final _cityCtrl = TextEditingController(text: 'Chennai');
  final _stateCtrl = TextEditingController(text: 'Tamil Nadu');
  final _pincodeCtrl = TextEditingController(text: '600001');
  final _countryCtrl = TextEditingController(text: 'India');
  final _emergencyNameCtrl = TextEditingController(text: 'Family Member');
  final _emergencyPhoneCtrl = TextEditingController(text: '+91 98765 43210');
  final _emergencyEmailCtrl = TextEditingController(text: 'emergency@email.com');

  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'B+';
  String _selectedDept = 'Computer Science';
  String _selectedQual = 'Ph.D';
  String _selectedRelation = 'Spouse';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _dobCtrl.dispose();
    _nationalityCtrl.dispose(); _designationCtrl.dispose(); _specializationCtrl.dispose();
    _expCtrl.dispose(); _joiningDateCtrl.dispose(); _officeCtrl.dispose(); _empIdCtrl.dispose();
    _currentAddrCtrl.dispose(); _permAddrCtrl.dispose(); _cityCtrl.dispose();
    _stateCtrl.dispose(); _pincodeCtrl.dispose(); _countryCtrl.dispose();
    _emergencyNameCtrl.dispose(); _emergencyPhoneCtrl.dispose(); _emergencyEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _loading = false;
    });
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Edit Profile',
      userName: _userName,
      currentRoute: AppRoutes.mentorProfileEdit,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      SizedBox(height: 4),
                      Text('Update your professional information', style: TextStyle(color: AppColors.textSecondary)),
                    ])),
                    TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Back to Profile')),
                  ]),
                  const SizedBox(height: 24),
                  AppCard(heading: 'Personal Information', padding: const EdgeInsets.all(24), child: _formGrid([
                    _field('Full Name *', _nameCtrl),
                    _field('Mentor ID', TextEditingController(text: 'M2024001')..dispose()),
                    _field('Email *', _emailCtrl),
                    _field('Phone *', _phoneCtrl),
                    _field('Date of Birth *', _dobCtrl),
                    _dropdown('Gender *', ['Male', 'Female', 'Other'], _selectedGender, (v) => _selectedGender = v),
                    _dropdown('Blood Group', ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], _selectedBloodGroup, (v) => _selectedBloodGroup = v),
                    _field('Nationality', _nationalityCtrl),
                  ])),
                  const SizedBox(height: 24),
                  AppCard(heading: 'Professional Information', padding: const EdgeInsets.all(24), child: _formGrid([
                    _dropdown('Department *', ['Computer Science', 'IT', 'Electronics', 'Mechanical', 'Civil', 'Electrical'], _selectedDept, (v) => _selectedDept = v),
                    _field('Designation *', _designationCtrl),
                    _dropdown('Qualification *', ['Ph.D', 'M.Tech', 'M.E', 'M.Sc', 'MBA'], _selectedQual, (v) => _selectedQual = v),
                    _field('Specialization *', _specializationCtrl),
                    _field('Experience *', _expCtrl),
                    _field('Joining Date *', _joiningDateCtrl),
                    _field('Office Room', _officeCtrl),
                    _field('Employee ID', _empIdCtrl),
                  ])),
                  const SizedBox(height: 24),
                  AppCard(heading: 'Address Information', padding: const EdgeInsets.all(24), child: Column(children: [
                    _field('Current Address *', _currentAddrCtrl),
                    const SizedBox(height: 16),
                    _field('Permanent Address *', _permAddrCtrl),
                    const SizedBox(height: 16),
                    _formGrid([_field('City *', _cityCtrl), _field('State *', _stateCtrl), _field('Pincode *', _pincodeCtrl), _field('Country *', _countryCtrl)]),
                  ])),
                  const SizedBox(height: 24),
                  AppCard(heading: 'Emergency Contact', padding: const EdgeInsets.all(24), child: _formGrid([
                    _field('Contact Name *', _emergencyNameCtrl),
                    _dropdown('Relationship *', ['Spouse', 'Parent', 'Sibling', 'Child', 'Other'], _selectedRelation, (v) => _selectedRelation = v),
                    _field('Phone *', _emergencyPhoneCtrl),
                    _field('Email', _emergencyEmailCtrl),
                  ])),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: _save, child: const Text('Save All Changes')),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      TextField(controller: ctrl, decoration: const InputDecoration()),
    ]);
  }

  Widget _dropdown(String label, List<String> items, String value, ValueChanged<String> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ]);
  }

  Widget _formGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 500) {
          return Wrap(spacing: 16, runSpacing: 16, children: children.map((c) => SizedBox(width: (constraints.maxWidth - 16) / 2, child: c)).toList());
        }
        return Column(children: [for (final c in children) ...[c, const SizedBox(height: 16)]]..removeLast());
      },
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)));
}