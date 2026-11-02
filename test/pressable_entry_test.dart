// Uses no Material code, to prove the separate library works without it.
import 'package:bouncy_button/pressable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('works in an app with no Material ancestors', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        builder: (context, _) => Center(
          child: BouncyExclusiveScope(
            child: BouncyPressable(
              onTap: () => taps++,
              haptic: BouncyHapticFeedbackType.light,
              child: const Text('x'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('x'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BouncyAsyncBuilder works with no Material ancestors',
      (tester) async {
    var runs = 0;
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        builder: (context, _) => Center(
          child: BouncyAsyncBuilder(
            onPressed: () async => runs++,
            cooldown: const Duration(milliseconds: 300),
            builder: (context, onPressed, status) => GestureDetector(
              onTap: onPressed,
              child: Text(status.name),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('idle'));
    await tester.pump();
    expect(runs, 1);
    await tester.pumpAndSettle();
    expect(find.text('idle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
