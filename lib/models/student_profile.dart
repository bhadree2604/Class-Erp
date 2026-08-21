import 'certificate.dart';
import 'parent_message.dart';

class StudentProfile {
  final String userId;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String department;
  final String semester;
  final String batch;
  final String section;
  final double cgpa;
  final double gpa;
  final int arrears;
  final int attendance;
  final String? profilePicture;
  final String currentAddress;
  final String permanentAddress;
  final List<String> activities;
  final List<Certificate> certificates;
  final List<ParentMessage> parentReportMessages;

  const StudentProfile({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.department,
    required this.semester,
    required this.batch,
    required this.section,
    required this.cgpa,
    required this.gpa,
    required this.arrears,
    required this.attendance,
    this.profilePicture,
    required this.currentAddress,
    required this.permanentAddress,
    required this.activities,
    required this.certificates,
    required this.parentReportMessages,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      department: json['department'] as String? ?? '',
      semester: json['semester'] as String? ?? '',
      batch: json['batch'] as String? ?? '',
      section: json['section'] as String? ?? '',
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0,
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0,
      arrears: json['arrears'] as int? ?? 0,
      attendance: json['attendance'] as int? ?? 0,
      profilePicture: json['profilePicture'] as String?,
      currentAddress: json['currentAddress'] as String? ?? '',
      permanentAddress: json['permanentAddress'] as String? ?? '',
      activities: (json['activities'] as List?)?.cast<String>() ?? const [],
      certificates: ((json['certificates'] as List?) ?? const [])
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList(),
      parentReportMessages: ((json['parentReportMessages'] as List?) ?? const [])
          .map((e) => ParentMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'semester': semester,
      'batch': batch,
      'section': section,
      'cgpa': cgpa,
      'gpa': gpa,
      'arrears': arrears,
      'attendance': attendance,
      'profilePicture': profilePicture,
      'currentAddress': currentAddress,
      'permanentAddress': permanentAddress,
      'activities': activities,
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'parentReportMessages': parentReportMessages.map((e) => e.toJson()).toList(),
    };
  }

  StudentProfile copyWith({
    String? userId,
    String? fullName,
    String? phone,
    String? email,
    String? currentAddress,
    String? permanentAddress,
    String? profilePicture,
    int? attendance,
    List<String>? activities,
    List<Certificate>? certificates,
    List<ParentMessage>? parentReportMessages,
  }) {
    return StudentProfile(
      userId: userId ?? this.userId,
      username: username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      department: department,
      semester: semester,
      batch: batch,
      section: section,
      cgpa: cgpa,
      gpa: gpa,
      arrears: arrears,
      attendance: attendance ?? this.attendance,
      profilePicture: profilePicture ?? this.profilePicture,
      currentAddress: currentAddress ?? this.currentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      activities: activities ?? this.activities,
      certificates: certificates ?? this.certificates,
      parentReportMessages: parentReportMessages ?? this.parentReportMessages,
    );
  }
}