import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/meeting.dart';
import '../../models/mentor_student.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorMeetingsScreen extends StatefulWidget {
  const MentorMeetingsScreen({super.key});

  @override
  State<MentorMeetingsScreen> createState() => _MentorMeetingsScreenState();
}

class _MentorMeetingsScreenState extends State<MentorMeetingsScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  List<Meeting> _meetings = [];
  List<MentorStudent> _students = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final students = await DataService.instance.getMentorStudents();
    final meetings = await DataService.instance.getMeetings();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _students = students;
      _meetings = meetings;
      _loading = false;
    });
  }

  List<Meeting> get _upcoming => _meetings.where((m) => m.status != 'Completed' && m.status != 'Cancelled').toList();
  List<Meeting> get _past => _meetings.where((m) => m.status == 'Completed' || m.status == 'Cancelled').toList();

  Future<void> _showMeetingForm({Meeting? existing}) async {
    final isEdit = existing != null;
    String? selectedRollNo = existing?.studentRollNo;
    String? selectedName = existing?.studentName;
    final topicCtrl = TextEditingController(text: existing?.topic ?? '');
    final agendaCtrl = TextEditingController(text: existing?.agenda ?? '');
    final dateCtrl = TextEditingController(text: existing?.date ?? '');
    final timeCtrl = TextEditingController(text: existing?.time ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Meeting' : 'Schedule Meeting',
              style: TextStyle(color: AppColorsExtension.of(context).textPrimary)),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Select Student *'),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRollNo,
                    hint: const Text('-- Select Student --'),
                    items: _students.map((s) => DropdownMenuItem(
                      value: s.rollNo,
                      child: Text('${s.name} (${s.rollNo})'),
                    )).toList(),
                    onChanged: (v) {
                      final student = _students.firstWhere((s) => s.rollNo == v);
                      setDialogState(() {
                        selectedRollNo = v;
                        selectedName = student.name;
                      });
                    },
                    decoration: const InputDecoration(hintText: '-- Select Student --'),
                  ),
                  const SizedBox(height: 12),
                  _label('Topic *'),
                  TextField(controller: topicCtrl, decoration: const InputDecoration(hintText: 'e.g., Academic Progress Review')),
                  const SizedBox(height: 12),
                  _label('Agenda'),
                  TextField(controller: agendaCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Brief agenda for the meeting...')),
                  const SizedBox(height: 12),
                  _label('Date *'),
                  TextField(controller: dateCtrl, decoration: const InputDecoration(hintText: 'YYYY-MM-DD')),
                  const SizedBox(height: 12),
                  _label('Time *'),
                  TextField(controller: timeCtrl, decoration: const InputDecoration(hintText: 'HH:MM (e.g., 10:30)')),
                  const SizedBox(height: 12),
                  _label('Notes'),
                  TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Additional notes...')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selectedRollNo == null || topicCtrl.text.isEmpty || dateCtrl.text.isEmpty || timeCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please fill in all required fields'),
                    behavior: SnackBarBehavior.floating,
                  ));
                  return;
                }
                Navigator.pop(context, true);
              },
              child: Text(isEdit ? 'Save Changes' : 'Schedule Meeting'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedRollNo != null) {
      final now = DateTime.now().toIso8601String();
      if (isEdit) {
        final updated = existing.copyWith(
          studentRollNo: selectedRollNo!,
          studentName: selectedName ?? '',
          topic: topicCtrl.text.trim(),
          agenda: agendaCtrl.text.trim(),
          date: dateCtrl.text.trim(),
          time: timeCtrl.text.trim(),
          notes: notesCtrl.text.trim(),
          updatedAt: now,
        );
        await DataService.instance.updateMeeting(updated);
      } else {
        final meeting = Meeting(
          id: DateTime.now().millisecondsSinceEpoch,
          studentRollNo: selectedRollNo!,
          studentName: selectedName ?? '',
          topic: topicCtrl.text.trim(),
          agenda: agendaCtrl.text.trim(),
          date: dateCtrl.text.trim(),
          time: timeCtrl.text.trim(),
          status: 'Scheduled',
          notes: notesCtrl.text.trim(),
          createdBy: _userName,
          createdAt: now,
          updatedAt: now,
        );
        await DataService.instance.addMeeting(meeting);
      }
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Meeting updated successfully!' : 'Meeting scheduled successfully!'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _deleteMeeting(Meeting meeting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: Text('Are you sure you want to delete the meeting "${meeting.topic}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DataService.instance.deleteMeeting(meeting.id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Meeting deleted'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Meetings',
      userName: _userName,
      currentRoute: AppRoutes.mentorMeetings,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Student Meetings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                            const SizedBox(height: 4),
                            Text('Schedule and manage one-on-one meetings with students', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showMeetingForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Schedule Meeting'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Upcoming Meetings',
                    padding: const EdgeInsets.all(24),
                    child: _upcoming.isEmpty
                        ? Text('No upcoming meetings', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                        : Column(
                            children: [
                              for (final m in _upcoming) ...[
                                _meetingCard(m),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'Past Meetings',
                    padding: const EdgeInsets.all(24),
                    child: _past.isEmpty
                        ? Text('No past meetings', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                        : Column(
                            children: [
                              for (final m in _past) ...[
                                _meetingCard(m),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _meetingCard(Meeting m) {
    final isCompleted = m.status == 'Completed';
    final statusColor = isCompleted ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsExtension.of(context).bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColorsExtension.of(context).bgTertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.topic, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColorsExtension.of(context).textPrimary)),
                    const SizedBox(height: 4),
                    Text('Student: ${m.studentName} (${m.studentRollNo})', style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(m.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColorsExtension.of(context).textLight),
              const SizedBox(width: 4),
              Text(m.date, style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textSecondary)),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: AppColorsExtension.of(context).textLight),
              const SizedBox(width: 4),
              Text(m.time, style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textSecondary)),
            ],
          ),
          if (m.agenda.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(m.agenda, style: TextStyle(fontSize: 13, color: AppColorsExtension.of(context).textSecondary)),
          ],
          if (m.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Notes: ${m.notes}', style: TextStyle(fontSize: 12, color: AppColorsExtension.of(context).textLight)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showMeetingForm(existing: m),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _deleteMeeting(m),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary)),
  );
}
