class AttendanceRecord {
  final String subject;
  final String date;
  final String status;
  final String markedBy;
  final String timestamp;

  const AttendanceRecord({
    required this.subject,
    required this.date,
    required this.status,
    required this.markedBy,
    required this.timestamp,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      subject: json['subject'] as String? ?? '',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      markedBy: json['markedBy'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'date': date,
      'status': status,
      'markedBy': markedBy,
      'timestamp': timestamp,
    };
  }
}

class AttendanceSummary {
  final int present;
  final int total;

  const AttendanceSummary({required this.present, required this.total});

  double get percentage => total == 0 ? 0 : (present / total) * 100;

  factory AttendanceSummary.fromRecords(List<AttendanceRecord> records) {
    final present = records.where((r) => r.status == 'Present').length;
    return AttendanceSummary(present: present, total: records.length);
  }
}