import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

/// 7. A style for every action.
class StylesDemo extends StatelessWidget {
  const StylesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final medium = BouncyButtonStyle.fromSize(BouncyButtonSize.medium);
    Widget row(List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Wrap(spacing: 10, runSpacing: 14, children: children),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        row([
          BouncyButton(
            onPressed: () {},
            style: medium,
            child: const Text('Pay'),
          ),
          BouncyButton(
            onPressed: () {},
            style: medium.copyWith(fill: BouncyButtonFill.tonal),
            child: const Text('Apply'),
          ),
          BouncyButton(
            onPressed: () {},
            style: medium.copyWith(fill: BouncyButtonFill.outlined),
            child: const Text('Cancel'),
          ),
          BouncyButton(
            onPressed: () {},
            style: medium.copyWith(fill: BouncyButtonFill.ghost),
            child: const Text('Skip'),
          ),
        ]),
        row([
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.destructive,
            leading: const Icon(Icons.delete_outline),
            child: const Text('Delete'),
          ),
          BouncyButton(
            onPressed: () {},
            style: BouncyButtonStyle.destructive
                .copyWith(fill: BouncyButtonFill.outlined),
            child: const Text('Remove'),
          ),
        ]),
        row([
          for (final size in BouncyButtonSize.values)
            BouncyButton(
              onPressed: () {},
              style: BouncyButtonStyle.fromSize(size),
              child: Text(size.name),
            ),
        ]),
        row([
          BouncyButton(
            onPressed: () {},
            style: medium,
            leading: const Icon(Icons.add_shopping_cart),
            child: const Text('Add to cart'),
          ),
          BouncyButton(
            onPressed: () {},
            style: medium.copyWith(fill: BouncyButtonFill.tonal),
            trailing: const Icon(Icons.arrow_forward),
            child: const Text('Continue'),
          ),
        ]),
      ],
    );
  }
}

/// 10. Button groups.
class GroupsDemo extends StatefulWidget {
  const GroupsDemo({super.key});

  @override
  State<GroupsDemo> createState() => _GroupsDemoState();
}

class _GroupsDemoState extends State<GroupsDemo> {
  Set<String> _view = {'week'};
  Set<String> _formats = {'bold'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: BouncyButtonGroup<String>(
            showSelectedIcon: true,
            segments: const [
              BouncyButtonSegment(value: 'day', label: Text('Day')),
              BouncyButtonSegment(value: 'week', label: Text('Week')),
              BouncyButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: _view,
            onSelectionChanged: (selection) =>
                setState(() => _view = selection),
          ),
        ),
        const SizedBox(height: 20),
        BouncyButtonGroup<String>(
          multiSelect: true,
          emptySelectionAllowed: true,
          expand: false,
          style: BouncyButtonStyle.fromSize(BouncyButtonSize.small)
              .copyWith(fill: BouncyButtonFill.outlined),
          segments: const [
            BouncyButtonSegment(
              value: 'bold',
              icon: Icon(Icons.format_bold),
              semanticLabel: 'Bold',
            ),
            BouncyButtonSegment(
              value: 'italic',
              icon: Icon(Icons.format_italic),
              semanticLabel: 'Italic',
            ),
            BouncyButtonSegment(
              value: 'underline',
              icon: Icon(Icons.format_underline),
              semanticLabel: 'Underline',
            ),
          ],
          selected: _formats,
          onSelectionChanged: (selection) =>
              setState(() => _formats = selection),
        ),
      ],
    );
  }
}

/// 11. Glass buttons.
class GlassDemo extends StatelessWidget {
  const GlassDemo({super.key});

  @override
  Widget build(BuildContext context) {
    Widget blob(Color color, double size) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
    final round = BouncyButtonStyle.glass.copyWith(
      shape: BoxShape.circle,
      height: 52,
      padding: const EdgeInsets.all(12),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4527A0), Color(0xFFAD1457), Color(0xFFEF6C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              top: 20,
              start: 30,
              child: blob(const Color(0xFF26C6DA), 90),
            ),
            PositionedDirectional(
              bottom: 10,
              end: 40,
              child: blob(const Color(0xFFFFEE58), 110),
            ),
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  BouncyButton.icon(
                    onPressed: () {},
                    tooltip: 'Previous',
                    style: round,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  BouncyButton(
                    onPressed: () {},
                    style: BouncyButtonStyle.glass,
                    leading: const Icon(Icons.play_arrow),
                    child: const Text('Play'),
                  ),
                  BouncyButton.icon(
                    onPressed: () {},
                    tooltip: 'Next',
                    style: round,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 15. Style your whole app at once.
class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  static const List<(String, Color)> _brands = [
    ('Indigo', Color(0xFF3F51B5)),
    ('Teal', Color(0xFF00796B)),
    ('Orange', Color(0xFFE65100)),
  ];

  Color _brand = _brands.first.$2;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: _brand,
      brightness: _dark ? Brightness.dark : Brightness.light,
      extensions: [
        BouncyButtonTheme(
          primaryStyle: BouncyButtonStyle.fromSize(BouncyButtonSize.medium),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (name, color) in _brands)
              ChoiceChip(
                label: Text(name),
                selected: _brand == color,
                onSelected: (_) => setState(() => _brand = color),
              ),
            FilterChip(
              label: const Text('Dark'),
              selected: _dark,
              onSelected: (value) => setState(() => _dark = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Theme(
          data: theme,
          child: Builder(
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 14,
                children: [
                  BouncyButton(onPressed: () {}, child: const Text('Save')),
                  BouncyButton(
                    onPressed: () {},
                    style: BouncyButtonStyle.tonal,
                    child: const Text('Share'),
                  ),
                  BouncyButton(
                    onPressed: () {},
                    style: BouncyButtonStyle.outlined,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 16. Colors, gradients, and custom looks.
class CustomLooksDemo extends StatelessWidget {
  const CustomLooksDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const base = Color(0xFF00796B);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BouncyButton(
              onPressed: () {},
              style: BouncyButtonStyle(
                gradient: BouncyButtonColors.gradientFromColor(
                  const Color(0xFF303F9F),
                  spread: 0.1,
                ),
              ),
              child: const Text('Gradient'),
            ),
            BouncyButton(
              onPressed: () {},
              style: BouncyButtonStyle(
                backgroundColor: Colors.amber.shade200,
                foregroundColor: Colors.brown.shade900,
                shadowColor: Colors.brown.shade700,
                border: Border.all(color: Colors.brown.shade700, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Retro'),
            ),
            BouncyButton(
              onPressed: () {},
              // The content can change while the button is held.
              builder: (context, isPressed) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isPressed ? Icons.mood : Icons.sentiment_neutral),
                    const SizedBox(width: 8),
                    // Flexible, so large text wraps instead of overflowing.
                    Flexible(child: Text(isPressed ? 'Release me' : 'Hold me')),
                  ],
                ),
              ),
              child: const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Palettes from one color',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        for (final (name, colors) in [
          ('analogous', BouncyButtonColors.analogous(base)),
          ('triadic', BouncyButtonColors.triadic(base)),
          ('monochromatic', BouncyButtonColors.monochromatic(base)),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(width: 120, child: Text(name)),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final color in colors)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
