class MentorProfile {
  final String userId;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String department;
  final String designation;
  final String qualification;
  final String experience;
  final String? profilePicture;

  const MentorProfile({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.department,
    required this.designation,
    required this.qualification,
    required this.experience,
    this.profilePicture,
  });

  factory MentorProfile.fromJson(Map<String, dynamic> json) {
    return MentorProfile(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'department': department,
      'designation': designation,
      'qualification': qualification,
      'experience': experience,
      'profilePicture': profilePicture,
    };
  }

  MentorProfile copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? department,
    String? designation,
    String? qualification,
    String? experience,
    String? profilePicture,
  }) {
    return MentorProfile(
      userId: userId,
      username: username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
