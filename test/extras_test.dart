import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  MediaQueryData media = const MediaQueryData(),
}) {
  return MediaQuery(
    data: media,
    child: MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

const List<BouncyButtonSegment<String>> _segments = [
  BouncyButtonSegment(value: 'day', label: Text('Day')),
  BouncyButtonSegment(value: 'week', label: Text('Week')),
  BouncyButtonSegment(value: 'month', label: Text('Month')),
];

BoxDecoration _faceOf(WidgetTester tester, String label) {
  final face = find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(BouncyButton),
    ),
    matching: find.byWidgetPredicate(
      (widget) => widget is Container && widget.decoration is BoxDecoration,
    ),
  );
  return tester.widget<Container>(face).decoration! as BoxDecoration;
}

/// Records SystemSound.play calls, ignoring haptics on the same channel.
List<String> _recordSounds(WidgetTester tester) {
  final sounds = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'SystemSound.play') {
        sounds.add(call.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return sounds;
}

void main() {
  group('BouncyButtonGroup', () {
    Widget group({
      Set<String> selected = const {'day'},
      ValueChanged<Set<String>>? onChanged,
      bool multiSelect = false,
      bool emptyAllowed = false,
      List<BouncyButtonSegment<String>> segments = _segments,
    }) {
      return BouncyButtonGroup<String>(
        segments: segments,
        selected: selected,
        onSelectionChanged: onChanged,
        multiSelect: multiSelect,
        emptySelectionAllowed: emptyAllowed,
      );
    }

    testWidgets('selects one segment at a time', (tester) async {
      Set<String>? result;
      await tester.pumpWidget(
        _app(group(onChanged: (value) => result = value)),
      );
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(result, {'week'});
    });

    testWidgets('keeps the last selection unless empty is allowed',
        (tester) async {
      Set<String>? result;
      await tester.pumpWidget(
        _app(group(onChanged: (value) => result = value)),
      );
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      expect(result, isNull);

      await tester.pumpWidget(
        _app(
          group(onChanged: (value) => result = value, emptyAllowed: true),
        ),
      );
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      expect(result, isEmpty);
    });

    testWidgets('multi-select toggles segments', (tester) async {
      Set<String>? result;
      await tester.pumpWidget(
        _app(
          group(
            selected: {'day', 'week'},
            multiSelect: true,
            onChanged: (value) => result = value,
          ),
        ),
      );
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(result, {'day', 'week', 'month'});
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      expect(result, {'week'});
    });

    testWidgets('a null callback or disabled segment does nothing',
        (tester) async {
      await tester.pumpWidget(_app(group()));
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      Set<String>? result;
      await tester.pumpWidget(
        _app(
          group(
            onChanged: (value) => result = value,
            segments: const [
              BouncyButtonSegment(value: 'day', label: Text('Day')),
              BouncyButtonSegment(
                value: 'week',
                label: Text('Week'),
                enabled: false,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('selected segments are filled, others tonal', (tester) async {
      await tester.pumpWidget(_app(group(onChanged: (_) {})));
      final scheme = Theme.of(tester.element(find.text('Day'))).colorScheme;
      expect(_faceOf(tester, 'Day').color, scheme.primary);
      expect(_faceOf(tester, 'Week').color, scheme.secondaryContainer);
    });

    for (final direction in TextDirection.values) {
      testWidgets('only the outer corners are round, ${direction.name}',
          (tester) async {
        await tester.pumpWidget(
          _app(group(onChanged: (_) {}), direction: direction),
        );
        BorderRadius corners(String label) =>
            _faceOf(tester, label).borderRadius!.resolve(direction);
        final leftLabel = direction == TextDirection.ltr ? 'Day' : 'Month';
        final rightLabel = direction == TextDirection.ltr ? 'Month' : 'Day';
        expect(corners(leftLabel).topLeft, isNot(Radius.zero));
        expect(corners(leftLabel).topRight, Radius.zero);
        expect(corners(rightLabel).topRight, isNot(Radius.zero));
        expect(corners(rightLabel).topLeft, Radius.zero);
        expect(corners('Week').topLeft, Radius.zero);
        expect(corners('Week').bottomRight, Radius.zero);
        // The first segment is on the reading side.
        final dayX = tester.getCenter(find.text('Day')).dx;
        final monthX = tester.getCenter(find.text('Month')).dx;
        expect(dayX < monthX, direction == TextDirection.ltr);
      });
    }

    testWidgets('segments share the width equally', (tester) async {
      await tester.pumpWidget(
        _app(SizedBox(width: 304, child: group(onChanged: (_) {}))),
      );
      final widths = [
        for (final element in find.byType(BouncyButton).evaluate())
          tester.getSize(find.byWidget(element.widget)).width,
      ];
      expect(widths, everyElement(closeTo(100, 0.01)));
    });

    testWidgets('works in a horizontal scroll view', (tester) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: group(onChanged: (_) {}),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles large text', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(width: 300, child: group(onChanged: (_) {})),
          media: const MediaQueryData(textScaler: TextScaler.linear(3)),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('announces the selected state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(group(onChanged: (_) {})));
      // isSemantics, its replacement, does not exist on the minimum Flutter.
      // ignore: deprecated_member_use
      final selected = containsSemantics(
        label: 'Day',
        isButton: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
      );
      expect(tester.getSemantics(find.text('Day')), selected);
      // ignore: deprecated_member_use
      final unselected = containsSemantics(label: 'Week', isSelected: false);
      expect(tester.getSemantics(find.text('Week')), unselected);
      handle.dispose();
    });

    testWidgets('an icon-only segment uses its semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyButtonGroup<int>(
            segments: const [
              BouncyButtonSegment(
                value: 0,
                icon: Icon(Icons.grid_view),
                semanticLabel: 'Grid',
              ),
              BouncyButtonSegment(
                value: 1,
                icon: Icon(Icons.list),
                semanticLabel: 'List',
              ),
            ],
            selected: const {0},
            onSelectionChanged: (_) {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Grid'), findsOneWidget);
      expect(find.bySemanticsLabel('List'), findsOneWidget);
      handle.dispose();
    });
  });

  group('sound', () {
    testWidgets('is off by default', (tester) async {
      final sounds = _recordSounds(tester);
      await tester.pumpWidget(
        _app(BouncyButton(onPressed: () {}, child: const Text('x'))),
      );
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(sounds, isEmpty);
    });

    testWidgets('plays the system click on each press', (tester) async {
      final sounds = _recordSounds(tester);
      var custom = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            interaction: BouncyButtonInteraction(
              enableSound: true,
              onPressSound: () => custom++,
            ),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(sounds, ['SystemSoundType.click', 'SystemSoundType.click']);
      expect(custom, 2);
    });

    testWidgets('does not play while the button is busy', (tester) async {
      final sounds = _recordSounds(tester);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            isLoading: true,
            interaction: const BouncyButtonInteraction(enableSound: true),
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.byType(BouncyButton));
      await tester.pump();
      expect(sounds, isEmpty);
    });

    testWidgets('works on BouncyPressable', (tester) async {
      final sounds = _recordSounds(tester);
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            onTap: () {},
            enableSound: true,
            child: const Text('x'),
          ),
        ),
      );
      await tester.tap(find.text('x'));
      await tester.pumpAndSettle();
      expect(sounds, ['SystemSoundType.click']);
    });
  });

  group('glass', () {
    testWidgets('is translucent and blurred, with no depth', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.glass.copyWith(elevation: 10),
            child: const Text('x'),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(_faceOf(tester, 'x').color!.a, lessThan(1));
      expect(tester.getSize(find.byType(BouncyButton)).height, 48);
    });

    testWidgets('a circle is clipped to a circle', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.circle.copyWith(
              fill: BouncyButtonFill.glass,
            ),
            child: const Text('x'),
          ),
        ),
      );
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('high contrast makes it solid and legible', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.glass,
            child: const Text('x'),
          ),
          media: const MediaQueryData(highContrast: true),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      final face = _faceOf(tester, 'x').color!;
      expect(face.a, 1);
      final text =
          DefaultTextStyle.of(tester.element(find.text('x'))).style.color!;
      final lf = face.computeLuminance();
      final lt = text.computeLuminance();
      final ratio =
          (lf > lt ? lf + 0.05 : lt + 0.05) / (lf > lt ? lt + 0.05 : lf + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  });
}
