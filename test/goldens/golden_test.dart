// Screenshot tests of every fill in every state.
//
// The images differ slightly between operating systems and Flutter versions,
// so these run only on macOS, with the Flutter version the reference images
// were made with, and are skipped everywhere else, CI included. On that setup
// they run with every `flutter test`. To run only these:
//
//     flutter test --tags golden
//
// After an intended visual change, update the images with:
//
//     flutter test --tags golden --update-goldens
@Tags(['golden'])
library;

import 'dart:io';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Flutter version the reference images were made with. Text and edges
/// render a little differently in other versions, so the tests only run on
/// this one. After upgrading Flutter, update the images and this version.
const String _goldenFlutterVersion = '3.44.9';

/// Why the screenshot tests are skipped here, or null to run them.
final String? _skip = () {
  if (!Platform.isMacOS) {
    return 'The reference images were made on macOS.';
  }
  final version = _flutterVersion();
  if (version != _goldenFlutterVersion) {
    return 'The reference images were made with Flutter '
        '$_goldenFlutterVersion, not $version.';
  }
  return null;
}();

/// The running Flutter version, from the SDK's version file.
String? _flutterVersion() {
  final root = Platform.environment['FLUTTER_ROOT'];
  final file = File('$root/bin/cache/flutter.version.json');
  if (root == null || !file.existsSync()) {
    return null;
  }
  final match = RegExp(r'"frameworkVersion":\s*"([^"]+)"')
      .firstMatch(file.readAsStringSync());
  return match?.group(1);
}

/// Loads Roboto and the Material icons from the Flutter SDK, so the images
/// show real text and icons instead of the test font's boxes.
Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    return;
  }
  final folder = '$root/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      final font = File('$folder/$file');
      if (font.existsSync()) {
        loader.addFont(
          font.readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
        );
      }
    }
    await loader.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

/// Passes images that differ in fewer than [tolerance] of their pixels, so
/// that small anti-aliasing differences between Flutter versions don't fail.
class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const double tolerance = 0.005;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

const Map<String, BouncyButtonStyle> _fills = {
  'filled': BouncyButtonStyle(),
  'tonal': BouncyButtonStyle(fill: BouncyButtonFill.tonal),
  'outlined': BouncyButtonStyle(fill: BouncyButtonFill.outlined),
  'ghost': BouncyButtonStyle(fill: BouncyButtonFill.ghost),
  'glass': BouncyButtonStyle(fill: BouncyButtonFill.glass),
  'destructive': BouncyButtonStyle(tone: BouncyButtonTone.destructive),
  'destructive tonal': BouncyButtonStyle(
    tone: BouncyButtonTone.destructive,
    fill: BouncyButtonFill.tonal,
  ),
  'destructive outlined': BouncyButtonStyle(
    tone: BouncyButtonTone.destructive,
    fill: BouncyButtonFill.outlined,
  ),
};

/// A fill at the medium size, so every cell lines up.
BouncyButtonStyle _styleFor(BouncyButtonStyle fill) =>
    BouncyButtonStyle.fromSize(BouncyButtonSize.medium).copyWith(
      fill: fill.fill,
      tone: fill.tone,
      width: 120,
    );

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _page(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: brightness),
    home: Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          body: DecoratedBox(
            // A pattern behind the buttons, so glass has something to blur.
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.surface,
                  scheme.surfaceContainerHighest,
                  scheme.surface,
                ],
              ),
            ),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        );
      },
    ),
  );
}

Widget _label(String text) => SizedBox(
      width: 150,
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );

void main() {
  final previous = goldenFileComparator;
  if (previous is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(
      previous.basedir.resolve('golden_test.dart'),
    );
  }
  if (_skip != null) {
    // testWidgets can't show a skip reason, so it is printed instead.
    debugPrint('Skipping the screenshot tests: $_skip');
  }
  setUpAll(_loadFonts);
  setUp(() => debugBouncyChecksEnabled = false);
  tearDown(() => debugBouncyChecksEnabled = true);

  for (final brightness in Brightness.values) {
    testWidgets(
      'every fill in every state, ${brightness.name}',
      (tester) async {
        await _setSize(tester, const Size(940, 720));
        final controllers = <BouncyButtonController>[];
        BouncyButtonController controller() {
          final created = BouncyButtonController();
          addTearDown(created.dispose);
          controllers.add(created);
          return created;
        }

        // Results stay on screen for the whole test.
        const feedback =
            BouncyButtonFeedback(resultDuration: Duration(hours: 1));
        await tester.pumpWidget(
          _page(
            brightness: brightness,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _label(''),
                    for (final state in [
                      'rest',
                      'disabled',
                      'loading',
                      'success',
                      'error',
                    ])
                      _label(state),
                  ],
                ),
                for (final MapEntry(key: name, value: fill) in _fills.entries)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        _label(name),
                        for (final cell in [
                          BouncyButton(
                            onPressed: () {},
                            style: _styleFor(fill),
                            child: const Text('Pay'),
                          ),
                          BouncyButton(
                            style: _styleFor(fill),
                            child: const Text('Pay'),
                          ),
                          BouncyButton(
                            isLoading: true,
                            onPressed: () {},
                            style: _styleFor(fill),
                            child: const Text('Pay'),
                          ),
                          BouncyButton(
                            controller: controller(),
                            onPressedAsync: () async {},
                            feedback: feedback,
                            style: _styleFor(fill),
                            child: const Text('Pay'),
                          ),
                          BouncyButton(
                            controller: controller(),
                            onPressedAsync: () async => throw StateError('x'),
                            onError: (_, __) {},
                            feedback: feedback,
                            style: _styleFor(fill),
                            child: const Text('Pay'),
                          ),
                        ])
                          SizedBox(width: 150, child: Center(child: cell)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
        for (final each in controllers) {
          each.press();
        }
        await tester.pump(const Duration(seconds: 1));
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('images/states_${brightness.name}.png'),
        );
      },
      skip: _skip != null,
    );
  }

  testWidgets(
    'every fill pressed',
    (tester) async {
      await _setSize(tester, const Size(500, 330));
      await tester.pumpWidget(
        _page(
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final MapEntry(key: name, value: fill) in _fills.entries)
                BouncyButton(
                  key: ValueKey(name),
                  onPressed: () {},
                  style: _styleFor(fill),
                  child: const Text('Pay'),
                ),
            ],
          ),
        ),
      );
      final gestures = <TestGesture>[];
      for (final name in _fills.keys) {
        gestures.add(
          await tester.startGesture(
            tester.getCenter(find.byKey(ValueKey(name))),
            pointer: gestures.length + 1,
          ),
        );
      }
      // The press starts once the tap timeout passes, then animates down.
      await tester.pump(kPressTimeout);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('images/pressed.png'),
      );
      for (final gesture in gestures) {
        await gesture.up();
      }
      await tester.pumpAndSettle();
    },
    skip: _skip != null,
  );

  for (final (hovered, focused) in [
    ('filled', 'tonal'),
    ('ghost', 'outlined'),
  ]) {
    testWidgets(
      '$hovered hovered and $focused focused',
      (tester) async {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.alwaysTraditional;
        addTearDown(
          () => FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.automatic,
        );
        await _setSize(tester, const Size(320, 110));
        final node = FocusNode();
        addTearDown(node.dispose);
        await tester.pumpWidget(
          _page(
            Row(
              children: [
                BouncyButton(
                  key: const ValueKey('hovered'),
                  onPressed: () {},
                  style: _styleFor(_fills[hovered]!),
                  child: const Text('Hover'),
                ),
                const SizedBox(width: 24),
                BouncyButton(
                  focusNode: node,
                  onPressed: () {},
                  style: _styleFor(_fills[focused]!),
                  child: const Text('Focus'),
                ),
              ],
            ),
          ),
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(
          location: tester.getCenter(find.byKey(const ValueKey('hovered'))),
        );
        node.requestFocus();
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('images/hover_focus_$hovered.png'),
        );
      },
      skip: _skip != null,
    );
  }

  testWidgets(
    'long text, large text, right to left, and extras',
    (tester) async {
      await _setSize(tester, const Size(520, 640));
      await tester.pumpWidget(
        _page(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 240,
                child: BouncyButton(
                  onPressed: () {},
                  leading: const Icon(Icons.shopping_cart),
                  child: const Text('Add everything to the shopping cart now'),
                ),
              ),
              const SizedBox(height: 16),
              MediaQuery.withClampedTextScaling(
                minScaleFactor: 2,
                maxScaleFactor: 2,
                child: BouncyButton(
                  onPressed: () {},
                  style: BouncyButtonStyle.fromSize(BouncyButtonSize.small),
                  child: const Text('Twice as big'),
                ),
              ),
              const SizedBox(height: 16),
              Directionality(
                textDirection: TextDirection.rtl,
                child: BouncyButton(
                  onPressed: () {},
                  leading: const Icon(Icons.arrow_back),
                  trailing: const Icon(Icons.arrow_forward),
                  child: const Text('Next'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  BouncyButton.icon(
                    onPressed: () {},
                    tooltip: 'Share',
                    icon: const Icon(Icons.share),
                  ),
                  const SizedBox(width: 16),
                  BouncyButton(
                    isSelected: true,
                    onPressed: () {},
                    style: BouncyButtonStyle.fromSize(BouncyButtonSize.medium),
                    child: const Text('Mute'),
                  ),
                  const SizedBox(width: 16),
                  BouncyButton(
                    onPressed: () {},
                    style: BouncyButtonStyle.fromSize(BouncyButtonSize.medium)
                        .copyWith(minWidth: 140),
                    child: const Text('OK'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 360,
                child: BouncyButtonGroup<String>(
                  segments: const [
                    BouncyButtonSegment(value: 'day', label: Text('Day')),
                    BouncyButtonSegment(value: 'week', label: Text('Week')),
                    BouncyButtonSegment(value: 'month', label: Text('Month')),
                  ],
                  selected: const {'week'},
                  showSelectedIcon: true,
                  onSelectionChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('images/layout.png'),
      );
    },
    skip: _skip != null,
  );
}
