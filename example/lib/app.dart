import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

import 'data/mock_backend.dart';
import 'screens/checkout_screen.dart';
import 'screens/features_screen.dart';
import 'screens/playground_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_screen.dart';
import 'state/demo_scope.dart';
import 'state/demo_settings.dart';
import 'state/event_log.dart';
import 'widgets/event_log_sheet.dart';

/// The demo app. Pass [settings] or [backend] to control it from a test.
class BouncyDemoApp extends StatefulWidget {
  const BouncyDemoApp({super.key, this.settings, this.backend});

  final DemoSettings? settings;
  final MockBackend? backend;

  @override
  State<BouncyDemoApp> createState() => _BouncyDemoAppState();
}

class _BouncyDemoAppState extends State<BouncyDemoApp> {
  late final DemoSettings _settings = widget.settings ?? DemoSettings();
  late final MockBackend _backend =
      widget.backend ?? MockBackend(settings: _settings);
  final EventLog _log = EventLog();

  ThemeData _theme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3F51B5),
        brightness: brightness,
      ),
      extensions: [
        BouncyButtonTheme(
          defaultInteraction: BouncyButtonInteraction(
            enableHapticFeedback: _settings.haptics,
            enableSound: _settings.sound,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _log.dispose();
    if (widget.settings == null) {
      _settings.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScope(
      settings: _settings,
      backend: _backend,
      log: _log,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => MaterialApp(
          title: 'Bouncy Button Demo',
          debugShowCheckedModeBanner: false,
          themeMode: _settings.themeMode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(_settings.textScale),
                disableAnimations:
                    _settings.reduceMotion || media.disableAnimations,
              ),
              child: Directionality(
                textDirection:
                    _settings.rtl ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              ),
            );
          },
          home: const DemoShell(),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<_Destination> _destinations = [
  _Destination('Features', Icons.auto_awesome_outlined, Icons.auto_awesome),
  _Destination('Shop', Icons.storefront_outlined, Icons.storefront),
  _Destination('Checkout', Icons.shopping_cart_outlined, Icons.shopping_cart),
  _Destination('Playground', Icons.tune_outlined, Icons.tune),
  _Destination('Settings', Icons.settings_outlined, Icons.settings),
];

/// Navigation that adapts to the window: a bottom bar or a side rail.
class DemoShell extends StatefulWidget {
  const DemoShell({super.key});

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  static const double _railBreakpoint = 720;

  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final useRail = MediaQuery.sizeOf(context).width >= _railBreakpoint;
    final body = IndexedStack(
      index: _index,
      children: const [
        FeaturesScreen(),
        ShopScreen(),
        CheckoutScreen(),
        PlaygroundScreen(),
        SettingsScreen(),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_index].label),
        actions: const [EventLogButton()],
      ),
      body: useRail
          ? Row(
              children: [
                // Destinations have a fixed size, so very large text can't fit.
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final destination in _destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: useRail
          ? null
          : MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _select,
                destinations: [
                  for (final destination in _destinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: destination.label,
                    ),
                ],
              ),
            ),
    );
  }
}
