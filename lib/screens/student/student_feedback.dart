import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/portal_scaffold.dart';

/// Student feedback — mirror of `student/feedback.html`.
class StudentFeedbackScreen extends StatefulWidget {
  const StudentFeedbackScreen({super.key});

  @override
  State<StudentFeedbackScreen> createState() => _StudentFeedbackScreenState();
}

class _StudentFeedbackScreenState extends State<StudentFeedbackScreen> {
  String _userName = 'Student';
  bool _loading = true;
  String? _activeForm;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _userName = user?.fullName ?? 'Student';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PortalScaffold(
      role: 'student',
      title: 'Feedback',
      userName: _userName,
      currentRoute: AppRoutes.studentFeedback,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    heading: 'Feedback & Reviews',
                    padding: const EdgeInsets.all(24),
                    child: const Text(
                      'Help us improve by sharing your valuable feedback',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_activeForm == null) _feedbackTypeGrid(),
                  if (_activeForm == 'course') const _CourseFeedbackForm(),
                  if (_activeForm == 'facility') const _FacilityFeedbackForm(),
                  if (_activeForm == 'general') const _GeneralFeedbackForm(),
                ],
              ),
            ),
    );
  }

  Widget _feedbackTypeGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 720
            ? (constraints.maxWidth - 48) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: width,
              child: _feedbackTypeCard(
                Icons.menu_book,
                'Course Feedback',
                'Rate courses and faculty',
                () => setState(() => _activeForm = 'course'),
              ),
            ),
            SizedBox(
              width: width,
              child: _feedbackTypeCard(
                Icons.business,
                'Facility Feedback',
                'Review campus facilities',
                () => setState(() => _activeForm = 'facility'),
              ),
            ),
            SizedBox(
              width: width,
              child: _feedbackTypeCard(
                Icons.lightbulb_outline,
                'General Feedback',
                'Share suggestions',
                () => setState(() => _activeForm = 'general'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _feedbackTypeCard(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AppCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseFeedbackForm extends StatefulWidget {
  const _CourseFeedbackForm();

  @override
  State<_CourseFeedbackForm> createState() => _CourseFeedbackFormState();
}

class _CourseFeedbackFormState extends State<_CourseFeedbackForm> {
  String _course = '';
  int _facultyRating = 0;
  int _contentRating = 0;
  int _resourcesRating = 0;
  final _likesCtrl = TextEditingController();
  final _improveCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  static const _courses = [
    'Data Structures',
    'Database Management',
    'Web Development',
    'Software Engineering',
    'Computer Networks',
  ];

  @override
  void dispose() {
    _likesCtrl.dispose();
    _improveCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank you!'),
        content: const Text(
            'Your feedback has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      heading: 'Course Feedback',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Select Course *'),
          DropdownButtonFormField<String>(
            initialValue: _course.isEmpty ? null : _course,
            items: [
              for (final c in _courses)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _course = v ?? ''),
            decoration:
                const InputDecoration(hintText: '-- Choose a course --'),
          ),
          const SizedBox(height: 24),
          _starRatingSection(
              'Faculty Teaching Quality *', _facultyRating,
              (v) => setState(() => _facultyRating = v)),
          _starRatingSection(
              'Course Content Quality *', _contentRating,
              (v) => setState(() => _contentRating = v)),
          _starRatingSection(
              'Learning Resources *', _resourcesRating,
              (v) => setState(() => _resourcesRating = v)),
          const SizedBox(height: 16),
          _label('What did you like most?'),
          TextField(
            controller: _likesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share what you enjoyed about this course...',
            ),
          ),
          const SizedBox(height: 16),
          _label('Areas for Improvement'),
          TextField(
            controller: _improveCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Suggestions for improvement...',
            ),
          ),
          const SizedBox(height: 16),
          _label('Additional Comments'),
          TextField(
            controller: _commentsCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Any other feedback...',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starRatingSection(String label, int rating, ValueChanged<int> onRate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => onRate(i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      i <= rating ? Icons.star : Icons.star_border,
                      color: i <= rating ? AppColors.warning : AppColors.textLight,
                      size: 32,
                    ),
                  ),
                ),
              if (rating > 0) ...[
                const SizedBox(width: 12),
                Text(
                  '$rating/5',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _FacilityFeedbackForm extends StatefulWidget {
  const _FacilityFeedbackForm();

  @override
  State<_FacilityFeedbackForm> createState() => _FacilityFeedbackFormState();
}

class _FacilityFeedbackFormState extends State<_FacilityFeedbackForm> {
  String _facility = '';
  int _rating = 0;
  String _cleanliness = '3';
  String _maintenance = '3';
  final _suggestionsCtrl = TextEditingController();

  static const _facilities = [
    'Library',
    'Computer Lab',
    'Cafeteria',
    'Sports Complex',
    'Hostel',
    'Auditorium',
    'Parking',
  ];

  static const _qualityLevels = [
    ('5', 'Excellent'),
    ('4', 'Very Good'),
    ('3', 'Good'),
    ('2', 'Fair'),
    ('1', 'Poor'),
  ];

  @override
  void dispose() {
    _suggestionsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_facility.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a facility')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank you!'),
        content: const Text(
            'Your feedback has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      heading: 'Facility Feedback',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Select Facility *'),
          DropdownButtonFormField<String>(
            initialValue: _facility.isEmpty ? null : _facility,
            items: [
              for (final f in _facilities)
                DropdownMenuItem(value: f, child: Text(f)),
            ],
            onChanged: (v) => setState(() => _facility = v ?? ''),
            decoration:
                const InputDecoration(hintText: '-- Choose a facility --'),
          ),
          const SizedBox(height: 24),
          _starSection('Overall Rating *', _rating,
              (v) => setState(() => _rating = v)),
          const SizedBox(height: 16),
          _label('Cleanliness'),
          DropdownButtonFormField<String>(
            initialValue: _cleanliness,
            items: [
              for (final q in _qualityLevels)
                DropdownMenuItem(value: q.$1, child: Text(q.$2)),
            ],
            onChanged: (v) => setState(() => _cleanliness = v ?? '3'),
          ),
          const SizedBox(height: 16),
          _label('Maintenance'),
          DropdownButtonFormField<String>(
            initialValue: _maintenance,
            items: [
              for (final q in _qualityLevels)
                DropdownMenuItem(value: q.$1, child: Text(q.$2)),
            ],
            onChanged: (v) => setState(() => _maintenance = v ?? '3'),
          ),
          const SizedBox(height: 16),
          _label('Suggestions for Improvement'),
          TextField(
            controller: _suggestionsCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'How can we improve this facility?',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starSection(String label, int rating, ValueChanged<int> onRate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => onRate(i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      i <= rating ? Icons.star : Icons.star_border,
                      color: i <= rating
                          ? AppColors.warning
                          : AppColors.textLight,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _GeneralFeedbackForm extends StatefulWidget {
  const _GeneralFeedbackForm();

  @override
  State<_GeneralFeedbackForm> createState() => _GeneralFeedbackFormState();
}

class _GeneralFeedbackFormState extends State<_GeneralFeedbackForm> {
  String _category = '';
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _anonymous = false;

  static const _categories = [
    'Academic',
    'Administration',
    'Infrastructure',
    'Student Services',
    'Events & Activities',
    'Other',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_category.isEmpty || _subjectCtrl.text.isEmpty || _messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank you!'),
        content: const Text(
            'Your feedback has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      heading: 'General Feedback',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Feedback Category *'),
          DropdownButtonFormField<String>(
            initialValue: _category.isEmpty ? null : _category,
            items: [
              for (final c in _categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v ?? ''),
            decoration:
                const InputDecoration(hintText: '-- Select category --'),
          ),
          const SizedBox(height: 16),
          _label('Subject *'),
          TextField(
            controller: _subjectCtrl,
            decoration: const InputDecoration(
              hintText: 'Brief subject of your feedback',
            ),
          ),
          const SizedBox(height: 16),
          _label('Your Feedback *'),
          TextField(
            controller: _messageCtrl,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText:
                  'Share your thoughts, suggestions, or concerns...',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _anonymous,
                onChanged: (v) => setState(() => _anonymous = v ?? false),
              ),
              const Text('Submit anonymously'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}