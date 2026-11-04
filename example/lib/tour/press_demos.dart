import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

/// 1. The 3D press.
class PressDemo extends StatelessWidget {
  const PressDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        BouncyButton(onPressed: () {}, child: const Text('Press me')),
        BouncyButton(
          onPressed: () {},
          style: BouncyButtonStyle(
            backgroundColor: Colors.teal.shade700,
            // A lighter depth, as the default turns black on dark colors.
            shadowDarkness: BouncyButtonStyle.shadowLight,
            elevation: 12,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text('Deep press'),
        ),
        BouncyButton(
          onPressed: () {},
          style: BouncyButtonStyle.pill.copyWith(
            backgroundColor: Colors.deepOrange.shade900,
          ),
          child: const Text('Pill'),
        ),
        BouncyButton.icon(
          onPressed: () {},
          tooltip: 'Like',
          style: BouncyButtonStyle.circle.copyWith(
            backgroundColor: Colors.pink.shade700,
          ),
          icon: const Icon(Icons.favorite),
        ),
      ],
    );
  }
}

/// 4. The bounce on any widget.
class AnyWidgetDemo extends StatefulWidget {
  const AnyWidgetDemo({super.key});

  @override
  State<AnyWidgetDemo> createState() => _AnyWidgetDemoState();
}

class _AnyWidgetDemoState extends State<AnyWidgetDemo> {
  int _opened = 0;
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: BouncyPressable(
            onTap: () => setState(() => _opened++),
            // The card holds another control, so it isn't one button.
            semanticsButton: false,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 110,
                    color: scheme.primaryContainer,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.headphones,
                            size: 56,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        PositionedDirectional(
                          top: 4,
                          end: 4,
                          child: BouncyPressable(
                            onTap: () => setState(() => _favorite = !_favorite),
                            isSelected: _favorite,
                            semanticLabel: 'Favorite',
                            scaleFactor: 0.8,
                            focusBorderRadius: BorderRadius.circular(24),
                            child: SizedBox.square(
                              dimension: 48,
                              child: Icon(
                                _favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _favorite
                                    ? Colors.red.shade700
                                    : scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Studio Headphones', style: textTheme.titleMedium),
                        Text(r'$129.00', style: textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Card opened $_opened ${_opened == 1 ? 'time' : 'times'}'),
      ],
    );
  }
}

/// 5. Springy, lively motion.
class MotionDemo extends StatelessWidget {
  const MotionDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final medium = BouncyButtonStyle.fromSize(BouncyButtonSize.medium);
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: [
        for (final (name, spring) in [
          ('Bouncy', BouncyPressSpring.bouncy),
          ('Snappy', BouncyPressSpring.snappy),
          ('Gentle', BouncyPressSpring.gentle),
        ])
          BouncyButton(
            onPressed: () {},
            animation: BouncyButtonAnimation(spring: spring),
            style: medium,
            child: Text(name),
          ),
        BouncyButton(
          onPressed: () {},
          style: medium.copyWith(
            backgroundColor: Colors.teal.shade700,
            // A lighter depth, as the default turns black on dark colors.
            shadowDarkness: BouncyButtonStyle.shadowLight,
            borderRadius: BorderRadius.circular(28),
            pressedBorderRadius: BorderRadius.circular(6),
          ),
          child: const Text('Shape morph'),
        ),
        BouncyButton(
          onPressed: () {},
          style: medium.copyWith(fill: BouncyButtonFill.tonal),
          interaction: const BouncyButtonInteraction(hoverLift: 4),
          child: const Text('Hover me'),
        ),
      ],
    );
  }
}

/// 6. Press animations.
class AnimationsDemo extends StatelessWidget {
  const AnimationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final small = BouncyButtonStyle.fromSize(BouncyButtonSize.small);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            for (final type in BouncyButtonAnimationType.values)
              BouncyButton(
                onPressed: () {},
                animation: BouncyButtonAnimation(
                  type: type,
                  duration: const Duration(milliseconds: 150),
                ),
                style: small,
                child: Text(type.name),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Presets', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            for (final (name, animation) in [
              ('quick', BouncyButtonAnimation.quick),
              ('smooth', BouncyButtonAnimation.smooth),
              ('springy', BouncyButtonAnimation.springy),
              ('bouncy', BouncyButtonAnimation.bouncy),
            ])
              BouncyButton(
                onPressed: () {},
                animation: animation,
                style: small.copyWith(fill: BouncyButtonFill.tonal),
                child: Text(name),
              ),
          ],
        ),
      ],
    );
  }
}

/// The short demo at the top of the README: a press, a payment, and a card.
class HeroDemo extends StatelessWidget {
  const HeroDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BouncyButton(onPressed: () {}, child: const Text('Press me')),
            BouncyButton.icon(
              onPressed: () {},
              tooltip: 'Like',
              style: BouncyButtonStyle.circle.copyWith(
                backgroundColor: Colors.pink.shade700,
              ),
              icon: const Icon(Icons.favorite),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 260,
          child: BouncyButton(
            onPressedAsync: () =>
                Future<void>.delayed(const Duration(milliseconds: 1200)),
            feedback: const BouncyButtonFeedback(loadingText: 'Paying…'),
            style: BouncyButtonStyle.primary.copyWith(
              width: double.infinity,
              backgroundColor: Colors.teal.shade700,
              // A lighter depth, as the default turns black on dark colors.
              shadowDarkness: BouncyButtonStyle.shadowLight,
            ),
            child: const Text(r'Pay $24.00'),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: BouncyPressable(
            onTap: () {},
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.headphones, color: scheme.primary, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Studio Headphones')),
                    const Text(r'$129'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
