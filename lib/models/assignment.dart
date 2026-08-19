class Assignment {
  final int id;
  final String subject;
  final String title;
  final String description;
  final String dueDate;
  final String maxMarks;
  final String status;
  final String createdBy;
  final String createdAt;

  const Assignment({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxMarks,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as int? ?? 0,
      subject: json['subject'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      maxMarks: json['maxMarks'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'maxMarks': maxMarks,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}