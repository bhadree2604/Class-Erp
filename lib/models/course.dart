class Course {
  final String code;
  final String name;
  final int credits;
  final int semester;
  final String type;
  final String? dept;

  const Course({
    required this.code,
    required this.name,
    required this.credits,
    required this.semester,
    required this.type,
    this.dept,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      credits: json['credits'] as int? ?? 0,
      semester: json['semester'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      dept: json['dept'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'credits': credits,
      'semester': semester,
      'type': type,
      if (dept != null) 'dept': dept,
    };
  }
}
