import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bouncy_button/bouncy_button.dart';

void main() {
  group('BouncyButton', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyButton(
              onPressed: () {
                pressed = true;
              },
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BouncyButton(
              onPressed: null,
              child: Text('Test Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets('calls onLongPress when long pressed',
        (WidgetTester tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyButton(
              onPressed: () {},
              onLongPress: () {
                longPressed = true;
              },
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('applies custom style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyButton(
              onPressed: () {},
              style: const BouncyButtonStyle(
                height: 100,
                backgroundColor: Colors.red,
              ),
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(BouncyButton),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container, isNotNull);
    });

    testWidgets('semantic label is applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyButton(
              onPressed: () {},
              semanticLabel: 'Test semantic label',
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.text('Test Button'));
      expect(semantics.label, contains('Test semantic label'));
    });
  });

  group('BouncyButtonStyle', () {
    test('copyWith creates new instance with updated values', () {
      const original = BouncyButtonStyle(
        height: 50,
        elevation: 5,
      );

      final copied = original.copyWith(height: 60);

      expect(copied.height, 60);
      expect(copied.elevation, 5);
    });

    test('predefined styles have expected values', () {
      expect(BouncyButtonStyle.primary.height, 56);
      expect(BouncyButtonStyle.secondary.height, 48);
      expect(BouncyButtonStyle.flat.elevation, 2);
      expect(BouncyButtonStyle.circle.shape, BoxShape.circle);
    });
  });

  group('BouncyButtonAnimation', () {
    test('copyWith creates new instance with updated values', () {
      const original = BouncyButtonAnimation(
        duration: Duration(milliseconds: 100),
        type: BouncyButtonAnimationType.scale,
      );

      final copied = original.copyWith(
        duration: const Duration(milliseconds: 200),
      );

      expect(copied.duration, const Duration(milliseconds: 200));
      expect(copied.type, BouncyButtonAnimationType.scale);
    });
  });

  group('BouncyButtonColors', () {
    test('gradientFromColor creates gradient', () {
      final gradient = BouncyButtonColors.gradientFromColor(Colors.blue);

      expect(gradient.colors.length, 3);
      expect(gradient.colors[1], Colors.blue);
    });

    test('complementary color calculation', () {
      final complementary = BouncyButtonColors.complementary(Colors.blue);

      expect(complementary, isNot(Colors.blue));
    });

    test('analogous colors generation', () {
      final analogous = BouncyButtonColors.analogous(Colors.blue, count: 3);

      expect(analogous.length, 3);
    });

    test('triadic colors generation', () {
      final triadic = BouncyButtonColors.triadic(Colors.blue);

      expect(triadic.length, 3);
      expect(triadic[0], Colors.blue);
    });

    test('monochromatic colors generation', () {
      final monochromatic =
          BouncyButtonColors.monochromatic(Colors.blue, count: 5);

      expect(monochromatic.length, 5);
    });
  });
}
