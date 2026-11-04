import 'package:bouncy_button_example/state/warning_log.dart';
import 'package:bouncy_button_example/tour/feature_demos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps one demo on its own, as the GIF recorder does.
Future<void> _pumpDemo(
  WidgetTester tester,
  FeatureDemo demo, {
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3F51B5),
        brightness: brightness,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Builder(builder: demo.builder),
        ),
      ),
    ),
  );
  await tester.pump();
}

FeatureDemo _demo(String id) =>
    featureDemos.firstWhere((demo) => demo.id == id);

void main() {
  test('demo ids are unique and in order', () {
    final ids = featureDemos.map((demo) => demo.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    for (final (index, id) in ids.indexed) {
      expect(id, startsWith((index + 1).toString().padLeft(2, '0')));
    }
  });

  testWidgets('every demo builds without a single debug warning',
      (tester) async {
    final warnings = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null && message.startsWith('bouncy_button:')) {
        warnings.add(message);
      }
    };
    try {
      for (final brightness in Brightness.values) {
        for (final demo in [...featureDemos, heroDemo]) {
          await _pumpDemo(tester, demo, brightness: brightness);
          expect(tester.takeException(), isNull, reason: demo.id);
        }
      }
    } finally {
      debugPrint = original;
    }
    expect(warnings, isEmpty);
  });

  testWidgets('loading shows the text, then a tick', (tester) async {
    await _pumpDemo(tester, _demo('02-loading'));
    await tester.tap(find.text(r'Pay $24.00'));
    await tester.pump();
    expect(find.text('Paying…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('a triple tap runs protected buttons once', (tester) async {
    await _pumpDemo(tester, _demo('03-double-taps'));
    for (final label in ['No protection', 'With cooldown', 'Pay (async)']) {
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text(label));
        await tester.pump(const Duration(milliseconds: 80));
      }
    }
    await tester.pumpAndSettle();
    expect(find.text('Ran 3 times'), findsOneWidget);
    expect(find.text('Ran 1 time'), findsOneWidget);
    expect(find.text('Charged 1 time'), findsOneWidget);
  });

  testWidgets('delete asks first, and a slow request gives up', (tester) async {
    await _pumpDemo(tester, _demo('08-timeout-confirm'));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Account deleted.'), findsOneWidget);

    await tester.tap(find.text('Slow request'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Gave up after 2 seconds.'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('the toggle and menu report their state', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpDemo(tester, _demo('12-accessibility'));
    await tester.tap(find.text('Mute'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Mute')),
      // ignore: deprecated_member_use
      containsSemantics(isChecked: true),
    );
    await tester.tap(find.text('Sort: Newest'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Sort: Newest')),
      // ignore: deprecated_member_use
      containsSemantics(isExpanded: true),
    );
    await tester.tap(find.text('Price'));
    await tester.pumpAndSettle();
    expect(find.text('Sort: Price'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('buttons with mistakes show their warnings on screen',
      (tester) async {
    bouncyWarnings.value = const [];
    final restore = captureBouncyWarnings();
    try {
      await _pumpDemo(tester, _demo('13-debug-checks'));
      expect(find.text('No warnings yet.'), findsOneWidget);
      await tester.tap(find.text('Show buttons with mistakes'));
      await tester.pumpAndSettle();
    } finally {
      restore();
    }
    expect(find.textContaining('has no label'), findsOneWidget);
    expect(find.textContaining('contrast'), findsOneWidget);
    expect(find.textContaining('can only be tapped'), findsOneWidget);
  });
}
