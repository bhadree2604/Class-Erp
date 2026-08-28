import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:rit_erp/main.dart';
import 'package:rit_erp/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  testWidgets('Landing screen shows login elements', (WidgetTester tester) async {
    await tester.pumpWidget(MyClassApp(startPage: const LoginScreen(), key: myAppKey));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Please login to continue'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}