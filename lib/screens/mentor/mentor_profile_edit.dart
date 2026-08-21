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

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _joiningDateCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  final _empIdCtrl = TextEditingController();
  final _currentAddrCtrl = TextEditingController();
  final _permAddrCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _emergencyEmailCtrl = TextEditingController();

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
    if (user == null) {
      if (!mounted) return;
      setState(() { _loading = false; });
      return;
    }
    final extra = user.extra;
    _nameCtrl.text = user.fullName;
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.phone;
    _dobCtrl.text = extra['dob'] as String? ?? '';
    _nationalityCtrl.text = extra['nationality'] as String? ?? '';
    _designationCtrl.text = extra['designation'] as String? ?? '';
    _specializationCtrl.text = extra['specialization'] as String? ?? '';
    _expCtrl.text = extra['experience'] as String? ?? '';
    _joiningDateCtrl.text = extra['joiningDate'] as String? ?? '';
    _officeCtrl.text = extra['office'] as String? ?? '';
    _empIdCtrl.text = extra['employeeId'] as String? ?? '';
    _currentAddrCtrl.text = extra['currentAddress'] as String? ?? '';
    _permAddrCtrl.text = extra['permanentAddress'] as String? ?? '';
    _cityCtrl.text = extra['city'] as String? ?? '';
    _stateCtrl.text = extra['state'] as String? ?? '';
    _pincodeCtrl.text = extra['pincode'] as String? ?? '';
    _countryCtrl.text = extra['country'] as String? ?? '';
    _emergencyNameCtrl.text = extra['emergencyName'] as String? ?? '';
    _emergencyPhoneCtrl.text = extra['emergencyPhone'] as String? ?? '';
    _emergencyEmailCtrl.text = extra['emergencyEmail'] as String? ?? '';
    _selectedGender = extra['gender'] as String? ?? 'Male';
    _selectedBloodGroup = extra['bloodGroup'] as String? ?? 'B+';
    _selectedDept = user.department.isNotEmpty ? user.department : (extra['department'] as String? ?? 'Computer Science');
    _selectedQual = extra['qualification'] as String? ?? 'Ph.D';
    _selectedRelation = extra['emergencyRelation'] as String? ?? 'Spouse';
    if (!mounted) return;
    setState(() {
      _userName = user.fullName.isNotEmpty ? user.fullName : 'Mentor';
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating));
      return;
    }
    final fields = {
      'full_name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'department': _selectedDept,
      'designation': _designationCtrl.text.trim(),
      'qualification': _selectedQual,
      'experience': _expCtrl.text.trim(),
      'dob': _dobCtrl.text.trim(),
      'nationality': _nationalityCtrl.text.trim(),
      'specialization': _specializationCtrl.text.trim(),
      'joiningDate': _joiningDateCtrl.text.trim(),
      'office': _officeCtrl.text.trim(),
      'employeeId': _empIdCtrl.text.trim(),
      'currentAddress': _currentAddrCtrl.text.trim(),
      'permanentAddress': _permAddrCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'gender': _selectedGender,
      'bloodGroup': _selectedBloodGroup,
      'emergencyName': _emergencyNameCtrl.text.trim(),
      'emergencyPhone': _emergencyPhoneCtrl.text.trim(),
      'emergencyEmail': _emergencyEmailCtrl.text.trim(),
      'emergencyRelation': _selectedRelation,
    };
    await AuthService.instance.updateUserFields(fields);
    if (!mounted) return;
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
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                      SizedBox(height: 4),
                      Text('Update your professional information', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                    ])),
                    TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Back to Profile')),
                  ]),
                  const SizedBox(height: 24),
                  AppCard(heading: 'Personal Information', padding: const EdgeInsets.all(24), child: _formGrid([
                    _field('Full Name *', _nameCtrl),
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

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary, fontSize: 14)));
}
