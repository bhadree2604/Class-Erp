import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorAttendanceScreen extends StatefulWidget {
  const MentorAttendanceScreen({super.key});

  @override
  State<MentorAttendanceScreen> createState() => _MentorAttendanceScreenState();
}

class _MentorAttendanceScreenState extends State<MentorAttendanceScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  String _selectedSubject = 'CS25C06';
  late DateTime _currentMonth;
  final Map<String, String> _attendance = {};

  static const _students = [
    ('953625104001', 'Bhadree'),
    ('953625104002', 'Amit Patel'),
    ('953625104003', 'Rahul Kumar'),
    ('953625104004', 'Priya Sharma'),
    ('953625104005', 'Vikram Singh'),
  ];

  static const _subjects = {
    'CS25C06': 'CS25C06 - Digital Principles',
    'CS25C07': 'CS25C07 - OOP',
    'MA25C02': 'MA25C02 - Linear Algebra',
    'EE25C01': 'EE25C01 - Basic EE',
    'UC25H02': 'UC25H02 - Tamils & Tech',
  };

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _loading = false;
    });
  }

  int get _daysInMonth => DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

  String _cellKey(String roll, int day) => '$_selectedSubject|$roll|${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  void _toggleCell(String roll, int day) {
    final key = _cellKey(roll, day);
    final current = _attendance[key];
    setState(() {
      if (current == null) {
        _attendance[key] = 'present';
      } else if (current == 'present') {
        _attendance[key] = 'absent';
      } else {
        _attendance.remove(key);
      }
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  int _studentPresentCount(String roll) {
    int count = 0;
    for (int d = 1; d <= _daysInMonth; d++) {
      if (_attendance[_cellKey(roll, d)] == 'present') count++;
    }
    return count;
  }

  int _studentTotalCount(String roll) {
    int count = 0;
    for (int d = 1; d <= _daysInMonth; d++) {
      if (_attendance[_cellKey(roll, d)] != null) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    return PortalScaffold(
      role: 'mentor',
      title: 'Attendance Management',
      userName: _userName,
      currentRoute: AppRoutes.mentorAttendance,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Attendance Management System', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                            SizedBox(height: 4),
                            Text('Professional attendance tracking and reporting', style: TextStyle(color: Colors.white70)),
                          ]),
                          Row(children: [
                            OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white), child: const Text('Weekly Report')),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: () {}, child: const Text('Monthly Report')),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Container(
                          color: AppColors.bgSecondary,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                                Text('Attendance Sheet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                Text('Green = Present  Red = Absent', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ]),
                              Row(children: [
                                DropdownButton<String>(
                                  value: _selectedSubject,
                                  items: _subjects.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13)))).toList(),
                                  onChanged: (v) => setState(() => _selectedSubject = v ?? _selectedSubject),
                                ),
                                const SizedBox(width: 8),
                                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                                Text('${monthNames[_currentMonth.month]} ${_currentMonth.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance saved!'), behavior: SnackBarBehavior.floating)),
                                  icon: const Icon(Icons.save),
                                  label: const Text('Save'),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(children: [
                            _headerRow(monthNames),
                            for (var i = 0; i < _students.length; i++)
                              _dataRow(i),
                          ]),
                        ),
                        Container(
                          color: AppColors.bgSecondary,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                _legend(Colors.green, 'Present'),
                                const SizedBox(width: 16),
                                _legend(Colors.red, 'Absent'),
                                const SizedBox(width: 16),
                                _legend(AppColors.bgTertiary, 'Not Marked'),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _statCards(),
                ],
              ),
            ),
    );
  }

  Widget _headerRow(List<String> monthNames) {
    return Container(
      color: AppColors.textPrimary,
      child: Row(children: [
        _thCell('Roll No', 140),
        _thCell('Name', 140),
        for (int d = 1; d <= _daysInMonth; d++)
          _thCell('$d', 42),
        _thCell('Total', 60),
        _thCell('Present', 70),
        _thCell('%', 50),
      ]),
    );
  }

  Widget _thCell(String t, double w) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white24))),
      child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }

  Widget _dataRow(int idx) {
    final (roll, name) = _students[idx];
    final total = _studentTotalCount(roll);
    final present = _studentPresentCount(roll);
    final pct = total > 0 ? ((present / total) * 100).round() : 0;

    return Container(
      color: idx.isEven ? Colors.white : AppColors.bgSecondary,
      child: Row(children: [
        _tdCell(roll, 140, bold: true),
        _tdCell(name, 140),
        for (int d = 1; d <= _daysInMonth; d++)
          _attCell(roll, d),
        _tdCell('$total', 60),
        _tdCell('$present', 60, color: AppColors.success),
        _tdCell('$pct%', 50, bold: true, color: pct >= 75 ? AppColors.success : pct >= 60 ? AppColors.warning : AppColors.danger),
      ]),
    );
  }

  Widget _tdCell(String t, double w, {bool bold = false, Color? color}) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      alignment: Alignment.center,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.bgTertiary))),
      child: Text(t, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500, fontSize: 12, color: color ?? AppColors.textPrimary)),
    );
  }

  Widget _attCell(String roll, int day) {
    final key = _cellKey(roll, day);
    final status = _attendance[key];
    final bg = status == 'present' ? AppColors.success : status == 'absent' ? AppColors.danger : AppColors.bgTertiary;
    final fg = status == null ? AppColors.textSecondary : Colors.white;
    final label = status == 'present' ? 'P' : status == 'absent' ? 'A' : '-';

    return GestureDetector(
      onTap: () => _toggleCell(roll, day),
      child: Container(
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, border: Border.all(color: Colors.white24)),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }

  Widget _legend(Color c, String t) {
    return Row(children: [
      Container(width: 16, height: 16, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _statCards() {
    final avgPct = _students.isNotEmpty
        ? _students.fold(0, (sum, s) {
            final t = _studentTotalCount(s.$1);
            final p = _studentPresentCount(s.$1);
            return sum + (t > 0 ? ((p / t) * 100).round() : 0);
          }) ~/ _students.length
        : 0;

    final lowCount = _students.where((s) {
      final t = _studentTotalCount(s.$1);
      final p = _studentPresentCount(s.$1);
      return t > 0 && ((p / t) * 100) < 75;
    }).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth >= 840 ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 24) / 2;
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _statCard('Total Students', '${_students.length}', AppColors.primary, w),
            _statCard('Avg Attendance', '$avgPct%', AppColors.success, w),
            _statCard('Classes This Month', '$_daysInMonth', AppColors.danger, w),
            _statCard('Low Attendance', '$lowCount', AppColors.warning, w),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color, double w) {
    return Container(
      width: w,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}