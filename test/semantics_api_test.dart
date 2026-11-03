// isSemantics, the replacement for containsSemantics, does not exist on the
// minimum Flutter version.
// ignore_for_file: deprecated_member_use

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: Center(child: child)),
  );
}

void _useKeyboardHighlights() {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );
}

void main() {
  group('isSelected', () {
    testWidgets('a button announces its toggle state', (tester) async {
      final handle = tester.ensureSemantics();
      Future<void> pump({bool? selected}) => tester.pumpWidget(
            _app(
              BouncyButton(
                isSelected: selected,
                onPressed: () {},
                child: const Text('Mute'),
              ),
            ),
          );

      await pump(selected: true);
      expect(
        tester.getSemantics(find.text('Mute')),
        containsSemantics(
          isButton: true,
          hasCheckedState: true,
          isChecked: true,
        ),
      );
      await pump(selected: false);
      expect(
        tester.getSemantics(find.text('Mute')),
        containsSemantics(hasCheckedState: true, isChecked: false),
      );
      await pump();
      expect(
        tester.getSemantics(find.text('Mute')),
        containsSemantics(hasCheckedState: false),
      );
      handle.dispose();
    });

    testWidgets('a pressable announces its toggle state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            isSelected: true,
            onTap: () {},
            child: const Text('Favorite'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Favorite')),
        containsSemantics(hasCheckedState: true, isChecked: true),
      );
      handle.dispose();
    });
  });

  group('expanded', () {
    testWidgets('a button announces whether its menu is open', (tester) async {
      final handle = tester.ensureSemantics();
      Future<void> pump(bool? expanded) => tester.pumpWidget(
            _app(
              BouncyButton(
                expanded: expanded,
                onPressed: () {},
                child: const Text('Sort'),
              ),
            ),
          );

      await pump(true);
      expect(
        tester.getSemantics(find.text('Sort')),
        containsSemantics(hasExpandedState: true, isExpanded: true),
      );
      await pump(false);
      expect(
        tester.getSemantics(find.text('Sort')),
        containsSemantics(hasExpandedState: true, isExpanded: false),
      );
      await pump(null);
      expect(
        tester.getSemantics(find.text('Sort')),
        containsSemantics(hasExpandedState: false),
      );
      handle.dispose();
    });

    testWidgets('a pressable announces it too', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            expanded: true,
            onTap: () {},
            child: const Text('Details'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Details')),
        containsSemantics(hasExpandedState: true, isExpanded: true),
      );
      handle.dispose();
    });
  });

  group('disabledReason', () {
    testWidgets('is read and shown while disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const BouncyButton(
            disabledReason: 'Add a card first',
            child: Text('Pay'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Pay')),
        containsSemantics(
          label: 'Pay',
          hint: 'Add a card first',
          hasEnabledState: true,
          isEnabled: false,
        ),
      );

      await tester.longPress(find.text('Pay'));
      await tester.pump();
      expect(find.text('Add a card first'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      handle.dispose();
    });

    testWidgets('is not used while enabled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BouncyButton(
            onPressed: () {},
            disabledReason: 'Add a card first',
            tooltip: 'Pay now',
            child: const Text('Pay'),
          ),
        ),
      );
      final data = tester.getSemantics(find.text('Pay')).getSemanticsData();
      expect(data.hint, isEmpty);
      expect(data.tooltip, 'Pay now');

      await tester.longPress(find.text('Pay'));
      await tester.pump();
      expect(find.text('Add a card first'), findsNothing);
      expect(find.text('Pay now'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      handle.dispose();
    });

    testWidgets('appearing keeps the button state', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var enabled = true;
      late StateSetter setOuter;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return BouncyButton(
                focusNode: node,
                enabled: enabled,
                disabledReason: 'Not now',
                onPressed: () {},
                child: const Text('Go'),
              );
            },
          ),
        ),
      );
      final before = tester.state(find.byType(BouncyButton));
      setOuter(() => enabled = false);
      await tester.pump();
      setOuter(() => enabled = true);
      await tester.pump();
      expect(tester.state(find.byType(BouncyButton)), same(before));
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });
  });

  group('tooltip', () {
    testWidgets('shows with keyboard focus', (tester) async {
      _useKeyboardHighlights();
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            focusNode: node,
            tooltip: 'Share',
            onPressed: () {},
            child: const Icon(Icons.share),
          ),
        ),
      );
      expect(find.text('Share'), findsNothing);
      node.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsOneWidget);

      node.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('does not show for touch focus', (tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(
          BouncyButton(
            focusNode: node,
            tooltip: 'Share',
            onPressed: () {},
            child: const Icon(Icons.share),
          ),
        ),
      );
      node.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsNothing);
    });
  });

  group('BouncyButton.icon', () {
    testWidgets('is named by its tooltip and big enough to tap',
        (tester) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await tester.pumpWidget(
        _app(
          BouncyButton.icon(
            onPressed: () => presses++,
            tooltip: 'Share',
            icon: const Icon(Icons.share),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byIcon(Icons.share)),
        containsSemantics(isButton: true, tooltip: 'Share'),
      );
      final size = tester.getSize(find.byType(BouncyButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      expect(presses, 1);
      handle.dispose();
    });

    testWidgets('is round and tonal by default', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton.icon(
            onPressed: () {},
            tooltip: 'Share',
            icon: const Icon(Icons.share),
          ),
        ),
      );
      final face = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(BouncyButton),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container && widget.decoration is BoxDecoration,
              ),
            )
            .first,
      );
      final decoration = face.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      final context = tester.element(find.byType(BouncyButton));
      expect(
        decoration.color,
        Theme.of(context).colorScheme.secondaryContainer,
      );
    });

    testWidgets('uses the theme icon style', (tester) async {
      await tester.pumpWidget(
        _app(
          BouncyButton.icon(
            onPressed: () {},
            tooltip: 'Share',
            icon: const Icon(Icons.share),
          ),
          theme: ThemeData(
            extensions: const [
              BouncyButtonTheme(
                iconStyle: BouncyButtonStyle(
                  height: 64,
                  shape: BoxShape.circle,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(BouncyButton)), const Size(64, 64));
    });
  });

  group('statesController', () {
    testWidgets('follows press, hover, focus, and selection', (tester) async {
      // Hover highlights only show in the mouse and keyboard highlight mode.
      _useKeyboardHighlights();
      final states = WidgetStatesController();
      addTearDown(states.dispose);
      final node = FocusNode();
      addTearDown(node.dispose);
      Future<void> pump({bool enabled = true}) => tester.pumpWidget(
            _app(
              BouncyButton(
                statesController: states,
                focusNode: node,
                enabled: enabled,
                isSelected: true,
                onPressed: () {},
                child: const Text('x'),
              ),
            ),
          );
      await pump();
      expect(states.value, {WidgetState.selected});

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('x')),
      );
      await tester.pump();
      expect(states.value, contains(WidgetState.pressed));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(states.value, isNot(contains(WidgetState.pressed)));

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(find.text('x')));
      await tester.pump();
      expect(states.value, contains(WidgetState.hovered));
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(states.value, isNot(contains(WidgetState.hovered)));

      node.requestFocus();
      await tester.pump();
      expect(states.value, contains(WidgetState.focused));

      await pump(enabled: false);
      expect(states.value, contains(WidgetState.disabled));
    });

    testWidgets('works on a pressable', (tester) async {
      final states = WidgetStatesController();
      addTearDown(states.dispose);
      await tester.pumpWidget(
        _app(
          BouncyPressable(
            statesController: states,
            onTap: () {},
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(BouncyPressable)),
      );
      await tester.pump();
      expect(states.value, contains(WidgetState.pressed));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(states.value, isEmpty);
    });
  });

  group('minWidth', () {
    testWidgets('widens a short button and lets a long one grow',
        (tester) async {
      Future<double> widthOf(String text, {double? width}) async {
        await tester.pumpWidget(
          _app(
            BouncyButton(
              onPressed: () {},
              style: BouncyButtonStyle(minWidth: 200, width: width),
              child: Text(text),
            ),
          ),
        );
        return tester.getSize(find.byType(BouncyButton)).width;
      }

      expect(await widthOf('OK'), 200);
      expect(
        await widthOf('A label much longer than two hundred'),
        greaterThan(200),
      );
      expect(await widthOf('OK', width: 120), 120);
    });

    testWidgets('is part of equality', (tester) async {
      const a = BouncyButtonStyle(minWidth: 100);
      expect(a, const BouncyButtonStyle(minWidth: 100));
      expect(a, isNot(const BouncyButtonStyle(minWidth: 101)));
      expect(a.copyWith(height: 50).minWidth, 100);
      expect(a.hashCode, const BouncyButtonStyle(minWidth: 100).hashCode);
    });
  });

  group('BouncyButtonGroup.showSelectedIcon', () {
    Widget group({bool show = true, Widget? selectedIcon}) {
      return BouncyButtonGroup<String>(
        segments: const [
          BouncyButtonSegment(
            value: 'list',
            label: Text('List'),
            icon: Icon(Icons.list),
          ),
          BouncyButtonSegment(value: 'grid', icon: Icon(Icons.grid_view)),
        ],
        selected: const {'list', 'grid'},
        multiSelect: true,
        showSelectedIcon: show,
        selectedIcon: selectedIcon,
        onSelectionChanged: (_) {},
      );
    }

    testWidgets('marks selected segments with a check', (tester) async {
      await tester.pumpWidget(_app(group()));
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.list), findsNothing);
      // A segment with only an icon keeps it.
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    });

    testWidgets('is off by default', (tester) async {
      await tester.pumpWidget(_app(group(show: false)));
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('takes a custom icon', (tester) async {
      await tester.pumpWidget(
        _app(group(selectedIcon: const Icon(Icons.done_all))),
      );
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });
  });
}
