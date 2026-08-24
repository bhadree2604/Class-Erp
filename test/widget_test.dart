import 'package:flutter_test/flutter_test.dart';

import 'package:rit_erp/main.dart';

void main() {
  testWidgets('Landing screen shows login elements', (WidgetTester tester) async {
    await tester.pumpWidget(MyClassApp(key: myAppKey));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Please login to continue'), findsOneWidget);
    expect(find.text('Create Student Account'), findsOneWidget);
  });
}