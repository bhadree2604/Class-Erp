class Grade {
  final String subject;
  final int credits;
  final String grade;
  final double gradePoint;

  const Grade({
    required this.subject,
    required this.credits,
    required this.grade,
    required this.gradePoint,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      subject: json['subject'] as String? ?? '',
      credits: json['credits'] as int? ?? 0,
      grade: json['grade'] as String? ?? '',
      gradePoint: (json['gradePoint'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'credits': credits,
      'grade': grade,
      'gradePoint': gradePoint,
    };
  }
}