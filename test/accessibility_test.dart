import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {MediaQueryData media = const MediaQueryData()}) {
  return MediaQuery(
    data: media,
    child: MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

/// Holds [key] down with [repeats] repeat events, then lets it go.
Future<void> _holdKey(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  int repeats = 3,
}) async {
  await tester.sendKeyDownEvent(key);
  for (var i = 0; i < repeats; i++) {
    await tester.sendKeyRepeatEvent(key);
  }
  await tester.sendKeyUpEvent(key);
  await tester.pumpAndSettle();
}

Finder _ring() => find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.position == DecorationPosition.foreground &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).border != null,
    );

void _useKeyboardHighlights() {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );
}

void main() {
  group('held keys', () {
    for (final key in [
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.numpadEnter,
    ]) {
      testWidgets('holding ${key.debugName} presses a button once',
          (tester) async {
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
        await _holdKey(tester, key);
        expect(presses, 1);
      });
    }

    testWidgets('each separate key press still counts', (tester) async {
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
      await _holdKey(tester, LogicalKeyboardKey.enter);
      await _holdKey(tester, LogicalKeyboardKey.enter, repeats: 0);
      await _holdKey(tester, LogicalKeyboardKey.space);
      expect(presses, 3);
    });

    testWidgets('holding Enter presses a pressable once', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            autofocus: true,
            onTap: () => taps++,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pump();
      await _holdKey(tester, LogicalKeyboardKey.enter);
      expect(taps, 1);
    });

    testWidgets('holding Enter starts one async run', (tester) async {
      var runs = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            autofocus: true,
            onPressedAsync: () async {
              runs++;
              await Future<void>.delayed(const Duration(milliseconds: 100));
            },
            child: const Text('x'),
          ),
        ),
      );
      await tester.pump();
      await _holdKey(tester, LogicalKeyboardKey.enter);
      expect(runs, 1);
    });

    testWidgets('a focused child of a pressable still gets repeats',
        (tester) async {
      var childActivations = 0;
      var cardTaps = 0;
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () => cardTaps++,
            semanticsButton: false,
            child: Actions(
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) => childActivations++,
                ),
              },
              child: const Focus(
                autofocus: true,
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await _holdKey(tester, LogicalKeyboardKey.enter);
      // The key down and all three repeats reach the child's own action.
      expect(childActivations, 4);
      expect(cardTaps, 0);
    });
  });

  group('focus ring', () {
    testWidgets('is thicker on a button in high contrast', (tester) async {
      Future<double> ringWidth({required bool highContrast}) async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              key: ValueKey(highContrast),
              autofocus: true,
              onPressed: () {},
              child: const Text('x'),
            ),
            media: MediaQueryData(highContrast: highContrast),
          ),
        );
        await tester.pump();
        final box = tester.widget<DecoratedBox>(_ring());
        final border = (box.decoration as BoxDecoration).border! as Border;
        return border.top.width;
      }

      _useKeyboardHighlights();
      expect(await ringWidth(highContrast: false), 2);
      expect(await ringWidth(highContrast: true), 3);
    });

    testWidgets('is thicker on a pressable in high contrast', (tester) async {
      _useKeyboardHighlights();
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            autofocus: true,
            onTap: () {},
            child: const SizedBox(width: 100, height: 100),
          ),
          media: const MediaQueryData(highContrast: true),
        ),
      );
      await tester.pump();
      final box = tester.widget<DecoratedBox>(_ring());
      final border = (box.decoration as BoxDecoration).border! as Border;
      expect(border.top.width, 3);
    });
  });

  group('semantics', () {
    testWidgets('icons, text, and a spinner read as one node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const BouncyButton(
            isLoading: true,
            leading: Icon(Icons.lock),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Pay'),
          ),
        ),
      );
      final node = tester.getSemantics(find.text('Pay'));
      final data = node.getSemanticsData();
      expect(data.label, 'Pay');
      expect(data.value, 'Loading');
      // isSemantics, its replacement, does not exist on the minimum Flutter.
      // ignore: deprecated_member_use
      expect(node, containsSemantics(isButton: true));
      expect(node.childrenCount, 0);
      handle.dispose();
    });
  });

  group('large text', () {
    for (final scale in [2.0, 3.0]) {
      for (final size in BouncyButtonSize.values) {
        testWidgets('${size.name} with icons fits at ${scale}x text',
            (tester) async {
          await tester.pumpWidget(
            _app(
              SizedBox(
                width: 320,
                child: BouncyButton(
                  onPressed: () {},
                  style: BouncyButtonStyle.fromSize(size),
                  leading: const Icon(Icons.shopping_cart),
                  trailing: const Icon(Icons.arrow_forward),
                  child: const Text('Add everything to the shopping cart'),
                ),
              ),
              media: MediaQueryData(textScaler: TextScaler.linear(scale)),
            ),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
