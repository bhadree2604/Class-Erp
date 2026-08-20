import 'package:flutter_test/flutter_test.dart';

import 'package:rit_erp/main.dart';

void main() {
  testWidgets('Landing screen shows portal selection', (WidgetTester tester) async {
    await tester.pumpWidget(MyClassApp(key: myAppKey));

    expect(find.text('Ramco Institute of Technology'), findsOneWidget);
    expect(find.text('Student Portal'), findsOneWidget);
    expect(find.text('Mentor Portal'), findsOneWidget);
  });
}
