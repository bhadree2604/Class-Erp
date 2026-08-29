import 'package:flutter/material.dart';

/// Mirrors the `.status` badges in styles.css (pending / submitted / graded
/// / overdue / absent / present / late) with their gradient + text colors.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    Color start, end, fg;
    if (s == 'graded') {
      start = const Color(0xFF74b9ff);
      end = const Color(0xFF0984e3);
      fg = const Color(0xFF0652dd);
    } else if (s == 'submitted' || s == 'present' || s == 'paid') {
      start = const Color(0xFF55efc4);
      end = const Color(0xFF00b894);
      fg = const Color(0xFF00693e);
    } else if (s == 'overdue' || s == 'absent') {
      start = const Color(0xFFff7675);
      end = const Color(0xFFd63031);
      fg = Colors.white;
    } else {
      // pending / late / upcoming
      start = const Color(0xFFffeaa7);
      end = const Color(0xFFfdcb6e);
      fg = const Color(0xFFd63031);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label(status),
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  static String _label(String s) {
    // Upcoming (events) is rendered with the same style as pending.
    if (s.toLowerCase() == 'upcoming') return 'UPCOMING';
    return s.toUpperCase();
  }
}
