import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: Center(child: child)),
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

Color _textColor(WidgetTester tester) =>
    DefaultTextStyle.of(tester.element(find.text('x'))).style.color!;

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  group('destructive tone', () {
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
    };
    themes.forEach((name, theme) {
      for (final fill in [
        BouncyButtonFill.filled,
        BouncyButtonFill.tonal,
        BouncyButtonFill.outlined,
        BouncyButtonFill.ghost,
      ]) {
        testWidgets('${fill.name} uses error colors and is legible, $name',
            (tester) async {
          await tester.pumpWidget(
            _app(
              BouncyButton(
                onPressed: () {},
                style: BouncyButtonStyle.destructive.copyWith(fill: fill),
                child: const Text('x'),
              ),
              theme: theme,
            ),
          );
          final scheme = theme.colorScheme;
          final face = _face(tester).color!;
          switch (fill) {
            case BouncyButtonFill.filled:
              expect(face, scheme.error);
              expect(_textColor(tester), scheme.onError);
            case BouncyButtonFill.tonal:
              expect(face, scheme.errorContainer);
              expect(_textColor(tester), scheme.onErrorContainer);
            case BouncyButtonFill.outlined:
              expect(_textColor(tester), scheme.error);
              expect((_face(tester).border! as Border).top.color, scheme.error);
            case BouncyButtonFill.ghost:
              expect(_textColor(tester), scheme.error);
            case BouncyButtonFill.glass:
              break;
          }
          final background = face.a == 0 ? scheme.surface : face;
          expect(
            _contrast(_textColor(tester), background),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    });

    testWidgets('a color set on the style still wins', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.destructive.copyWith(
              backgroundColor: Colors.orange,
            ),
            child: const Text('x'),
          ),
        ),
      );
      expect(_face(tester).color, Colors.orange);
    });

    testWidgets('disabled destructive buttons look disabled', (tester) async {
      await tester.pumpWidget(
        _app(
          const BouncyButton(
            onPressed: null,
            style: BouncyButtonStyle.destructive,
            child: Text('x'),
          ),
        ),
      );
      final scheme = Theme.of(tester.element(find.text('x'))).colorScheme;
      expect(_face(tester).color, isNot(scheme.error));
    });
  });

  group('tooltip', () {
    testWidgets('shows on long press and names the button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            tooltip: 'Add to favorites',
            style: BouncyButtonStyle.circle,
            child: const Icon(Icons.favorite),
          ),
        ),
      );
      final data =
          tester.getSemantics(find.byIcon(Icons.favorite)).getSemanticsData();
      expect(data.tooltip, 'Add to favorites');
      expect(
        find.bySemanticsLabel('Add to favorites'),
        findsNothing,
        reason: 'given once, as the tooltip, not also as a label',
      );

      await tester.longPress(find.byType(BouncyButton));
      await tester.pumpAndSettle();
      expect(find.text('Add to favorites'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('does not stop a long press callback', (tester) async {
      var longPresses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            onLongPress: () => longPresses++,
            tooltip: 'More',
            child: const Text('x'),
          ),
        ),
      );
      await tester.longPress(find.text('x'));
      await tester.pumpAndSettle();
      expect(longPresses, 1);
    });
  });

  group('minimum tap target', () {
    testWidgets('enlarges the tap area without changing the look',
        (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () => presses++,
            style: const BouncyButtonStyle(
              height: 24,
              elevation: 2,
              width: 30,
              padding: EdgeInsets.zero,
              minTapTarget: 48,
            ),
            child: const Text('x'),
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton)), const Size(48, 48));
      expect(_face(tester).color, isNotNull);
      final faceSize = tester.getSize(
        find.descendant(
          of: find.byType(BouncyButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container && widget.decoration is BoxDecoration,
          ),
        ),
      );
      expect(faceSize.width, 30);

      // A tap near the corner, outside the drawn button, still counts.
      final corner =
          tester.getTopLeft(find.byType(BouncyButton)) + const Offset(3, 3);
      await tester.tapAt(corner);
      await tester.pumpAndSettle();
      expect(presses, 1);
    });

    testWidgets('a button already larger keeps its size', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.primary.copyWith(minTapTarget: 48),
            child: const Text('x'),
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton)).height, 64);
    });
  });

  group('renamed APIs', () {
    test('the old haptic type name still works', () {
      // ignore: deprecated_member_use_from_same_package
      const HapticFeedbackType old = HapticFeedbackType.medium;
      expect(old, BouncyHapticFeedbackType.medium);
    });

    test('scaleLightness comes from the new extension', () {
      const gradient = LinearGradient(colors: [Color(0xFF808080), Colors.blue]);
      final darker = gradient.scaleLightness(0.5);
      expect(
        HSLColor.fromColor(darker.colors.first).lightness,
        closeTo(HSLColor.fromColor(gradient.colors.first).lightness / 2, 0.01),
      );
      final viaNewName = BouncyGradientExtension(gradient).scaleLightness(0.5);
      expect(viaNewName.colors, darker.colors);
    });
  });

  test('styles compare the new fields', () {
    expect(
      const BouncyButtonStyle(tone: BouncyButtonTone.destructive),
      isNot(const BouncyButtonStyle()),
    );
    expect(
      const BouncyButtonStyle().copyWith(minTapTarget: 48),
      const BouncyButtonStyle(minTapTarget: 48),
    );
  });
}
