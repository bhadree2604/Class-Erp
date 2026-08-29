class ParentMessage {
  final int id;
  final String category;
  final String message;
  final String addedBy;
  final String date;

  const ParentMessage({
    required this.id,
    required this.category,
    required this.message,
    required this.addedBy,
    required this.date,
  });

  factory ParentMessage.fromJson(Map<String, dynamic> json) {
    return ParentMessage(
      id: json['id'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      message: json['message'] as String? ?? '',
      addedBy: json['addedBy'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'message': message,
      'addedBy': addedBy,
      'date': date,
    };
  }
}
