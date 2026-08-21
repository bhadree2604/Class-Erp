class Meeting {
  final int id;
  final String studentRollNo;
  final String studentName;
  final String topic;
  final String agenda;
  final String date;
  final String time;
  final String status;
  final String notes;
  final String createdBy;
  final String createdAt;
  final String updatedAt;

  const Meeting({
    required this.id,
    required this.studentRollNo,
    required this.studentName,
    required this.topic,
    required this.agenda,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Meeting copyWith({
    int? id,
    String? studentRollNo,
    String? studentName,
    String? topic,
    String? agenda,
    String? date,
    String? time,
    String? status,
    String? notes,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return Meeting(
      id: id ?? this.id,
      studentRollNo: studentRollNo ?? this.studentRollNo,
      studentName: studentName ?? this.studentName,
      topic: topic ?? this.topic,
      agenda: agenda ?? this.agenda,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as int? ?? 0,
      studentRollNo: json['studentRollNo'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      agenda: json['agenda'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? 'Scheduled',
      notes: json['notes'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentRollNo': studentRollNo,
      'studentName': studentName,
      'topic': topic,
      'agenda': agenda,
      'date': date,
      'time': time,
      'status': status,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
