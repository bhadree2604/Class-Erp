import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models/event.dart' as model;
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';
import '../../widgets/status_badge.dart';

/// Student events — mirror of `student/events.html`.
class StudentEventsScreen extends StatefulWidget {
  const StudentEventsScreen({super.key});

  @override
  State<StudentEventsScreen> createState() => _StudentEventsScreenState();
}

class _StudentEventsScreenState extends State<StudentEventsScreen> {
  String _userName = 'Student';
  List<model.Event> _events = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    final events = await DataService.instance.getEvents();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _events = events;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Events',
      userName: _userName,
      currentRoute: AppRoutes.studentEvents,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'College Events',
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'View upcoming and past college events',
                      style: TextStyle(
                        color: AppColorsExtension.of(context).textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    heading: 'All Events',
                    child: _events.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No events available',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColorsExtension.of(context).textSecondary),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final twoCol = constraints.maxWidth >= 720;
                              return Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                children: [
                                  for (final e in _events)
                                    SizedBox(
                                      width: twoCol
                                          ? (constraints.maxWidth - 24) / 2
                                          : constraints.maxWidth,
                                      child: _eventCard(e),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _eventCard(model.Event event) {
    final eventDate = DateTime.tryParse(event.date);
    final isUpcoming =
        eventDate != null && eventDate.isAfter(DateTime.now());

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColorsExtension.of(context).textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: isUpcoming ? 'Upcoming' : 'Past'),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.category, 'Type', event.type),
          _infoRow(Icons.calendar_today, 'Date', _formatDate(event.date)),
          _infoRow(Icons.access_time, 'Time', event.time),
          _infoRow(Icons.location_on, 'Venue', event.venue),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              event.description,
              style: TextStyle(
                color: AppColorsExtension.of(context).textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColorsExtension.of(context).textLight),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColorsExtension.of(context).textPrimary,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColorsExtension.of(context).textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}