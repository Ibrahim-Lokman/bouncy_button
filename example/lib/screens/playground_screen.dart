import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/demo_scope.dart';

class _NamedColor {
  const _NamedColor(this.name, this.color, this.code);

  final String name;
  final Color color;
  final String code;
}

const List<_NamedColor> _colors = [
  _NamedColor('Indigo', Color(0xFF3F51B5), 'Color(0xFF3F51B5)'),
  _NamedColor('Teal', Color(0xFF00796B), 'Color(0xFF00796B)'),
  _NamedColor('Pink', Color(0xFFC2185B), 'Color(0xFFC2185B)'),
  _NamedColor('Orange', Color(0xFFE65100), 'Color(0xFFE65100)'),
];

/// Lets you adjust a button live and copy the code that produces it.
class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  BouncyButtonAnimationType _type = BouncyButtonAnimationType.depth;
  BouncyButtonFill _fill = BouncyButtonFill.filled;
  bool _icon = false;
  bool _spring = false;
  _NamedColor _color = _colors.first;
  double _height = 56;
  double _elevation = 8;
  double _radius = 12;
  double _duration = 120;
  double _shadowDarkness = 0.3;

  String get _code => '''
BouncyButton(
  onPressed: () {},
  style: BouncyButtonStyle(
    height: ${_height.round()},
    elevation: ${_elevation.round()},
    backgroundColor: const ${_color.code},
    borderRadius: BorderRadius.circular(${_radius.round()}),
    shadowDarkness: ${_shadowDarkness.toStringAsFixed(2)},
    fill: BouncyButtonFill.${_fill.name},
  ),${_icon ? '\n  leading: const Icon(Icons.bolt),' : ''}
  animation: const BouncyButtonAnimation(
    type: BouncyButtonAnimationType.${_type.name},
    ${_spring ? 'spring: BouncyPressSpring.bouncy,' : 'duration: Duration(milliseconds: ${_duration.round()}),'}
  ),
  child: const Text('Press me'),
)''';

  Future<void> _copyCode() async {
    final messenger = ScaffoldMessenger.of(context);
    DemoScope.read(context).log.add('Copied playground code');
    await Clipboard.setData(ClipboardData(text: _code));
    messenger.showSnackBar(const SnackBar(content: Text('Code copied')));
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int fractionDigits = 0,
  }) {
    final shown = value.toStringAsFixed(fractionDigits);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$label: $shown'),
        Slider(
          value: value,
          min: min,
          max: max,
          label: shown,
          semanticFormatterCallback: (value) =>
              '$label ${value.toStringAsFixed(fractionDigits)}',
          onChanged: (value) => setState(() => onChanged(value)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: BouncyButton(
              onPressed: () =>
                  DemoScope.read(context).log.add('Playground button pressed'),
              style: BouncyButtonStyle(
                height: _height,
                elevation: _elevation,
                backgroundColor: _color.color,
                borderRadius: BorderRadius.circular(_radius),
                shadowDarkness: _shadowDarkness,
                fill: _fill,
              ),
              leading: _icon ? const Icon(Icons.bolt) : null,
              animation: BouncyButtonAnimation(
                type: _type,
                duration: Duration(milliseconds: _duration.round()),
                spring: _spring ? BouncyPressSpring.bouncy : null,
              ),
              child: const Text('Press me'),
            ),
          ),
        ),
        _slider(
          label: 'Height',
          value: _height,
          min: 40,
          max: 96,
          onChanged: (value) => _height = value,
        ),
        _slider(
          label: 'Elevation',
          value: _elevation,
          min: 0,
          max: 24,
          onChanged: (value) => _elevation = value,
        ),
        _slider(
          label: 'Corner radius',
          value: _radius,
          min: 0,
          max: 48,
          onChanged: (value) => _radius = value,
        ),
        _slider(
          label: 'Duration (ms)',
          value: _duration,
          min: 20,
          max: 800,
          onChanged: (value) => _duration = value,
        ),
        _slider(
          label: 'Shadow darkness',
          value: _shadowDarkness,
          min: 0,
          max: 1,
          fractionDigits: 2,
          onChanged: (value) => _shadowDarkness = value,
        ),
        const SizedBox(height: 8),
        Text('Animation type', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in BouncyButtonAnimationType.values)
              ChoiceChip(
                label: Text(type.name),
                selected: _type == type,
                onSelected: (_) => setState(() => _type = type),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Fill', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final fill in BouncyButtonFill.values)
              ChoiceChip(
                label: Text(fill.name),
                selected: _fill == fill,
                onSelected: (_) => setState(() => _fill = fill),
              ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Spring'),
          subtitle: const Text('Replaces the duration'),
          value: _spring,
          onChanged: (value) => setState(() => _spring = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Leading icon'),
          value: _icon,
          onChanged: (value) => setState(() => _icon = value),
        ),
        const SizedBox(height: 16),
        Text('Color', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in _colors)
              ChoiceChip(
                label: Text(color.name),
                selected: _color == color,
                onSelected: (_) => setState(() => _color = color),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Text('Code', style: textTheme.titleSmall)),
            TextButton.icon(
              onPressed: _copyCode,
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              _code,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
