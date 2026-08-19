class Certificate {
  final int id;
  final String title;
  final String category;
  final String issuedBy;
  final String date;
  final String description;
  final String? fileData;
  final String? fileName;
  final String uploadedBy;
  final String uploadedAt;
  final String dateIssued;

  const Certificate({
    required this.id,
    required this.title,
    required this.category,
    required this.issuedBy,
    required this.date,
    required this.description,
    this.fileData,
    this.fileName,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.dateIssued,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      issuedBy: json['issuedBy'] as String? ?? '',
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fileData: json['fileData'] as String?,
      fileName: json['fileName'] as String?,
      uploadedBy: json['uploadedBy'] as String? ?? '',
      uploadedAt: json['uploadedAt'] as String? ?? '',
      dateIssued: json['dateIssued'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'issuedBy': issuedBy,
      'date': date,
      'description': description,
      'fileData': fileData,
      'fileName': fileName,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
      'dateIssued': dateIssued,
    };
  }
}