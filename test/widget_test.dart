import 'package:flutter_test/flutter_test.dart';
import 'package:my_journeys/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyJourneysApp());
    expect(find.text('My Journey'), findsOneWidget);
  });
}
