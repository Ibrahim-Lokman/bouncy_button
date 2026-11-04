import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

import '../tour/feature_demos.dart';
import '../widgets/event_log_sheet.dart';
import 'gallery_screen.dart';

/// Every feature of the package, in the same order as the README, each with
/// a live demo. The README's screenshots and GIFs are recorded from these.
class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Every feature, in the same order as the README. Try each one.',
            style: textTheme.bodyLarge,
          ),
        ),
        for (final (index, demo) in featureDemos.indexed)
          FeatureCard(number: index + 1, demo: demo),
        Center(
          child: BouncyButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const GalleryPage()),
            ),
            style: BouncyButtonStyle.outlined,
            trailing: const Icon(Icons.arrow_forward),
            child: const Text('See every option'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// One numbered feature, with its title, a sentence about it, and its demo.
///
/// It stays alive when scrolled off screen, so a demo keeps its choices, and
/// an action it is running finishes.
class FeatureCard extends StatefulWidget {
  const FeatureCard({super.key, required this.number, required this.demo});

  final int number;
  final FeatureDemo demo;

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final number = widget.number;
    final demo = widget.demo;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: Text(
                    '$number',
                    style: const TextStyle(fontSize: 13),
                    textScaler: TextScaler.noScaling,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(demo.title, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(demo.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: demo.builder(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Gallery, which shows every option, on its own page.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Every option'),
        actions: const [EventLogButton()],
      ),
      body: const GalleryScreen(),
    );
  }
}
