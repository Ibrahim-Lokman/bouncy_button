import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('a controller in a changing tree', () {
    // In a list without keys, a button that changes position gets a new
    // State, which can be built before the old one is removed.
    for (final (name, before, after) in [
      ('later', 0, 2),
      ('earlier', 2, 0),
    ]) {
      testWidgets('follows a button that moves $name in a list',
          (tester) async {
        final controller = BouncyButtonController();
        addTearDown(controller.dispose);
        var presses = 0;
        Widget build(int extras) => _app(
              ListView(
                children: [
                  for (var i = 0; i < extras; i++) Text('Line $i'),
                  BouncyButton(
                    controller: controller,
                    onPressed: () => presses++,
                    child: const Text('Pay'),
                  ),
                ],
              ),
            );

        await tester.pumpWidget(build(before));
        await tester.pumpWidget(build(after));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(controller.isAttached, isTrue);

        await controller.press();
        await tester.pumpAndSettle();
        expect(presses, 1);
      });
    }

    testWidgets('stays attached when the button is moved with a key',
        (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      final key = GlobalKey();
      var presses = 0;
      Widget build({required bool wrapped}) {
        final button = BouncyButton(
          key: key,
          controller: controller,
          onPressed: () => presses++,
          child: const Text('Pay'),
        );
        return _app(
          Center(
            child: wrapped
                ? Padding(padding: EdgeInsets.zero, child: button)
                : button,
          ),
        );
      }

      await tester.pumpWidget(build(wrapped: false));
      await tester.pumpWidget(build(wrapped: true));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(controller.isAttached, isTrue);
      await controller.press();
      await tester.pumpAndSettle();
      expect(presses, 1);
    });

    testWidgets('reports two buttons sharing one controller', (tester) async {
      final controller = BouncyButtonController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              BouncyButton(
                controller: controller,
                onPressed: () {},
                child: const Text('a'),
              ),
              BouncyButton(
                controller: controller,
                onPressed: () {},
                child: const Text('b'),
              ),
            ],
          ),
        ),
      );
      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect(error.toString(), contains('one widget at a time'));
    });
  });
}
