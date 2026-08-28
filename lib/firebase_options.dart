import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyAaMNhi0IPvXD8hI8gQsgwaVySHzbP0OcA',
        authDomain: 'class-e4f21.firebaseapp.com',
        projectId: 'class-e4f21',
        storageBucket: 'class-e4f21.firebasestorage.app',
        messagingSenderId: '725416971892',
        appId: '1:725416971892:web:c03da297d31200d2380b21',
        measurementId: 'G-TS2E4KK36J',
      );
    } else {
      // Android/iOS config (existing)
      return const FirebaseOptions(
        apiKey: 'AIzaSyAzlfbadUrnBezrOYmXdxsUZjDj8J8qTGQ',
        authDomain: 'class-e4f21.firebaseapp.com',
        projectId: 'class-e4f21',
        storageBucket: 'class-e4f21.firebasestorage.app',
        messagingSenderId: '725416971892',
        appId: '1:725416971892:android:201d7e0182d0a6d5380b21',
        measurementId: 'G-XXXXXXXXXX',
      );
    }
  }
}
