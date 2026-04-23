import 'package:flutter_test/flutter_test.dart';
import 'package:telepatient_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TelePatientApp());
    expect(find.byType(TelePatientApp), findsOneWidget);
  });
}
