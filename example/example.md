# bouncy_button example

A one-screen tour of the main features. Copy it into a new Flutter app, or run it from the package's `example` folder:

```bash
flutter run -t lib/quick_start.dart
```

```dart
import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

void main() => runApp(const QuickStartApp());

class QuickStartApp extends StatelessWidget {
  const QuickStartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bouncy Button',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const QuickStartPage(),
    );
  }
}

class QuickStartPage extends StatefulWidget {
  const QuickStartPage({super.key});

  @override
  State<QuickStartPage> createState() => _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {
  int _opened = 0;
  String _view = 'week';

  // Stands in for a real network request, such as a payment.
  Future<void> _pay() => Future<void>.delayed(const Duration(seconds: 1));

  void _show(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bouncy Button')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. A 3D button that sinks when pressed and springs back.
          const _Title('Press me'),
          BouncyButton(
            onPressed: () => _show('Pressed!'),
            child: const Text('Press me'),
          ),

          // 2. A style for each kind of action.
          const _Title('Styles'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              BouncyButton(
                onPressed: () {},
                style: BouncyButtonStyle.tonal,
                child: const Text('Tonal'),
              ),
              BouncyButton(
                onPressed: () {},
                style: BouncyButtonStyle.outlined,
                child: const Text('Outlined'),
              ),
              BouncyButton(
                onPressed: () {},
                style: BouncyButtonStyle.destructive,
                leading: const Icon(Icons.delete_outline),
                child: const Text('Delete'),
              ),
            ],
          ),

          // 3. Loading, then a tick. Extra taps are ignored meanwhile.
          const _Title('Loading and success'),
          BouncyButton(
            onPressedAsync: _pay,
            onError: (error, stackTrace) => _show('Payment failed'),
            feedback: const BouncyButtonFeedback(loadingText: 'Paying…'),
            style: BouncyButtonStyle.primary.copyWith(width: double.infinity),
            child: const Text(r'Pay $24.00'),
          ),

          // 4. A fast double tap only counts once.
          const _Title('Double-tap protection'),
          BouncyButton(
            onPressed: () => setState(() => _opened++),
            cooldown: const Duration(milliseconds: 600),
            child: Text('Opened $_opened times'),
          ),

          // 5. The same press on any widget.
          const _Title('Any widget'),
          BouncyPressable(
            onTap: () => _show('Card opened'),
            child: const Card(
              child: ListTile(
                leading: Icon(Icons.headphones),
                title: Text('Studio Headphones'),
                subtitle: Text(r'$129.00'),
              ),
            ),
          ),

          // 6. Connected buttons for picking one option.
          const _Title('Button group'),
          BouncyButtonGroup<String>(
            segments: const [
              BouncyButtonSegment(value: 'day', label: Text('Day')),
              BouncyButtonSegment(value: 'week', label: Text('Week')),
              BouncyButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: {_view},
            onSelectionChanged: (selection) {
              setState(() => _view = selection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
```

## The full demo app

For every option, run `flutter run` in the `example` folder. It opens a larger demo with:

- **Gallery:** every style, animation, and setting.
- **Shop:** product cards with loading, empty, and error states.
- **Checkout:** a payment that can succeed, be declined, or fail and retry.
- **Playground:** adjust a button live and copy its code.

It runs on built-in sample data, so it needs no setup or network.
