import 'dart:io';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:bouncy_button_example/quick_start.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('example.md shows exactly the code in lib/quick_start.dart', () {
    // pub.dev shows example.md on the Example tab, so it must not drift from
    // the code that is analyzed and tested here.
    final markdown = File('example.md').readAsStringSync();
    final start = markdown.indexOf('```dart\n') + '```dart\n'.length;
    final end = markdown.indexOf('\n```', start);
    final shown = markdown.substring(start, end);
    final code = File('lib/quick_start.dart').readAsStringSync().trimRight();
    expect(shown, code);
  });

  testWidgets('the quick start tour works', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const QuickStartApp());
    expect(tester.takeException(), isNull);

    // Pay shows loading, then success, then returns to its label.
    await tester.tap(find.text(r'Pay $24.00'));
    await tester.pump();
    expect(find.text('Paying…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.pumpAndSettle();

    // A quick double tap counts once.
    await tester.tap(find.text('Opened 0 times'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Opened 1 times'));
    await tester.pumpAndSettle();
    expect(find.text('Opened 1 times'), findsOneWidget);

    // The group changes selection.
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    final month = tester.widget<BouncyButtonGroup<String>>(
      find.byType(BouncyButtonGroup<String>),
    );
    expect(month.selected, {'month'});

    // The pressable card responds.
    await tester.tap(find.text('Studio Headphones'));
    await tester.pumpAndSettle();
    expect(find.text('Card opened'), findsOneWidget);
  });
}
