import 'package:bouncy_button/bouncy_button.dart';
import 'package:bouncy_button_example/app.dart';
import 'package:bouncy_button_example/data/fixtures.dart';
import 'package:bouncy_button_example/data/mock_backend.dart';
import 'package:bouncy_button_example/state/demo_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<String> _tabs = [
  'Gallery',
  'Shop',
  'Checkout',
  'Playground',
  'Settings',
];

/// Pumps the app at [size], using a backend with no delay by default.
Future<(DemoSettings, MockBackend)> _pumpApp(
  WidgetTester tester, {
  DemoSettings? settings,
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final demoSettings = settings ?? DemoSettings(latency: Duration.zero);
  addTearDown(demoSettings.dispose);
  final backend = MockBackend(settings: demoSettings);
  await tester.pumpWidget(
    BouncyDemoApp(settings: demoSettings, backend: backend),
  );
  await tester.pumpAndSettle();
  return (demoSettings, backend);
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find
        .descendant(
          of: find.byWidgetPredicate(
            (widget) => widget is NavigationBar || widget is NavigationRail,
          ),
          matching: find.text(label),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _pullToRefresh(WidgetTester tester) async {
  await tester.fling(
      find.byType(ListView).hitTestable().first, const Offset(0, 500), 1000);
  await tester.pumpAndSettle();
}

void main() {
  group('every screen renders under each condition', () {
    final conditions = <String, (Size, DemoSettings Function())>{
      'light, narrow': (
        const Size(320, 640),
        () => DemoSettings(latency: Duration.zero, themeMode: ThemeMode.light),
      ),
      'dark, narrow': (
        const Size(320, 640),
        () => DemoSettings(latency: Duration.zero, themeMode: ThemeMode.dark),
      ),
      '3x text, narrow': (
        const Size(320, 640),
        () => DemoSettings(latency: Duration.zero, textScale: 3),
      ),
      'right to left, narrow': (
        const Size(320, 640),
        () => DemoSettings(latency: Duration.zero, rtl: true),
      ),
      'reduced motion': (
        const Size(400, 800),
        () => DemoSettings(latency: Duration.zero, reduceMotion: true),
      ),
      'light, wide': (
        const Size(1200, 800),
        () => DemoSettings(latency: Duration.zero, themeMode: ThemeMode.light),
      ),
      '3x text, wide': (
        const Size(1200, 800),
        () => DemoSettings(latency: Duration.zero, textScale: 3),
      ),
      'right to left, wide': (
        const Size(1200, 800),
        () => DemoSettings(latency: Duration.zero, rtl: true),
      ),
    };

    conditions.forEach((name, condition) {
      testWidgets(name, (tester) async {
        await _pumpApp(tester, size: condition.$1, settings: condition.$2());
        expect(tester.takeException(), isNull);
        for (final tab in _tabs) {
          await _openTab(tester, tab);
          expect(tester.takeException(), isNull, reason: 'on the $tab tab');
          // Scroll to the end so that every item gets laid out and painted.
          final list = find.byType(ListView).hitTestable();
          if (list.evaluate().isNotEmpty) {
            await tester.fling(list.first, const Offset(0, -20000), 5000);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'on the $tab tab');
          }
        }
      });
    });
  });

  testWidgets('uses a rail when wide and a bottom bar when narrow',
      (tester) async {
    await _pumpApp(tester, size: const Size(1200, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  group('gallery', () {
    testWidgets('pressed buttons appear in the event log', (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.text('Primary'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Event log'));
      await tester.pumpAndSettle();
      expect(find.text('Primary pressed'), findsOneWidget);
    });

    testWidgets('shows every animation type', (tester) async {
      await _pumpApp(tester);
      for (final type in BouncyButtonAnimationType.values) {
        await tester.scrollUntilVisible(
          find.text(type.name),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(type.name), findsOneWidget);
      }
    });
  });

  group('shop', () {
    testWidgets('shows a spinner, then products', (tester) async {
      final settings = DemoSettings(
        latency: const Duration(milliseconds: 500),
      );
      addTearDown(settings.dispose);
      await tester.pumpWidget(BouncyDemoApp(settings: settings));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator, skipOffstage: false),
          findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await _openTab(tester, 'Shop');
      expect(find.text(mockProducts.first.name), findsOneWidget);
    });

    testWidgets('a failed first load can be retried', (tester) async {
      final settings = DemoSettings(latency: Duration.zero, offline: true);
      await _pumpApp(tester, settings: settings);
      await _openTab(tester, 'Shop');
      expect(find.text(MockFailure.network.message), findsOneWidget);

      settings.offline = false;
      await tester.pump();
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text(mockProducts.first.name), findsOneWidget);
    });

    testWidgets('an empty catalog shows a message', (tester) async {
      await _pumpApp(
        tester,
        settings: DemoSettings(latency: Duration.zero, emptyCatalog: true),
      );
      await _openTab(tester, 'Shop');
      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('a failed refresh keeps the products and shows a banner',
        (tester) async {
      final (settings, _) = await _pumpApp(tester);
      await _openTab(tester, 'Shop');

      settings.offline = true;
      await tester.pump();
      await _pullToRefresh(tester);
      expect(find.text(mockProducts.first.name), findsOneWidget);
      expect(find.byType(MaterialBanner), findsOneWidget);
    });

    testWidgets('a favorite that fails to save rolls back', (tester) async {
      final (_, backend) = await _pumpApp(tester);
      await _openTab(tester, 'Shop');
      final product = mockProducts.first;
      final add = find.byTooltip('Add ${product.name} to favorites');
      expect(add, findsOneWidget);

      backend.script([MockFailure.server]);
      await tester.tap(add);
      await tester.pump();
      expect(
        find.byTooltip('Remove ${product.name} from favorites'),
        findsOneWidget,
        reason: 'the heart should change before the request finishes',
      );

      await tester.pumpAndSettle();
      expect(add, findsOneWidget);
      expect(find.text(MockFailure.server.message), findsOneWidget);
      expect(backend.favorites, isNot(contains(product.id)));
    });

    testWidgets('tapping a heart does not open the product', (tester) async {
      await _pumpApp(tester);
      await _openTab(tester, 'Shop');
      final product = mockProducts.first;

      await tester.tap(find.byTooltip('Add ${product.name} to favorites'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(product.name));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Event log'));
      await tester.pumpAndSettle();
      expect(find.text('Saved ${product.name}'), findsOneWidget);
      expect(find.text('Opened ${product.name}'), findsOneWidget);
    });

    testWidgets('a favorite that saves stays saved', (tester) async {
      final (_, backend) = await _pumpApp(tester);
      await _openTab(tester, 'Shop');
      final product = mockProducts.first;

      await tester.tap(find.byTooltip('Add ${product.name} to favorites'));
      await tester.pumpAndSettle();
      expect(backend.favorites, contains(product.id));
      expect(
        find.byTooltip('Remove ${product.name} from favorites'),
        findsOneWidget,
      );
    });
  });

  group('checkout', () {
    Future<void> fillForm(WidgetTester tester, {String? card}) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name on card'),
        'Ada Lovelace',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'ada@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Card number'),
        card ?? '4242 4242 4242 4242',
      );
    }

    Finder payButton() => find.ancestor(
          of: find.textContaining('Pay \$'),
          matching: find.byType(BouncyButton),
        );

    Future<void> tapPay(WidgetTester tester) async {
      // The list only builds what is near the screen, so scroll rather than
      // assume the button exists.
      await tester.scrollUntilVisible(
        payButton(),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.pumpAndSettle();
      await tester.tap(payButton());
    }

    testWidgets('a valid order is charged once and confirmed', (tester) async {
      final (_, backend) = await _pumpApp(tester);
      await _openTab(tester, 'Checkout');
      await fillForm(tester);
      await tapPay(tester);
      await tester.pumpAndSettle();

      expect(backend.charges, 1);
      expect(find.textContaining('Order ORD-1001 placed'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Mock card charged 1 time'),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
    });

    testWidgets('tapping Pay twice quickly charges once', (tester) async {
      final settings = DemoSettings(
        latency: const Duration(milliseconds: 500),
      );
      final (_, backend) = await _pumpApp(tester, settings: settings);
      await _openTab(tester, 'Checkout');
      await fillForm(tester);
      await tapPay(tester);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(payButton(), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(payButton(), warnIfMissed: false);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(backend.charges, 1);
    });

    testWidgets('an incomplete form is not sent', (tester) async {
      final (_, backend) = await _pumpApp(tester);
      await _openTab(tester, 'Checkout');
      backend.script([MockFailure.server]);
      await tapPay(tester);
      await tester.pumpAndSettle();

      expect(find.text('Enter the name on the card'), findsOneWidget);
      expect(backend.charges, 0);
      // The scripted failure is still waiting, so no request was made.
      await tester.runAsync(
        () => expectLater(
          backend.fetchProducts(),
          throwsA(isA<MockApiException>()),
        ),
      );
    });

    testWidgets('a declined card shows why, and can be retried',
        (tester) async {
      final (_, backend) = await _pumpApp(tester);
      await _openTab(tester, 'Checkout');
      await fillForm(tester, card: '4000 0000 0000 0002');
      await tapPay(tester);
      await tester.pumpAndSettle();
      expect(find.text(MockFailure.declined.message), findsOneWidget);
      expect(backend.charges, 0);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Card number'),
        '4242 4242 4242 4242',
      );
      await tapPay(tester);
      await tester.pumpAndSettle();
      expect(backend.charges, 1);
    });

    testWidgets('a network failure can be retried', (tester) async {
      final (_, backend) = await _pumpApp(tester);
      await _openTab(tester, 'Checkout');
      await fillForm(tester);
      backend.script([MockFailure.network]);
      await tapPay(tester);
      await tester.pumpAndSettle();
      expect(find.text(MockFailure.network.message), findsOneWidget);
      expect(backend.charges, 0);

      await tapPay(tester);
      await tester.pumpAndSettle();
      expect(backend.charges, 1);
    });

    testWidgets('a promo code applies a discount', (tester) async {
      await _pumpApp(tester);
      await _openTab(tester, 'Checkout');
      await tester.enterText(
        find.widgetWithText(TextField, 'Promo code'),
        'save10',
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Discount'), findsOneWidget);
    });

    testWidgets('a wrong promo code shows an error', (tester) async {
      await _pumpApp(tester);
      await _openTab(tester, 'Checkout');
      await tester.enterText(
        find.widgetWithText(TextField, 'Promo code'),
        'FREE',
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text(MockFailure.invalidPromo.message), findsOneWidget);
      expect(find.text('Discount'), findsNothing);
    });

    testWidgets('quantity buttons stop at one', (tester) async {
      await _pumpApp(tester);
      await _openTab(tester, 'Checkout');
      final remove = find.bySemanticsLabel('Remove one Studio Headphones');
      expect(remove, findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Add one Studio Headphones'));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsNWidgets(2));
      await tester.tap(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('settings', () {
    testWidgets('right to left mirrors the app', (tester) async {
      final (settings, _) = await _pumpApp(tester);
      final context = tester.element(find.byType(DemoShell));
      expect(Directionality.of(context), TextDirection.ltr);

      settings.rtl = true;
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.byType(DemoShell))),
        TextDirection.rtl,
      );
    });

    testWidgets('resetting restores favorites', (tester) async {
      final (_, backend) = await _pumpApp(tester);
      // Widget tests use a fake clock, so awaiting this directly would hang.
      await tester.runAsync(() => backend.setFavorite('mug', favorite: true));
      expect(backend.favorites, contains('mug'));
      await _openTab(tester, 'Settings');
      await tester.scrollUntilVisible(
        find.text('Reset mock data'),
        100,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.tap(find.text('Reset mock data'));
      await tester.pump();
      expect(backend.favorites, {'keyboard'});
    });
  });

  group('mock backend', () {
    test('scripted outcomes run in order, then requests succeed', () async {
      final settings = DemoSettings(latency: Duration.zero);
      addTearDown(settings.dispose);
      final backend = MockBackend(settings: settings)
        ..script([MockFailure.network, null, MockFailure.server]);

      await expectLater(
          backend.fetchProducts(), throwsA(isA<MockApiException>()));
      await expectLater(backend.fetchProducts(), completes);
      await expectLater(
          backend.fetchProducts(), throwsA(isA<MockApiException>()));
      await expectLater(backend.fetchProducts(), completes);
    });

    test('a seed repeats the same failures', () async {
      Future<List<bool>> run() async {
        final settings = DemoSettings(latency: Duration.zero, failureRate: 0.5);
        addTearDown(settings.dispose);
        final backend = MockBackend(settings: settings, seed: 7);
        final results = <bool>[];
        for (var i = 0; i < 20; i++) {
          try {
            await backend.fetchProducts();
            results.add(true);
          } on MockApiException {
            results.add(false);
          }
        }
        return results;
      }

      final first = await run();
      expect(await run(), first);
      expect(first, containsAll([true, false]));
    });

    test('offline fails even when a success is scripted', () async {
      final settings = DemoSettings(latency: Duration.zero, offline: true);
      addTearDown(settings.dispose);
      final backend = MockBackend(settings: settings)..script([null]);
      await expectLater(
          backend.fetchProducts(), throwsA(isA<MockApiException>()));
    });
  });
}
