import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(
  Widget child, {
  ThemeData? theme,
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    theme: theme,
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

BoxDecoration _face(WidgetTester tester) {
  final face = find.descendant(
    of: find.byType(BouncyButton),
    matching: find.byWidgetPredicate(
      (widget) => widget is Container && widget.decoration is BoxDecoration,
    ),
  );
  return tester.widget<Container>(face).decoration! as BoxDecoration;
}

Color _textColor(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text))).style.color!;

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  group('leading and trailing', () {
    testWidgets('sit either side of the label with a gap', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            leading: const Icon(Icons.add, key: Key('lead')),
            trailing: const Icon(Icons.arrow_forward, key: Key('trail')),
            gap: 10,
            child: const Text('x'),
          ),
        ),
      );
      final lead = tester.getRect(find.byKey(const Key('lead')));
      final label = tester.getRect(find.text('x'));
      final trail = tester.getRect(find.byKey(const Key('trail')));
      expect(label.left - lead.right, 10);
      expect(trail.left - label.right, 10);
    });

    testWidgets('swap sides in right-to-left layouts', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            leading: const Icon(Icons.add, key: Key('lead')),
            child: const Text('x'),
          ),
          direction: TextDirection.rtl,
        ),
      );
      expect(
        tester.getRect(find.byKey(const Key('lead'))).left,
        greaterThan(tester.getRect(find.text('x')).right),
      );
    });

    testWidgets('work inside a Row, where width is unbounded', (tester) async {
      await tester.pumpWidget(
        _app(
          Row(
            children: [
              BouncyButton(
                onPressed: () {},
                leading: const Icon(Icons.add),
                child: const Text('x'),
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a long label wraps instead of overflowing', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 200,
            child: BouncyButton(
              onPressed: () {},
              leading: const Icon(Icons.add),
              child: const Text('A very long label that cannot fit'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(BouncyButton)).width, 200);
    });
  });

  group('sizes', () {
    final expected = {
      BouncyButtonSize.small: (48.0, 14.0, 18.0),
      BouncyButtonSize.medium: (54.0, 16.0, 20.0),
      BouncyButtonSize.large: (64.0, 18.0, 24.0),
    };
    expected.forEach((size, values) {
      testWidgets('${size.name} scales height, depth, text, and icons',
          (tester) async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              style: BouncyButtonStyle.fromSize(size),
              leading: const Icon(Icons.add),
              child: const Text('x'),
            ),
          ),
        );
        final height = tester.getSize(find.byType(BouncyButton)).height;
        expect(height, values.$1);
        expect(height, greaterThanOrEqualTo(48), reason: 'tap target');
        expect(
          DefaultTextStyle.of(tester.element(find.text('x'))).style.fontSize,
          values.$2,
        );
        expect(tester.getSize(find.byIcon(Icons.add)).width, values.$3);
      });
    });

    testWidgets('combine with other options through copyWith', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.fromSize(BouncyButtonSize.small)
                .copyWith(backgroundColor: Colors.teal),
            child: const Text('x'),
          ),
        ),
      );
      expect(_face(tester).color, Colors.teal);
      expect(tester.getSize(find.byType(BouncyButton)).height, 48);
    });
  });

  group('fills', () {
    final themes = {
      'light': ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      'dark': ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      'default light': ThemeData(),
      'default dark': ThemeData.dark(),
    };
    final fills = {
      BouncyButtonFill.filled: BouncyButtonStyle.primary,
      BouncyButtonFill.tonal: BouncyButtonStyle.tonal,
      BouncyButtonFill.outlined: BouncyButtonStyle.outlined,
      BouncyButtonFill.ghost: BouncyButtonStyle.ghost,
    };
    themes.forEach((themeName, theme) {
      fills.forEach((fill, style) {
        testWidgets('${fill.name} text is legible, $themeName', (tester) async {
          await tester.pumpWidget(
            _app(
              BouncyButton(
                onPressed: () {},
                style: style,
                child: const Text('x'),
              ),
              theme: theme,
            ),
          );
          final face = _face(tester).color!;
          // A ghost face is clear, so its text sits on the page.
          final background = face.a == 0 ? theme.colorScheme.surface : face;
          expect(
            _contrast(_textColor(tester, 'x'), background),
            greaterThanOrEqualTo(4.5),
          );
        });
      });
    });

    testWidgets('outlined has a border in the accent color', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.outlined.copyWith(
              backgroundColor: Colors.teal.shade800,
            ),
            child: const Text('x'),
          ),
        ),
      );
      final border = _face(tester).border! as Border;
      expect(border.top.color, Colors.teal.shade800);
      expect(_textColor(tester, 'x'), Colors.teal.shade800);
    });

    testWidgets('ghost has no depth, even if given elevation', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.ghost.copyWith(elevation: 10),
            child: const Text('x'),
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton)).height, 48);
    });

    testWidgets('ghost shows a tint while pressed', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.ghost,
            child: const Text('x'),
          ),
        ),
      );
      Color? tint() => (tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(BouncyButton),
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is DecoratedBox &&
                        widget.position == DecorationPosition.foreground,
                  ),
                ),
              )
              .decoration as BoxDecoration)
          .color;
      expect(tint(), isNull);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('x')));
      await tester.pump();
      expect(tint(), isNotNull);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tint(), isNull);
    });

    for (final fill in BouncyButtonFill.values) {
      testWidgets('${fill.name} can be disabled', (tester) async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: null,
              style: BouncyButtonStyle(fill: fill),
              child: const Text('x'),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('shorthand', () {
    testWidgets('simple sets the common values', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.simple(
              color: Colors.teal,
              width: 160,
              height: 50,
              depth: 4,
            ),
            child: const Text('x'),
          ),
        ),
      );
      expect(_face(tester).color, Colors.teal);
      expect(tester.getSize(find.byType(BouncyButton)), const Size(160, 54));
    });

    test('shadow constants match animated_button', () {
      expect(BouncyButtonStyle.shadowLight, 0.12);
      expect(BouncyButtonStyle.shadowDark, 0.3);
      expect(
        const BouncyButtonStyle().shadowDarkness,
        BouncyButtonStyle.shadowDark,
      );
    });

    test('darken and lighten change lightness only', () {
      const color = Color(0xFF3F51B5);
      final base = HSLColor.fromColor(color);
      final dark = HSLColor.fromColor(BouncyButtonColors.darken(color, 0.2));
      final light = HSLColor.fromColor(BouncyButtonColors.lighten(color));
      expect(dark.lightness, closeTo(base.lightness - 0.2, 0.01));
      expect(light.lightness, closeTo(base.lightness + 0.12, 0.01));
      expect(dark.hue, closeTo(base.hue, 1));
    });
  });

  group('BouncyButtonScope', () {
    testWidgets('wins over the Material theme extension', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButtonScope(
            theme: const BouncyButtonTheme(
              primaryStyle: BouncyButtonStyle(backgroundColor: Colors.teal),
            ),
            child: BouncyButton(onPressed: () {}, child: const Text('x')),
          ),
          theme: ThemeData(
            extensions: const [
              BouncyButtonTheme(
                primaryStyle: BouncyButtonStyle(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      );
      expect(_face(tester).color, Colors.teal);
    });

    testWidgets('a style on the button still wins', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButtonScope(
            theme: const BouncyButtonTheme(
              primaryStyle: BouncyButtonStyle(backgroundColor: Colors.teal),
            ),
            child: BouncyButton(
              onPressed: () {},
              style: const BouncyButtonStyle(backgroundColor: Colors.orange),
              child: const Text('x'),
            ),
          ),
        ),
      );
      expect(_face(tester).color, Colors.orange);
    });

    testWidgets('changes rebuild the buttons', (tester) async {
      Widget build(Color color) => _app(
            BouncyButtonScope(
              theme: BouncyButtonTheme(
                primaryStyle: BouncyButtonStyle(backgroundColor: color),
              ),
              child: BouncyButton(onPressed: () {}, child: const Text('x')),
            ),
          );
      await tester.pumpWidget(build(Colors.teal));
      await tester.pumpWidget(build(Colors.purple));
      expect(_face(tester).color, Colors.purple);
    });

    test('themes have value equality', () {
      expect(
        const BouncyButtonTheme(primaryStyle: BouncyButtonStyle(height: 50)),
        const BouncyButtonTheme(primaryStyle: BouncyButtonStyle(height: 50)),
      );
    });
  });
}
