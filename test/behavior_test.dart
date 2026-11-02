import 'dart:ui' show SemanticsAction;

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(theme: theme, home: Scaffold(body: child));
}

/// The top of the label, which moves with the button face.
double _faceY(WidgetTester tester) => tester.getTopLeft(find.text('x')).dy;

BoxDecoration _faceDecoration(WidgetTester tester) {
  final face = find.descendant(
    of: find.byType(BouncyButton),
    matching: find.byWidgetPredicate(
      (widget) => widget is Container && widget.decoration is BoxDecoration,
    ),
  );
  return tester.widget<Container>(face).decoration! as BoxDecoration;
}

/// Pumps frames and returns how far down the face travelled at its lowest.
Future<double> _maxTravel(WidgetTester tester, double restY) async {
  var travel = 0.0;
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 10));
    final offset = _faceY(tester) - restY;
    if (offset > travel) {
      travel = offset;
    }
  }
  return travel;
}

void main() {
  group('layout', () {
    testWidgets('sizes to its child in a loose parent', (tester) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              BouncyButton(onPressed: () {}, child: const Text('x')),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(BouncyButton)).width, lessThan(200));
      expect(tester.getSize(find.byType(BouncyButton)).height, 68);
    });

    testWidgets('does not throw inside a Row', (tester) async {
      await tester.pumpWidget(
        _app(
          Row(
            children: [
              BouncyButton(onPressed: () {}, child: const Text('x')),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('fills a parent that forces a width', (tester) async {
      await tester.pumpWidget(
        _app(
          Row(
            children: [
              Expanded(
                child: BouncyButton(onPressed: () {}, child: const Text('x')),
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton)).width, 800);
    });

    testWidgets('double.infinity fills the available width', (tester) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              BouncyButton(
                onPressed: () {},
                style: const BouncyButtonStyle(width: double.infinity),
                child: const Text('x'),
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton)).width, 800);
    });

    testWidgets('fills a parent that forces a height', (tester) async {
      await tester.pumpWidget(
        _app(
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: BouncyButton(onPressed: () {}, child: const Text('x')),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(BouncyButton)), const Size(200, 100));
    });

    testWidgets('circle stays square', (tester) async {
      await tester.pumpWidget(
        _app(
          Center(
            child: BouncyButton(
              onPressed: () {},
              style: BouncyButtonStyle.circle.copyWith(width: 56),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton)), const Size(56, 64));
    });

    testWidgets('grows instead of clipping scaled text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3)),
            child: Scaffold(
              body: Column(
                children: [
                  BouncyButton(onPressed: () {}, child: const Text('x')),
                ],
              ),
            ),
          ),
        ),
      );
      final text = tester.renderObject<RenderParagraph>(find.text('x'));
      expect(text.size.height, text.getMaxIntrinsicHeight(800));
      expect(text.didExceedMaxLines, isFalse);
    });
  });

  group('press animation', () {
    testWidgets('a 30ms tap still shows the full press', (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 30));
      await gesture.up();
      expect(await _maxTravel(tester, rest), 8);
      expect(_faceY(tester), rest);
    });

    testWidgets('starts moving within a frame or two of the touch',
        (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(_faceY(tester), greaterThan(rest));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a tap that is delayed by scrolling still shows the press',
        (tester) async {
      await tester.pumpWidget(
        _app(
          ListView(
            children: [
              BouncyButton(onPressed: () {}, child: const Text('x')),
            ],
          ),
        ),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 30));
      await gesture.up();
      expect(await _maxTravel(tester, rest), 8);
      expect(_faceY(tester), rest);
    });

    testWidgets('stays down while held', (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_faceY(tester) - rest, 8);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
    });

    testWidgets('stays down for the whole long press', (tester) async {
      var longPresses = 0;
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            onLongPress: () => longPresses++,
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(longPresses, 1);
      expect(_faceY(tester) - rest, 8);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
      expect(presses, 0);
    });

    testWidgets('a tap with onLongPress set is not cut short', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            onLongPress: () {},
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 30));
      await gesture.up();
      expect(await _maxTravel(tester, rest), 8);
      expect(presses, 1);
    });

    testWidgets('disabling a held button releases it', (tester) async {
      Widget build(bool enabled) => _app(
            BouncyButton(
              onPressed: enabled ? () {} : null,
              child: const Text('x'),
            ),
          );
      await tester.pumpWidget(build(true));
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      await tester.pumpWidget(build(false));
      expect(tester.takeException(), isNull);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_faceY(tester), rest);
    });

    testWidgets('removing a held button does not throw', (tester) async {
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pumpWidget(_app(const SizedBox()));
      expect(tester.takeException(), isNull);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('curve changes apply at runtime', (tester) async {
      Widget build(Curve curve) => _app(
            BouncyButton(
              onPressed: () {},
              animation: BouncyButtonAnimation(
                type: BouncyButtonAnimationType.scale,
                duration: const Duration(seconds: 1),
                curve: curve,
              ),
              child: const Text('x'),
            ),
          );
      await tester.pumpWidget(build(Curves.linear));
      await tester.pumpWidget(build(const Threshold(0.99)));
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final scale = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(BouncyButton),
              matching: find.byType(Transform),
            )
            .first,
      );
      expect(scale.transform.storage[0], 1);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the bouncy preset stays pressed and springs past rest',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            animation: BouncyButtonAnimation.bouncy,
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pumpAndSettle();
      expect(_faceY(tester), greaterThan(rest));
      final scale = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(BouncyButton),
              matching: find.byType(Transform),
            )
            .first,
      );
      expect(scale.transform.storage[0], moreOrLessEquals(0.95));
      await gesture.up();
      var highest = double.infinity;
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        final y = _faceY(tester);
        if (y < highest) {
          highest = y;
        }
      }
      expect(highest, lessThan(rest));
      await tester.pumpAndSettle();
      expect(_faceY(tester), moreOrLessEquals(rest));
    });

    testWidgets('builder is not rebuilt on animation frames', (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            animation: const BouncyButtonAnimation(
              duration: Duration(milliseconds: 200),
            ),
            builder: (context, isPressed) {
              builds++;
              return const SizedBox();
            },
            child: const SizedBox(),
          ),
        ),
      );
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(BouncyButton)));
      await tester.pump();
      builds = 0;
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(builds, 0);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('reduced motion', () {
    testWidgets('skips transforms and animates instantly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: BouncyButton(
                onPressed: () {},
                animation: const BouncyButtonAnimation(
                  type: BouncyButtonAnimationType.rotation,
                  duration: Duration(milliseconds: 300),
                ),
                child: const Text('x'),
              ),
            ),
          ),
        ),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      expect(_faceY(tester) - rest, 8);
      expect(
        find.descendant(
          of: find.byType(BouncyButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Transform &&
                widget.transform.storage[1] != 0, // Rotated.
          ),
        ),
        findsNothing,
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('splash', () {
    testWidgets('keeps press, haptics and a single callback', (tester) async {
      var haptics = 0;
      var presses = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics++;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            interaction: const BouncyButtonInteraction(enableSplash: true),
            child: const Text('x'),
          ),
        ),
      );
      final rest = _faceY(tester);

      final quick = await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 30));
      await quick.up();
      expect(await _maxTravel(tester, rest), 8);
      await tester.pumpAndSettle();
      expect(presses, 1);
      expect(haptics, 1);

      final held = await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));
      await held.up();
      await tester.pumpAndSettle();
      expect(presses, 2);
      expect(haptics, 2);
    });

    testWidgets('the depth strip below the face is still tappable',
        (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          Center(
            child: BouncyButton(
              onPressed: () => presses++,
              interaction: const BouncyButtonInteraction(enableSplash: true),
              child: const Text('x'),
            ),
          ),
        ),
      );
      await tester.tapAt(
        tester.getBottomLeft(find.byType(BouncyButton)) + const Offset(30, -2),
      );
      await tester.pumpAndSettle();
      expect(presses, 1);
    });

    testWidgets('accepts a directional border radius', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(
              borderRadius: BorderRadiusDirectional.all(Radius.circular(8)),
            ),
            interaction: const BouncyButtonInteraction(enableSplash: true),
            child: const Text('x'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('keyboard', () {
    testWidgets('Enter and Space activate the button', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            autofocus: true,
            onPressed: () => presses++,
            child: const Text('x'),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(presses, 2);
    });

    testWidgets('a disabled button cannot take focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: null,
            focusNode: node,
            child: const Text('x'),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });

    testWidgets('shows a ring only with keyboard focus', (tester) async {
      Finder ring() => find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.position == DecorationPosition.foreground &&
                (widget.decoration as BoxDecoration).border != null,
          );
      await tester.pumpWidget(
        _app(
          BouncyButton(
            autofocus: true,
            onPressed: () {},
            child: const Text('x'),
          ),
        ),
      );
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.pump();
      expect(ring(), findsOneWidget);

      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      await tester.pump();
      expect(ring(), findsNothing);
    });
  });

  group('semantics', () {
    testWidgets('is a button without a semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      final data = tester.getSemantics(find.text('x')).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.label, 'x');
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.hasAction(SemanticsAction.scrollLeft), isFalse);
      expect(data.hasAction(SemanticsAction.scrollUp), isFalse);
      handle.dispose();
    });

    testWidgets('the tap action calls onPressed once', (tester) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            child: const Text('x'),
          ),
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('x'));
      await tester.pumpAndSettle();
      expect(presses, 1);
      handle.dispose();
    });

    testWidgets('a semantic label replaces the child label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            semanticLabel: 'Add to cart',
            child: const Icon(Icons.add),
          ),
        ),
      );
      final data =
          tester.getSemantics(find.byType(BouncyButton)).getSemanticsData();
      expect(data.label, 'Add to cart');
      handle.dispose();
    });

    testWidgets('built-in styles meet the 48px tap target', (tester) async {
      final handle = tester.ensureSemantics();
      for (final style in [
        BouncyButtonStyle.primary,
        BouncyButtonStyle.secondary,
        BouncyButtonStyle.flat,
        BouncyButtonStyle.pill,
        BouncyButtonStyle.circle,
      ]) {
        await tester.pumpWidget(
          _app(
            Center(
              child: BouncyButton(
                onPressed: () {},
                style: style,
                semanticLabel: 'x',
                child: const SizedBox(width: 100),
              ),
            ),
          ),
        );
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      }
      handle.dispose();
    });
  });

  group('theme', () {
    const red = Color(0xFFFF0000);
    const green = Color(0xFF00FF00);
    final theme = ThemeData(
      extensions: const [
        BouncyButtonTheme(
          primaryStyle: BouncyButtonStyle(backgroundColor: red),
          secondaryStyle: BouncyButtonStyle(backgroundColor: green),
          defaultAnimation:
              BouncyButtonAnimation(duration: Duration(milliseconds: 400)),
        ),
      ],
    );

    testWidgets('styles come from the theme', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(onPressed: () {}, child: const Text('x')),
          theme: theme,
        ),
      );
      expect(_faceDecoration(tester).color, red);

      await tester.pumpWidget(
        _app(
          BouncyButton.secondary(onPressed: () {}, child: const Text('x')),
          theme: theme,
        ),
      );
      expect(_faceDecoration(tester).color, green);
    });

    testWidgets('an explicit style beats the theme', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton.primary(
            onPressed: () {},
            style: const BouncyButtonStyle(backgroundColor: green),
            child: const Text('x'),
          ),
          theme: theme,
        ),
      );
      expect(_faceDecoration(tester).color, green);
    });

    testWidgets('default animation comes from the theme', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(onPressed: () {}, child: const Text('x')),
          theme: theme,
        ),
      );
      final rest = _faceY(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final midway = _faceY(tester) - rest;
      expect(midway, greaterThan(0));
      expect(midway, lessThan(8));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('named constructors keep their defaults without a theme',
        (tester) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              BouncyButton.primary(onPressed: () {}, child: const Text('a')),
              BouncyButton.secondary(onPressed: () {}, child: const Text('b')),
              BouncyButton.tertiary(onPressed: () {}, child: const Text('c')),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton).at(0)).height, 64);
      expect(tester.getSize(find.byType(BouncyButton).at(1)).height, 54);
      expect(tester.getSize(find.byType(BouncyButton).at(2)).height, 48);
    });
  });

  group('colors', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return ((x > y ? x : y) + 0.05) / ((x > y ? y : x) + 0.05);
    }

    for (final brightness in Brightness.values) {
      testWidgets('defaults are legible in $brightness', (tester) async {
        final theme = ThemeData(
          colorSchemeSeed: Colors.blue,
          brightness: brightness,
        );
        await tester.pumpWidget(
          _app(
            BouncyButton(onPressed: () {}, child: const Text('x')),
            theme: theme,
          ),
        );
        await tester.pumpAndSettle();
        final face = _faceDecoration(tester).color!;
        final text =
            DefaultTextStyle.of(tester.element(find.text('x'))).style.color!;
        expect(face, theme.colorScheme.primary);
        expect(contrast(face, theme.scaffoldBackgroundColor), greaterThan(3));
        expect(contrast(text, face), greaterThan(4.5));
      });
    }

    testWidgets('the default depth color is not neon in a dark theme',
        (tester) async {
      final theme = ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      );
      await tester.pumpWidget(
        _app(
          BouncyButton(onPressed: () {}, child: const Text('x')),
          theme: theme,
        ),
      );
      await tester.pumpAndSettle();
      final depth = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(DecoratedBox),
        ),
      );
      final color = (depth.decoration as BoxDecoration).color!;
      expect(
        HSLColor.fromColor(color).saturation,
        lessThanOrEqualTo(
          HSLColor.fromColor(theme.colorScheme.primary).saturation,
        ),
      );
      expect(
        color.computeLuminance(),
        lessThan(theme.colorScheme.primary.computeLuminance()),
      );
    });

    testWidgets('foreground contrasts with a custom background',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(backgroundColor: Color(0xFF111111)),
            child: const Text('x'),
          ),
        ),
      );
      final text =
          DefaultTextStyle.of(tester.element(find.text('x'))).style.color;
      expect(text, Colors.white);
    });

    testWidgets('a color on the child wins over the foreground',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: const BouncyButtonStyle(foregroundColor: Colors.white),
            child: const Text('x', style: TextStyle(color: Colors.pink)),
          ),
        ),
      );
      final text = tester.renderObject<RenderParagraph>(find.text('x'));
      expect(text.text.style?.color, Colors.pink);
    });

    testWidgets('a disabled gradient stays opaque', (tester) async {
      const blue = Color(0xFF2196F3);
      await tester.pumpWidget(
        _app(
          const BouncyButton(
            onPressed: null,
            style: BouncyButtonStyle(
              gradient: LinearGradient(colors: [blue, blue]),
            ),
            child: Text('x'),
          ),
        ),
      );
      final gradient = _faceDecoration(tester).gradient!;
      expect(gradient.colors.first.a, 1);
      expect(gradient.colors.first, isNot(blue));
    });

    testWidgets('hslColor paints the face', (tester) async {
      final hsl = HSLColor.fromColor(const Color(0xFF2196F3));
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle(hslColor: hsl),
            child: const Text('x'),
          ),
        ),
      );
      expect(_faceDecoration(tester).color, hsl.toColor());
    });
  });

  group('config equality', () {
    test('equal styles compare equal', () {
      const a = BouncyButtonStyle(height: 50, shadows: [BoxShadow()]);
      const b = BouncyButtonStyle(height: 50, shadows: [BoxShadow()]);
      expect(identical(a, b), isTrue);
      final c = BouncyButtonStyle.primary.copyWith(height: 50);
      final d = BouncyButtonStyle.primary.copyWith(height: 50);
      expect(c, d);
      expect(c.hashCode, d.hashCode);
      expect(c, isNot(BouncyButtonStyle.primary));
    });

    test('equal animations and interactions compare equal', () {
      expect(
        BouncyButtonAnimation.quick.copyWith(scaleAmount: 0.8),
        BouncyButtonAnimation.quick.copyWith(scaleAmount: 0.8),
      );
      expect(
        const BouncyButtonInteraction().copyWith(enableSplash: true),
        const BouncyButtonInteraction().copyWith(enableSplash: true),
      );
    });

    test('scaleLightness darkens rather than fades', () {
      const blue = Color(0xFF2196F3);
      const gradient = LinearGradient(colors: [blue]);
      final scaled = gradient.scaleLightness(0.6);
      expect(scaled.colors.first.a, 1);
      expect(
        scaled.colors.first.computeLuminance(),
        lessThan(blue.computeLuminance()),
      );
    });
  });
}
