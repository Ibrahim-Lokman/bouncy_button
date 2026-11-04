import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

import '../state/warning_log.dart';

/// 12. Built for everyone.
class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({super.key});

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  bool _muted = false;
  String _sort = 'Newest';
  bool _sortOpen = false;

  void _setSortOpen(bool open) {
    // The menu can close as the screen goes away.
    if (mounted) {
      setState(() => _sortOpen = open);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medium = BouncyButtonStyle.fromSize(BouncyButtonSize.medium);
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // The label stays "Mute". Screen readers add checked or not checked.
        BouncyButton(
          isSelected: _muted,
          onPressed: () => setState(() => _muted = !_muted),
          style: medium.copyWith(
            fill: _muted ? BouncyButtonFill.filled : BouncyButtonFill.tonal,
          ),
          leading: Icon(_muted ? Icons.volume_off : Icons.volume_up),
          child: const Text('Mute'),
        ),
        // Screen readers hear whether the menu is open.
        MenuAnchor(
          onOpen: () => _setSortOpen(true),
          onClose: () => _setSortOpen(false),
          menuChildren: [
            for (final option in ['Newest', 'Price', 'Rating'])
              MenuItemButton(
                onPressed: () => setState(() => _sort = option),
                child: Text(option),
              ),
          ],
          builder: (context, menu, _) => BouncyButton(
            expanded: _sortOpen,
            onPressed: () => menu.isOpen ? menu.close() : menu.open(),
            style: medium.copyWith(fill: BouncyButtonFill.outlined),
            trailing: Icon(_sortOpen ? Icons.expand_less : Icons.expand_more),
            child: Text('Sort: $_sort'),
          ),
        ),
        // The tooltip names it for screen readers, and shows on hover, long
        // press, and keyboard focus.
        BouncyButton.icon(
          onPressed: () {},
          tooltip: 'Share',
          icon: const Icon(Icons.share),
        ),
        // Says why it can't be used: on long press, hover, and to screen
        // readers.
        BouncyButton(
          disabledReason: 'Sign in to save items',
          style: medium,
          leading: const Icon(Icons.bookmark_border),
          child: const Text('Save for later'),
        ),
      ],
    );
  }
}

/// 13. Catch mistakes early.
class DebugChecksDemo extends StatefulWidget {
  const DebugChecksDemo({super.key});

  @override
  State<DebugChecksDemo> createState() => _DebugChecksDemoState();
}

class _DebugChecksDemoState extends State<DebugChecksDemo> {
  bool _showMistakes = false;

  /// The first sentence of a warning, without the package name.
  static String _shorten(String warning) {
    final text = warning.replaceFirst('bouncy_button: ', '');
    final end = text.indexOf('. ');
    return end == -1 ? text : text.substring(0, end + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show buttons with mistakes'),
          value: _showMistakes,
          onChanged: (value) => setState(() => _showMistakes = value),
        ),
        if (_showMistakes)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // An icon with no label: screen readers can't name it.
                BouncyButton(onPressed: () {}, child: const Icon(Icons.share)),
                // White on yellow is hard to read.
                BouncyButton(
                  onPressed: () {},
                  style: const BouncyButtonStyle(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Buy'),
                ),
                // Too small to tap easily.
                BouncyButton(
                  onPressed: () {},
                  style: const BouncyButtonStyle(
                    height: 28,
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Tiny'),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: bouncyWarnings,
            builder: (context, warnings, _) {
              const style = TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 12,
                height: 1.4,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debug console',
                    style: TextStyle(
                      color: Color(0xFF9CDCFE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (warnings.isEmpty)
                    const Text('No warnings yet.', style: style),
                  for (final warning in warnings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsetsDirectional.only(top: 1, end: 6),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFFCA28),
                              size: 15,
                            ),
                          ),
                          Expanded(
                            child: Text(_shorten(warning), style: style),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
