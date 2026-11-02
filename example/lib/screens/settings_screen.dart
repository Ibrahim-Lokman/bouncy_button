import 'package:flutter/material.dart';

import '../state/demo_scope.dart';

/// Controls the mock backend and the conditions the demo runs under.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = DemoScope.of(context);
    final settings = scope.settings;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _Heading('Mock backend', style: textTheme.titleMedium),
        _SliderTile(
          label: 'Latency',
          value: settings.latency.inMilliseconds.toDouble(),
          max: 3000,
          divisions: 30,
          format: (value) => '${value.round()} ms',
          onChanged: (value) =>
              settings.latency = Duration(milliseconds: value.round()),
        ),
        _SliderTile(
          label: 'Failure rate',
          value: settings.failureRate,
          max: 1,
          divisions: 10,
          format: (value) => '${(value * 100).round()}%',
          onChanged: (value) => settings.failureRate = value,
        ),
        SwitchListTile(
          title: const Text('Offline'),
          subtitle: const Text('Every request fails with a network error.'),
          value: settings.offline,
          onChanged: (value) => settings.offline = value,
        ),
        SwitchListTile(
          title: const Text('Empty catalog'),
          subtitle: const Text('The Shop screen receives no products.'),
          value: settings.emptyCatalog,
          onChanged: (value) => settings.emptyCatalog = value,
        ),
        ListTile(
          title: const Text('Reset mock data'),
          subtitle: const Text(
            'Restores favorites, clears charges, and clears the event log.',
          ),
          trailing: const Icon(Icons.restart_alt),
          onTap: () {
            scope.backend.reset();
            scope.log.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mock data reset')),
            );
          },
        ),
        const Divider(),
        _Heading('Display', style: textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in ThemeMode.values)
                ChoiceChip(
                  label: Text(switch (mode) {
                    ThemeMode.system => 'System theme',
                    ThemeMode.light => 'Light theme',
                    ThemeMode.dark => 'Dark theme',
                  }),
                  selected: settings.themeMode == mode,
                  onSelected: (_) => settings.themeMode = mode,
                ),
            ],
          ),
        ),
        _SliderTile(
          label: 'Text size',
          value: settings.textScale,
          min: 0.8,
          max: 3,
          divisions: 11,
          format: (value) => '${value.toStringAsFixed(1)}x',
          onChanged: (value) => settings.textScale = value,
        ),
        SwitchListTile(
          title: const Text('Right to left'),
          subtitle: const Text('Lays out the app as for Arabic or Hebrew.'),
          value: settings.rtl,
          onChanged: (value) => settings.rtl = value,
        ),
        SwitchListTile(
          title: const Text('Reduce motion'),
          subtitle: const Text('Simulates the system accessibility setting.'),
          value: settings.reduceMotion,
          onChanged: (value) => settings.reduceMotion = value,
        ),
        const Divider(),
        _Heading('Feedback', style: textTheme.titleMedium),
        SwitchListTile(
          title: const Text('Haptics'),
          subtitle: const Text(
            'Applied through BouncyButtonTheme, so buttons with their own '
            'interaction keep it.',
          ),
          value: settings.haptics,
          onChanged: (value) => settings.haptics = value,
        ),
        SwitchListTile(
          title: const Text('Press sound'),
          subtitle: const Text(
            'The system click, where the platform has one. Web is silent.',
          ),
          value: settings.sound,
          onChanged: (value) => settings.sound = value,
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(text, style: style),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.max,
    required this.format,
    required this.onChanged,
    this.min = 0,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$label: ${format(value)}'),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: format(value),
            semanticFormatterCallback: (value) => '$label ${format(value)}',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
