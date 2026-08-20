import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

class MentorEventsScreen extends StatefulWidget {
  const MentorEventsScreen({super.key});

  @override
  State<MentorEventsScreen> createState() => _MentorEventsScreenState();
}

class _MentorEventsScreenState extends State<MentorEventsScreen> {
  String _userName = 'Mentor';
  bool _loading = true;
  bool _showForm = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  String _selectedType = 'Academic';
  List<Event> _events = [];

  static const _types = ['Academic', 'Cultural', 'Sports', 'Technical', 'Workshop', 'Seminar', 'Other'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final events = await DataService.instance.getEvents();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Mentor';
      _events = events;
      _loading = false;
    });
  }

  Future<void> _create() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty || _dateCtrl.text.isEmpty || _timeCtrl.text.isEmpty || _venueCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields'), behavior: SnackBarBehavior.floating));
      return;
    }
    final e = Event(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleCtrl.text.trim(),
      type: _selectedType,
      description: _descCtrl.text.trim(),
      date: _dateCtrl.text.trim(),
      time: _timeCtrl.text.trim(),
      venue: _venueCtrl.text.trim(),
      createdBy: 'Mentor',
      createdAt: DateTime.now().toIso8601String(),
    );
    await DataService.instance.addEvent(e);
    _titleCtrl.clear();
    _descCtrl.clear();
    _dateCtrl.clear();
    _timeCtrl.clear();
    _venueCtrl.clear();
    setState(() => _showForm = false);
    _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created successfully!'), behavior: SnackBarBehavior.floating));
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Event?'), content: const Text('Are you sure you want to delete this event?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger)))]));
    if (confirm == true) {
      await DataService.instance.deleteEvent(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'mentor',
      title: 'Event Management',
      userName: _userName,
      currentRoute: AppRoutes.mentorEvents,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Event Management',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create and manage college events', style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(onPressed: () => setState(() => _showForm = !_showForm), icon: Icon(_showForm ? Icons.close : Icons.add), label: Text(_showForm ? 'Cancel' : 'Create New Event')),
                      ],
                    ),
                  ),
                  if (_showForm) ...[
                    const SizedBox(height: 24),
                    AppCard(
                      heading: 'Create New Event',
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Event Title *'),
                          TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'e.g., Tech Fest 2026')),
                          const SizedBox(height: 16),
                          _label('Event Type *'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedType,
                            items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
                          ),
                          const SizedBox(height: 16),
                          _label('Description *'),
                          TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Event details...')),
                          const SizedBox(height: 16),
                          _label('Event Date *'),
                          TextField(controller: _dateCtrl, decoration: const InputDecoration(hintText: 'YYYY-MM-DD')),
                          const SizedBox(height: 16),
                          _label('Event Time *'),
                          TextField(controller: _timeCtrl, decoration: const InputDecoration(hintText: 'HH:MM')),
                          const SizedBox(height: 16),
                          _label('Venue *'),
                          TextField(controller: _venueCtrl, decoration: const InputDecoration(hintText: 'e.g., Main Auditorium')),
                          const SizedBox(height: 24),
                          Row(children: [
                            TextButton(onPressed: () => setState(() => _showForm = false), child: const Text('Cancel')),
                            const SizedBox(width: 12),
                            ElevatedButton(onPressed: _create, child: const Text('Create Event')),
                          ]),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppCard(
                    heading: 'All Events',
                    padding: const EdgeInsets.all(24),
                    child: _events.isEmpty
                        ? Text('No events created yet', style: TextStyle(color: AppColorsExtension.of(context).textSecondary))
                        : Column(
                            children: [
                              for (final e in _events) ...[
                                AppCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(e.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColorsExtension.of(context).textPrimary)),
                                          TextButton(onPressed: () => _delete(e.id), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _info('Type', e.type),
                                      _info('Date', e.date),
                                      _info('Time', e.time),
                                      _info('Venue', e.venue),
                                      const SizedBox(height: 8),
                                      Text(e.description, style: TextStyle(color: AppColorsExtension.of(context).textSecondary)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: AppColorsExtension.of(context).textPrimary, fontSize: 14)));

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(text: TextSpan(style: TextStyle(color: AppColorsExtension.of(context).textSecondary, fontSize: 14), children: [TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)), TextSpan(text: value)])),
    );
  }
}