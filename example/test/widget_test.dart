import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bouncy_button_example/main.dart';

void main() {
  testWidgets('demo renders and buttons respond', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(BouncyButton), findsWidgets);

    await tester.tap(find.text('Simple Button'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
