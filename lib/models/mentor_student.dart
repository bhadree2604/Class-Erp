class MentorStudent {
  final int id;
  final String name;
  final String rollNo;
  final String department;
  final int semester;
  final String addedDate;

  const MentorStudent({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.department,
    required this.semester,
    required this.addedDate,
  });

  factory MentorStudent.fromJson(Map<String, dynamic> json) {
    return MentorStudent(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      rollNo: json['rollNo'] as String? ?? '',
      department: json['department'] as String? ?? '',
      semester: json['semester'] as int? ?? 0,
      addedDate: json['addedDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rollNo': rollNo,
      'department': department,
      'semester': semester,
      'addedDate': addedDate,
    };
  }
}
