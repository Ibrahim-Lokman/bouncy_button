import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool reduceMotion = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

double _faceY(WidgetTester tester) => tester.getTopLeft(find.text('x')).dy;

BoxDecoration _face(WidgetTester tester) {
  final face = find.descendant(
    of: find.byType(BouncyButton),
    matching: find.byWidgetPredicate(
      (widget) => widget is Container && widget.decoration is BoxDecoration,
    ),
  );
  return tester.widget<Container>(face).decoration! as BoxDecoration;
}

BoxDecoration _slab(WidgetTester tester) {
  final slab = find.descendant(
    of: find.descendant(
      of: find.byType(BouncyButton),
      matching: find.byType(Positioned),
    ),
    matching: find.byType(DecoratedBox),
  );
  return tester.widget<DecoratedBox>(slab.first).decoration as BoxDecoration;
}

Widget _springButton({
  BouncyPressSpring spring = BouncyPressSpring.bouncy,
  FocusNode? focusNode,
}) {
  return BouncyButton(
    onPressed: () {},
    focusNode: focusNode,
    animation: BouncyButtonAnimation(spring: spring),
    child: const Text('x'),
  );
}

void main() {
  group('spring', () {
    testWidgets('holds fully down, then returns to rest', (tester) async {
      await tester.pumpWidget(_app(_springButton()));
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_faceY(tester) - rest, closeTo(8, 0.01));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), closeTo(rest, 0.01));
    });

    testWidgets('a bouncy spring overshoots rest on release', (tester) async {
      await tester.pumpWidget(_app(_springButton()));
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      await gesture.up();
      var highest = double.infinity;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        final y = _faceY(tester);
        if (y < highest) {
          highest = y;
        }
      }
      expect(highest, lessThan(rest));
      await tester.pumpAndSettle();
    });

    testWidgets('the face never goes deeper than its depth', (tester) async {
      await tester.pumpWidget(_app(_springButton()));
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        expect(_faceY(tester) - rest, lessThanOrEqualTo(8.0001));
      }
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a quick tap still shows nearly the whole press',
        (tester) async {
      await tester
          .pumpWidget(_app(_springButton(spring: BouncyPressSpring.gentle)));
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      var deepest = 0.0;
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        final travel = _faceY(tester) - rest;
        if (travel > deepest) {
          deepest = travel;
        }
      }
      expect(deepest, greaterThanOrEqualTo(8 * 0.9 - 0.01));
      await tester.pumpAndSettle();
      expect(_faceY(tester), closeTo(rest, 0.01));
    });

    testWidgets('pressing again mid-release carries the motion smoothly',
        (tester) async {
      await tester
          .pumpWidget(_app(_springButton(spring: BouncyPressSpring.gentle)));
      final center = tester.getCenter(find.text('x'));
      final first = await tester.startGesture(center);
      await tester.pumpAndSettle();
      await first.up();
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final before = _faceY(tester);
      await tester.pump(const Duration(milliseconds: 16));
      final rising = before - _faceY(tester);
      expect(rising, greaterThan(0), reason: 'releasing, so rising');

      final second = await tester.startGesture(center);
      final atPress = _faceY(tester);
      // The first frame only starts the animation's clock.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      // The face is still moving up just after the press, as it keeps its
      // speed. A curve would turn around at once.
      expect(_faceY(tester), lessThan(atPress));

      await tester.pumpAndSettle();
      await second.up();
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion moves at once', (tester) async {
      await tester.pumpWidget(_app(_springButton(), reduceMotion: true));
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      expect(_faceY(tester) - rest, 8);
      await gesture.up();
      await tester.pump();
      expect(_faceY(tester), rest);
    });

    testWidgets('keyboard activation returns to rest', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(_app(_springButton(focusNode: node)));
      final rest = _faceY(tester);
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      var deepest = 0.0;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        final travel = _faceY(tester) - rest;
        if (travel > deepest) {
          deepest = travel;
        }
      }
      expect(deepest, greaterThan(7));
      await tester.pumpAndSettle();
      expect(_faceY(tester), closeTo(rest, 0.01));
    });

    testWidgets('keyboard activation under reduced motion returns to rest',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(_springButton(focusNode: node), reduceMotion: true),
      );
      final rest = _faceY(tester);
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
    });

    testWidgets('switching between spring and curve keeps the position',
        (tester) async {
      Widget build({required bool spring}) => _app(
            BouncyButton(
              onPressed: () {},
              animation: BouncyButtonAnimation(
                spring: spring ? BouncyPressSpring.snappy : null,
              ),
              child: const Text('x'),
            ),
          );
      await tester.pumpWidget(build(spring: true));
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_faceY(tester) - rest, closeTo(8, 0.01));

      await tester.pumpWidget(build(spring: false));
      expect(_faceY(tester) - rest, closeTo(8, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);

      await tester.pumpWidget(build(spring: true));
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(_faceY(tester), closeTo(rest, 0.01));
    });

    testWidgets('works on BouncyPressable', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () {},
            scaleFactor: 0.8,
            spring: BouncyPressSpring.snappy,
            child: const Text('x'),
          ),
        ),
      );
      double scale() => tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(BouncyPressable),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .storage[0];
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(scale(), closeTo(0.8, 0.001));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(scale(), closeTo(1, 0.001));
    });

    test('springs have value equality and reject bad values', () {
      expect(
        const BouncyPressSpring(stiffness: 300),
        const BouncyPressSpring(stiffness: 300),
      );
      expect(
        const BouncyButtonAnimation(spring: BouncyPressSpring.snappy),
        const BouncyButtonAnimation(spring: BouncyPressSpring.snappy),
      );
      expect(
        () => BouncyPressSpring(dampingRatio: -1 + 0.0 * DateTime.now().day),
        throwsAssertionError,
      );
    });
  });

  group('hover lift', () {
    // Hover highlights show in traditional mode, the default on desktop.
    // Tests run as a touch platform, so switch modes explicitly.
    setUp(() {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
    });
    tearDown(() {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
    });

    Future<TestGesture> hover(WidgetTester tester) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      return mouse;
    }

    testWidgets('a mouse raises the face, and leaving lowers it',
        (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final rest = _faceY(tester);
      final mouse = await hover(tester);
      expect(_faceY(tester), rest - 2);

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
      await mouse.removePointer();
    });

    testWidgets('pressing while hovered goes fully down', (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final rest = _faceY(tester);
      final mouse = await hover(tester);
      await mouse.down(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_faceY(tester) - rest, 8);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest - 2);
      await mouse.removePointer();
    });

    testWidgets('a touch does not lift', (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final rest = _faceY(tester);
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
    });

    testWidgets('reduced motion, zero lift, and disabled stay put',
        (tester) async {
      for (final button in [
        _app(
          BouncyButton(onPressed: () {}, child: const Text('x')),
          reduceMotion: true,
        ),
        _app(
          BouncyButton(
            onPressed: () {},
            interaction: const BouncyButtonInteraction(hoverLift: 0),
            child: const Text('x'),
          ),
        ),
        _app(const BouncyButton(onPressed: null, child: Text('x'))),
      ]) {
        await tester.pumpWidget(button);
        final rest = _faceY(tester);
        final mouse = await hover(tester);
        expect(_faceY(tester), rest);
        await mouse.moveTo(Offset.zero);
        await mouse.removePointer();
        await tester.pumpAndSettle();
      }
    });
  });

  group('shape morphing', () {
    const rest = BorderRadius.all(Radius.circular(24));
    const pressed = BorderRadius.all(Radius.circular(6));

    testWidgets('corners change with the press, and back', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(
              borderRadius: rest,
              pressedBorderRadius: pressed,
            ),
            child: const Text('x'),
          ),
        ),
      );
      expect(_face(tester).borderRadius, rest);
      expect(_slab(tester).borderRadius, rest);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_face(tester).borderRadius, pressed);
      expect(_slab(tester).borderRadius, pressed);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_face(tester).borderRadius, rest);
    });

    testWidgets('a circle starts as a circle', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.circle.copyWith(
              pressedBorderRadius: pressed,
            ),
            child: const Text('x'),
          ),
        ),
      );
      expect(_face(tester).borderRadius, BorderRadius.circular(28));
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 35));
      final mid = _face(tester).borderRadius! as BorderRadius;
      expect(mid.topLeft.x, inExclusiveRange(6, 28));
      await tester.pumpAndSettle();
      expect(_face(tester).borderRadius, pressed);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('is ignored with a custom decoration', (tester) async {
      const decoration = BoxDecoration(
        color: Colors.teal,
        borderRadius: rest,
      );
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(
              decoration: decoration,
              pressedBorderRadius: pressed,
            ),
            child: const Text('x'),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_face(tester), decoration);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('does not rebuild the content on animation frames',
        (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(
              borderRadius: rest,
              pressedBorderRadius: pressed,
            ),
            builder: (context, isPressed) {
              builds++;
              return const Text('x');
            },
            child: const SizedBox(),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      final afterPress = builds;
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 8));
      }
      expect(builds, afterPress);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
