import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

/// 17. Haptics and sound.
class HapticsDemo extends StatelessWidget {
  const HapticsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final small = BouncyButtonStyle.fromSize(BouncyButtonSize.small);
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: [
        for (final type in BouncyHapticFeedbackType.values)
          BouncyButton(
            onPressed: () {},
            style: small.copyWith(fill: BouncyButtonFill.tonal),
            interaction: BouncyButtonInteraction(hapticFeedbackType: type),
            child: Text(type.name),
          ),
        BouncyButton(
          onPressed: () {},
          style: small,
          interaction: const BouncyButtonInteraction(enableSound: true),
          leading: const Icon(Icons.volume_up),
          child: const Text('Click sound'),
        ),
        BouncyButton(
          onPressed: () {},
          style: small.copyWith(fill: BouncyButtonFill.outlined),
          interaction: const BouncyButtonInteraction(
            enableHapticFeedback: false,
          ),
          child: const Text('Silent'),
        ),
      ],
    );
  }
}

/// 18. Test your buttons.
class TestingDemo extends StatelessWidget {
  const TestingDemo({super.key});

  static const String _code = '''
import 'package:bouncy_button/testing.dart';

testWidgets('Pay is accessible', (tester) async {
  var payments = 0;
  await tester.pumpWidget(MyCheckout(onPay: () async => payments++));
  await expectAccessibleButton(
    tester,
    find.text('Pay'),
    pressCount: () => payments,
  );
});''';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          _code,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
