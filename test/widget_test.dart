import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rit_erp/main.dart';
import 'package:rit_erp/services/auth_service.dart';
import 'package:rit_erp/screens/login_screen.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Mock Firebase services
  AuthService.authOverride = MockFirebaseAuth();
  AuthService.firestoreOverride = MockFirebaseFirestore();

  testWidgets('Landing screen shows login elements', (WidgetTester tester) async {
    await tester.pumpWidget(MyClassApp(startPage: const LoginScreen(), key: myAppKey));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Please login to continue'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}