// Records the README's screenshots and GIFs from the Features tab demos.
//
// It is skipped unless RECORD_GIFS=1 is set, so normal test runs and CI never
// run it. Use example/tool/make_gifs.sh, which runs it and turns the frames
// into GIFs.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bouncy_button_example/state/warning_log.dart';
import 'package:bouncy_button_example/tour/feature_demos.dart';
import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final bool _record = Platform.environment['RECORD_GIFS'] == '1';

/// Where the frames go, relative to the example folder.
const String _framesPath = 'build/gif_frames';

/// Frames per second of the recording.
const int _fps = 20;
const Duration _frameTime = Duration(milliseconds: 1000 ~/ _fps);

/// Loads Roboto and the Material icons from the Flutter SDK, so frames show
/// real text and icons instead of the test font's boxes.
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

/// Draws where a finger is down, and the mouse pointer, so a GIF shows what
/// is being pressed.
class _PointerOverlay extends StatefulWidget {
  const _PointerOverlay({
    required this.keyLabel,
    required this.mouse,
    required this.child,
  });

  final ValueNotifier<String?> keyLabel;

  /// Where the mouse pointer is drawn, set by the recorder.
  final ValueNotifier<Offset?> mouse;
  final Widget child;

  @override
  State<_PointerOverlay> createState() => _PointerOverlayState();
}

class _PointerOverlayState extends State<_PointerOverlay> {
  final Map<int, Offset> _touches = {};

  void _update(PointerEvent event) {
    if (event.kind == PointerDeviceKind.mouse) {
      return;
    }
    setState(() {
      if (event is PointerDownEvent || event is PointerMoveEvent) {
        _touches[event.pointer] = event.localPosition;
      } else if (event is PointerUpEvent || event is PointerCancelEvent) {
        _touches.remove(event.pointer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _update,
      onPointerMove: _update,
      onPointerUp: _update,
      onPointerCancel: _update,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<Offset?>(
                valueListenable: widget.mouse,
                builder: (context, mouse, _) => CustomPaint(
                  painter: _PointerPainter(_touches.values.toList(), mouse),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 10,
            end: 10,
            child: ValueListenableBuilder<String?>(
              valueListenable: widget.keyLabel,
              builder: (context, label, _) => label == null
                  ? const SizedBox.shrink()
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xE6212121),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.keyboard,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            // Above the app's theme, so it names its font.
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter(this.touches, this.mouse);

  final List<Offset> touches;
  final Offset? mouse;

  @override
  void paint(Canvas canvas, Size size) {
    for (final touch in touches) {
      canvas
        ..drawCircle(touch, 18, Paint()..color = const Color(0x55000000))
        ..drawCircle(
          touch,
          18,
          Paint()
            ..color = const Color(0xCCFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
    final pointer = mouse;
    if (pointer != null) {
      final arrow = Path()
        ..moveTo(pointer.dx, pointer.dy)
        ..lineTo(pointer.dx, pointer.dy + 18)
        ..lineTo(pointer.dx + 5, pointer.dy + 14)
        ..lineTo(pointer.dx + 9, pointer.dy + 22)
        ..lineTo(pointer.dx + 12, pointer.dy + 21)
        ..lineTo(pointer.dx + 8, pointer.dy + 13)
        ..lineTo(pointer.dx + 14, pointer.dy + 13)
        ..close();
      canvas
        ..drawPath(arrow, Paint()..color = Colors.black)
        ..drawPath(
          arrow,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
    }
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) => true;
}

/// Records one demo: pumps it frame by frame and saves each frame.
class _Recorder {
  _Recorder(this.tester, this.demo);

  final WidgetTester tester;
  final FeatureDemo demo;
  final GlobalKey _boundary = GlobalKey();
  final ValueNotifier<String?> keyLabel = ValueNotifier(null);
  final ValueNotifier<Offset?> mouse = ValueNotifier(null);
  int _frame = 0;

  Directory get _folder => Directory('$_framesPath/${demo.id}');

  Future<void> start() async {
    await tester.runAsync(() async {
      if (_folder.existsSync()) {
        _folder.deleteSync(recursive: true);
      }
      _folder.createSync(recursive: true);
    });
    tester.view.physicalSize = demo.recordSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF3F51B5)),
        builder: (context, child) => RepaintBoundary(
          key: _boundary,
          child: _PointerOverlay(
            keyLabel: keyLabel,
            mouse: mouse,
            child: child!,
          ),
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Builder(builder: demo.builder),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<Uint8List> _png() async {
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  /// Saves the current frame into the GIF.
  Future<void> _capture() async {
    await tester.runAsync(() async {
      final name = (_frame++).toString().padLeft(4, '0');
      await File('${_folder.path}/$name.png').writeAsBytes(await _png());
    });
  }

  /// Removes the GIF frames, for features shown by a screenshot only.
  Future<void> keepScreenshotOnly() async {
    await tester.runAsync(() async {
      for (final file in _folder.listSync().whereType<File>()) {
        if (!file.path.endsWith('poster.png')) {
          file.deleteSync();
        }
      }
    });
  }

  /// Saves the current frame as the screenshot shown next to the GIF.
  Future<void> poster() async {
    await tester.runAsync(() async {
      await File('${_folder.path}/poster.png').writeAsBytes(await _png());
    });
  }

  /// Records [duration] of time passing.
  Future<void> wait(Duration duration) async {
    final frames = (duration.inMilliseconds / _frameTime.inMilliseconds).ceil();
    for (var i = 0; i < frames; i++) {
      await tester.pump(_frameTime);
      await _capture();
    }
  }

  Future<void> hold(
    Finder finder,
    Duration holdFor, {
    Duration after = const Duration(milliseconds: 500),
    bool posterWhileHeld = false,
  }) async {
    final gesture = await tester.startGesture(tester.getCenter(finder));
    await wait(holdFor);
    if (posterWhileHeld) {
      await poster();
    }
    await gesture.up();
    await wait(after);
  }

  Future<void> tap(
    Finder finder, {
    Duration after = const Duration(milliseconds: 500),
  }) =>
      hold(finder, const Duration(milliseconds: 100), after: after);

  /// Taps [count] times, quickly, as an impatient person would.
  Future<void> rapidTaps(Finder finder, int count) async {
    for (var i = 0; i < count; i++) {
      await hold(
        finder,
        const Duration(milliseconds: 50),
        after: const Duration(milliseconds: 50),
      );
    }
  }

  Future<void> pressKey(LogicalKeyboardKey key, String label) async {
    keyLabel.value = label;
    await tester.sendKeyEvent(key);
    await wait(const Duration(milliseconds: 700));
    keyLabel.value = null;
  }

  /// Moves a mouse pointer onto [finder] and leaves it there.
  Future<TestGesture> hover(Finder finder) async {
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    final target = tester.getCenter(finder);
    final from = target + const Offset(-120, 60);
    await pointer.addPointer(location: from);
    for (var i = 1; i <= 8; i++) {
      final position = Offset.lerp(from, target, i / 8)!;
      await pointer.moveTo(position);
      mouse.value = position;
      await wait(_frameTime);
    }
    return pointer;
  }

  /// Takes the mouse pointer away again.
  Future<void> leave(TestGesture pointer) async {
    mouse.value = null;
    await pointer.removePointer();
  }
}

typedef _Script = Future<void> Function(_Recorder recorder);

const Duration _short = Duration(milliseconds: 300);
const Duration _beat = Duration(milliseconds: 600);

final Map<String, _Script> _scripts = {
  '00-hero': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Press me'));
    await r.tap(find.byIcon(Icons.favorite));
    await r.tap(find.text(r'Pay $24.00'), after: _short);
    await r.wait(const Duration(milliseconds: 200));
    await r.poster();
    await r.wait(const Duration(milliseconds: 1600));
    await r.hold(find.text('Studio Headphones'), _short, after: _beat);
  },
  '01-3d-press': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Press me'));
    await r.hold(
      find.text('Deep press'),
      const Duration(milliseconds: 700),
      posterWhileHeld: true,
      after: _beat,
    );
    await r.tap(find.text('Pill'));
    await r.tap(find.byIcon(Icons.favorite), after: _beat);
  },
  '02-loading': (r) async {
    await r.wait(_short);
    await r.tap(find.text(r'Pay $24.00'), after: _short);
    await r.poster();
    await r.wait(const Duration(milliseconds: 1600));
    await r.tap(find.text('Try a failing payment'), after: _beat);
    await r.wait(const Duration(milliseconds: 1600));
  },
  '03-double-taps': (r) async {
    await r.wait(_short);
    for (final label in ['No protection', 'With cooldown', 'Pay (async)']) {
      await r.rapidTaps(find.text(label), 3);
      await r.wait(_short);
    }
    await r.wait(_beat);
    await r.poster();
    await r.wait(_beat);
  },
  '04-any-widget': (r) async {
    await r.wait(_short);
    await r.hold(
      find.text('Studio Headphones'),
      const Duration(milliseconds: 500),
      posterWhileHeld: true,
    );
    await r.tap(find.byIcon(Icons.favorite_border), after: _beat);
    await r.tap(find.text(r'$129.00'), after: _beat);
  },
  '05-motion': (r) async {
    await r.wait(_short);
    for (final label in ['Bouncy', 'Snappy', 'Gentle']) {
      await r.hold(
        find.text(label),
        const Duration(milliseconds: 200),
        after: const Duration(milliseconds: 700),
      );
    }
    await r.hold(
      find.text('Shape morph'),
      const Duration(milliseconds: 500),
      posterWhileHeld: true,
      after: _beat,
    );
    final mouse = await r.hover(find.text('Hover me'));
    await r.wait(_beat);
    await r.leave(mouse);
    await r.wait(_short);
  },
  '06-animations': (r) async {
    await r.wait(_short);
    for (final type in [
      'depth',
      'scale',
      'rotation',
      'bounce',
      'fade',
      'slide'
    ]) {
      await r.hold(
        find.text(type),
        const Duration(milliseconds: 300),
        posterWhileHeld: type == 'scale',
        after: const Duration(milliseconds: 250),
      );
    }
    for (final preset in ['quick', 'smooth', 'springy', 'bouncy']) {
      await r.tap(find.text(preset), after: const Duration(milliseconds: 350));
    }
  },
  '07-styles': (r) async {
    await r.wait(_short);
    await r.poster();
    for (final label in [
      'Pay',
      'Apply',
      'Cancel',
      'Skip',
      'Delete',
      'Remove',
      'small',
      'medium',
      'large',
      'Add to cart',
      'Continue',
    ]) {
      await r.tap(find.text(label), after: const Duration(milliseconds: 200));
    }
    await r.wait(_short);
  },
  '08-timeout-confirm': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Delete account'), after: _beat);
    await r.poster();
    await r.tap(
      find.widgetWithText(TextButton, 'Delete'),
      after: const Duration(milliseconds: 1600),
    );
    await r.tap(
      find.text('Slow request'),
      after: const Duration(milliseconds: 2400),
    );
    await r.wait(_beat);
  },
  '09-any-button': (r) async {
    await r.wait(_short);
    // The labels change once pressed, so find the buttons themselves.
    await r.rapidTaps(find.byType(ElevatedButton), 2);
    await r.wait(_short);
    await r.poster();
    await r.wait(const Duration(milliseconds: 1400));
    await r.rapidTaps(find.byType(CupertinoButton), 2);
    await r.wait(const Duration(milliseconds: 1600));
  },
  '10-groups': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Month'));
    await r.poster();
    await r.tap(find.text('Day'));
    for (final icon in [Icons.format_italic, Icons.format_underline]) {
      await r.tap(find.byIcon(icon), after: const Duration(milliseconds: 400));
    }
    await r.tap(find.byIcon(Icons.format_bold), after: _beat);
  },
  '11-glass': (r) async {
    await r.wait(_short);
    await r.poster();
    await r.hold(find.text('Play'), _short, after: _short);
    await r.tap(find.byIcon(Icons.skip_previous), after: _short);
    await r.tap(find.byIcon(Icons.skip_next), after: _beat);
  },
  '12-accessibility': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Mute'), after: _beat);
    await r.tap(find.text('Sort: Newest'), after: _beat);
    await r.tap(find.text('Price'), after: _beat);
    for (var i = 0; i < 3; i++) {
      await r.pressKey(LogicalKeyboardKey.tab, 'Tab');
    }
    await r.wait(_short);
    await r.poster();
    await r.wait(_short);
    await r.hold(
      find.text('Save for later'),
      const Duration(milliseconds: 900),
      after: const Duration(milliseconds: 1200),
    );
  },
  '13-debug-checks': (r) async {
    await r.wait(_short);
    await r.tap(
      find.text('Show buttons with mistakes'),
      after: const Duration(milliseconds: 1200),
    );
    await r.poster();
    await r.wait(_beat);
  },
  '14-control': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Press Save from code'), after: _short);
    await r.poster();
    await r.wait(const Duration(milliseconds: 1600));
    await r.tap(find.text('Google'), after: _short);
    await r.tap(find.text('Apple'), after: const Duration(milliseconds: 1800));
  },
  '15-theme': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Teal'), after: _beat);
    await r.tap(find.text('Dark'), after: _beat);
    await r.poster();
    await r.tap(find.text('Orange'), after: _beat);
    await r.tap(find.text('Save'), after: _short);
    await r.tap(find.text('Dark'), after: _beat);
  },
  '16-custom-looks': (r) async {
    await r.wait(_short);
    await r.tap(find.text('Gradient'));
    await r.tap(find.text('Retro'));
    await r.hold(
      find.text('Hold me'),
      const Duration(milliseconds: 900),
      posterWhileHeld: true,
      after: _beat,
    );
  },
  '17-haptics-sound': (r) async {
    await r.wait(_short);
    await r.poster();
  },
};

void main() {
  setUpAll(_loadFonts);

  for (final demo in [heroDemo, ...featureDemos]) {
    if (demo.media == FeatureMedia.none) {
      continue;
    }
    testWidgets(demo.id, (tester) async {
      final script = _scripts[demo.id];
      expect(script, isNotNull, reason: 'No recording script for ${demo.id}');
      // The debug checks demo shows the warnings it prints.
      bouncyWarnings.value = const [];
      final restore = captureBouncyWarnings();
      // Tests draw Material shadows as solid black lines. Real shadows look
      // like the app. The test framework expects it back on afterwards.
      debugDisableShadows = false;
      try {
        final recorder = _Recorder(tester, demo);
        await recorder.start();
        await script!(recorder);
        await tester.pumpAndSettle();
        if (demo.media == FeatureMedia.screenshot) {
          await recorder.keepScreenshotOnly();
        }
      } finally {
        restore();
        debugDisableShadows = true;
      }
    }, skip: !_record);
  }
}
