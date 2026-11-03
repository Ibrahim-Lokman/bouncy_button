import 'package:bouncy_button/bouncy_button.dart';
import 'package:bouncy_button/src/debug_checks.dart'
    show debugResetBouncyWarnings, contrastRatio;
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

/// Runs [body] and returns the bouncy_button warnings it printed.
Future<List<String>> _warnings(Future<void> Function() body) async {
  debugResetBouncyWarnings();
  final printed = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && message.startsWith('bouncy_button:')) {
      printed.add(message);
    }
  };
  try {
    await body();
  } finally {
    debugPrint = original;
  }
  return printed;
}

Matcher _oneWarning(String containing) =>
    allOf(hasLength(1), everyElement(contains(containing)));

void main() {
  test('contrastRatio matches WCAG', () {
    expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
    expect(contrastRatio(Colors.white, Colors.white), 1);
    // Material red with white text, a common mistake.
    expect(
      contrastRatio(Colors.white, const Color(0xFFF44336)),
      closeTo(3.68, 0.01),
    );
  });

  group('icon-only label', () {
    testWidgets('warns for an icon with nothing to read', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(BouncyButton(onPressed: () {}, child: const Icon(Icons.share))),
        );
      });
      expect(printed, _oneWarning('BouncyButton.icon(tooltip: ...)'));
    });

    testWidgets('is quiet with a label', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BouncyButton(
                  onPressed: () {},
                  tooltip: 'Share',
                  child: const Icon(Icons.share),
                ),
                BouncyButton(
                  onPressed: () {},
                  child: const Icon(Icons.delete, semanticLabel: 'Delete'),
                ),
                BouncyButton.icon(
                  onPressed: () {},
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, isEmpty);
    });
  });

  group('label in name', () {
    testWidgets('warns when the label leaves out the visible text',
        (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              semanticLabel: 'Store document',
              child: const Text('Save'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, _oneWarning('does not contain "Save"'));
    });

    testWidgets('is quiet when the label contains it', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              semanticLabel: 'Save document',
              child: const Text('Save'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, isEmpty);
    });
  });

  group('nested tappables', () {
    testWidgets('warns for a button inside the content', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close),
              ),
              child: const Text('Filter'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, _oneWarning('contains another widget that handles taps'));
    });

    testWidgets("ignores the button's own ripple", (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              interaction: const BouncyButtonInteraction(enableSplash: true),
              child: const Text('Go'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, isEmpty);
    });

    testWidgets('allows controls inside a pressable', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyPressable(
              onTap: () {},
              semanticsButton: false,
              child: SizedBox(
                width: 200,
                height: 100,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite, semanticLabel: 'Favorite'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, isEmpty);
    });
  });

  group('toggle label', () {
    Widget toggle(bool on, String text) => _app(
          BouncyButton(
            isSelected: on,
            onPressed: () {},
            child: Text(text),
          ),
        );

    testWidgets('warns when the text flips with the state', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(toggle(false, 'Mute'));
        await tester.pumpWidget(toggle(true, 'Unmute'));
        await tester.pump();
      });
      expect(printed, _oneWarning('Keep one text, such as "Mute"'));
    });

    testWidgets('is quiet when the text stays', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(toggle(false, 'Mute'));
        await tester.pumpWidget(toggle(true, 'Mute'));
        await tester.pump();
      });
      expect(printed, isEmpty);
    });
  });

  group('contrast', () {
    testWidgets('warns for hard-to-read text', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              style: const BouncyButtonStyle(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.white,
              ),
              child: const Text('Buy'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, _oneWarning('below the 4.5:1 needed for normal text'));
    });

    testWidgets('allows less contrast for large text', (tester) async {
      Future<List<String>> run(double fontSize) => _warnings(() async {
            await tester.pumpWidget(
              _app(
                BouncyButton(
                  key: ValueKey(fontSize),
                  onPressed: () {},
                  style: BouncyButtonStyle(
                    backgroundColor: const Color(0xFFF44336),
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: fontSize),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            );
            await tester.pump();
          });

      // White on Material red is 3.7:1: too low for normal text only.
      expect(await run(16), _oneWarning('contrast of 3.7:1'));
      expect(await run(24), isEmpty);
    });

    testWidgets('is quiet for every built-in fill, light and dark',
        (tester) async {
      for (final brightness in Brightness.values) {
        final printed = await _warnings(() async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: Scaffold(
                body: Wrap(
                  children: [
                    for (final style in [
                      BouncyButtonStyle.primary,
                      BouncyButtonStyle.tonal,
                      BouncyButtonStyle.outlined,
                      BouncyButtonStyle.ghost,
                      BouncyButtonStyle.glass,
                      BouncyButtonStyle.destructive,
                      BouncyButtonStyle.destructive
                          .copyWith(fill: BouncyButtonFill.tonal),
                    ])
                      BouncyButton(
                        onPressed: () {},
                        style: style,
                        child: const Text('Go'),
                      ),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();
        });
        expect(printed, isEmpty, reason: brightness.name);
      }
    });

    testWidgets('skips disabled buttons', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            const BouncyButton(
              style: BouncyButtonStyle(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.white,
              ),
              child: Text('Buy'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, isEmpty);
    });
  });

  group('tap target', () {
    const tiny = BouncyButtonStyle(
      height: 24,
      width: 30,
      elevation: 0,
      padding: EdgeInsets.zero,
    );

    testWidgets('warns for a small button', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              style: tiny,
              child: const Text('x'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, _oneWarning('Set minTapTarget: 48'));
    });

    testWidgets('is quiet with minTapTarget', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              style: tiny.copyWith(minTapTarget: 48),
              child: const Text('x'),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, isEmpty);
    });

    testWidgets('warns for a small pressable', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyPressable(
              onTap: () {},
              child: const SizedBox(width: 20, height: 20),
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, _oneWarning('Add padding inside it'));
    });

    testWidgets('uses 44 on Apple platforms', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            BouncyPressable(
              onTap: () {},
              child: const SizedBox(width: 46, height: 46),
            ),
          ),
        );
        await tester.pump();
      });
      debugDefaultTargetPlatformOverride = null;
      expect(printed, isEmpty);
    });

    testWidgets('built-in sizes are quiet', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final size in BouncyButtonSize.values)
                  BouncyButton(
                    onPressed: () {},
                    style: BouncyButtonStyle.fromSize(size),
                    child: const Text('Go'),
                  ),
                BouncyButton.primary(
                  onPressed: () {},
                  child: const Text('Go'),
                ),
                BouncyButton.secondary(
                  onPressed: () {},
                  child: const Text('Go'),
                ),
              ],
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, isEmpty);
    });
  });

  group('screen reader labels', () {
    testWidgets('warns for English labels in another language', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) => Localizations.override(
                context: context,
                locale: const Locale('de'),
                child: BouncyButton(
                  onPressedAsync: () async {},
                  child: const Text('Bezahlen'),
                ),
              ),
            ),
          ),
        );
      });
      expect(printed, _oneWarning('"Loading", "Done", "Failed"'));
      expect(printed.single, contains('"de"'));
    });

    testWidgets('is quiet once they are translated', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) => Localizations.override(
                context: context,
                locale: const Locale('de'),
                child: BouncyButton(
                  onPressedAsync: () async {},
                  feedback: const BouncyButtonFeedback(
                    loadingLabel: 'Lädt',
                    successLabel: 'Fertig',
                    errorLabel: 'Fehlgeschlagen',
                  ),
                  child: const Text('Bezahlen'),
                ),
              ),
            ),
          ),
        );
      });
      expect(printed, isEmpty);
    });

    testWidgets('is quiet in English and for plain buttons', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BouncyButton(
                  onPressedAsync: () async {},
                  child: const Text('Pay'),
                ),
                Builder(
                  builder: (context) => Localizations.override(
                    context: context,
                    locale: const Locale('de'),
                    child: BouncyButton(
                      onPressed: () {},
                      child: const Text('Weiter'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
      expect(printed, isEmpty);
    });
  });

  group('switch and repeats', () {
    testWidgets('each warning prints once', (tester) async {
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 5; i++)
                  BouncyButton(
                    onPressed: () {},
                    child: const Icon(Icons.share),
                  ),
              ],
            ),
          ),
        );
        await tester.pump();
      });
      expect(printed, hasLength(1));
    });

    testWidgets('debugBouncyChecksEnabled turns them off', (tester) async {
      debugBouncyChecksEnabled = false;
      final printed = await _warnings(() async {
        await tester.pumpWidget(
          _app(BouncyButton(onPressed: () {}, child: const Icon(Icons.share))),
        );
        await tester.pump();
      });
      debugBouncyChecksEnabled = true;
      expect(printed, isEmpty);
    });
  });
}
