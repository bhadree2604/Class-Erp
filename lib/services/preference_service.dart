import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rit_erp/services/auth_service.dart';

class PreferenceService {
  PreferenceService._internal();
  static final PreferenceService _instance = PreferenceService._internal();
  static PreferenceService get instance => _instance;
  factory PreferenceService() => _instance;

  FirebaseFirestore get _fs => AuthService.firestoreOverride ?? FirebaseFirestore.instance;
  FirebaseAuth get _authInstance => AuthService.authOverride ?? FirebaseAuth.instance;

  NotificationPreferences _defaults() => NotificationPreferences(
        emailEnabled: true,
        pushEnabled: false,
        newsletter: false,
      );

  Future<DocumentReference?> _getUserDoc() async {
    final user = _authInstance.currentUser;
    if (user == null) return null;
    return _fs.collection('user_preferences').doc(user.uid);
  }

  Future<void> savePreferences(NotificationPreferences prefs) async {
    final doc = await _getUserDoc();
    if (doc != null) {
      try {
        await doc.set(prefs.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
    final prefsSP = await SharedPreferences.getInstance();
    await prefsSP.setBool('notif_emailEnabled', prefs.emailEnabled);
    await prefsSP.setBool('notif_pushEnabled', prefs.pushEnabled);
    await prefsSP.setBool('notif_newsletter', prefs.newsletter);
  }

  Future<NotificationPreferences> getPreferences() async {
    final user = _authInstance.currentUser;
    if (user != null) {
      try {
        final doc =
            await _fs.collection('user_preferences').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final prefs = NotificationPreferences.fromJson(doc.data()!);
          final prefsSP = await SharedPreferences.getInstance();
          await prefsSP.setBool('notif_emailEnabled', prefs.emailEnabled);
          await prefsSP.setBool('notif_pushEnabled', prefs.pushEnabled);
          await prefsSP.setBool('notif_newsletter', prefs.newsletter);
          return prefs;
        }
      } catch (_) {}
    }
    final prefsSP = await SharedPreferences.getInstance();
    return NotificationPreferences(
      emailEnabled: prefsSP.getBool('notif_emailEnabled') ?? true,
      pushEnabled: prefsSP.getBool('notif_pushEnabled') ?? false,
      newsletter: prefsSP.getBool('notif_newsletter') ?? false,
    );
  }

  Future<void> initPreferences() async {
    await getPreferences();
  }

  Stream<NotificationPreferences> preferencesStream() {
    final user = _authInstance.currentUser;
    if (user == null) {
      return Stream.value(_defaults());
    }
    return _fs
        .collection('user_preferences')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return NotificationPreferences.fromJson(doc.data()!);
      }
      return _defaults();
    });
  }
}

class NotificationPreferences {
  final bool emailEnabled;
  final bool pushEnabled;
  final bool newsletter;

  NotificationPreferences({
    required this.emailEnabled,
    required this.pushEnabled,
    required this.newsletter,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      emailEnabled: json['emailEnabled'] ?? true,
      pushEnabled: json['pushEnabled'] ?? false,
      newsletter: json['newsletter'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'newsletter': newsletter,
    };
  }

  NotificationPreferences copyWith({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? newsletter,
  }) {
    return NotificationPreferences(
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      newsletter: newsletter ?? this.newsletter,
    );
  }
}
