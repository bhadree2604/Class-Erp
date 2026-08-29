class SemesterReport {
  final int semester;
  final String gpa;
  final String percentage;
  final String status;

  const SemesterReport({
    required this.semester,
    required this.gpa,
    required this.percentage,
    required this.status,
  });

  bool get isCompleted => status == 'Completed';

  factory SemesterReport.fromJson(Map<String, dynamic> json) {
    return SemesterReport(
      semester: json['semester'] as int? ?? 0,
      gpa: json['gpa'] as String? ?? '-',
      percentage: json['percentage'] as String? ?? '-',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'gpa': gpa,
      'percentage': percentage,
      'status': status,
    };
  }
}
