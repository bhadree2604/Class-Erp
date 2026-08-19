class Event {
  final int id;
  final String title;
  final String type;
  final String description;
  final String date;
  final String time;
  final String venue;
  final String createdBy;
  final String createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
    required this.createdBy,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'date': date,
      'time': time,
      'venue': venue,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}