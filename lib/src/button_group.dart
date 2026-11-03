import 'package:flutter/material.dart';

import 'bouncy_button_widget.dart';
import 'enums.dart';
import 'interactions.dart';
import 'styles.dart';

/// One option in a [BouncyButtonGroup].
@immutable
class BouncyButtonSegment<T> {
  /// Creates a segment.
  const BouncyButtonSegment({
    required this.value,
    this.label,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
  }) : assert(
          label != null || icon != null,
          'A segment needs a label, an icon, or both.',
        );

  /// The value this segment selects.
  final T value;

  /// The text, typically a [Text].
  final Widget? label;

  /// An icon shown before the label, or alone.
  final Widget? icon;

  /// Whether this segment can be selected.
  final bool enabled;

  /// The screen reader label, which replaces the label's own. Use it for
  /// segments that only have an icon.
  final String? semanticLabel;
}

/// A row of connected buttons for choosing one option, or several.
///
/// ```dart
/// BouncyButtonGroup<String>(
///   segments: const [
///     BouncyButtonSegment(value: 'day', label: Text('Day')),
///     BouncyButtonSegment(value: 'week', label: Text('Week')),
///     BouncyButtonSegment(value: 'month', label: Text('Month')),
///   ],
///   selected: {view},
///   onSelectionChanged: (selection) => setState(() => view = selection.first),
/// )
/// ```
///
/// Selected segments use a filled face and the rest a tonal one. Only the
/// outer corners are rounded, on the correct sides in right-to-left layouts.
/// Screen readers announce each segment's selected state.
class BouncyButtonGroup<T> extends StatelessWidget {
  /// Creates a button group.
  const BouncyButtonGroup({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelect = false,
    this.emptySelectionAllowed = false,
    this.style,
    this.selectedStyle,
    this.interaction,
    this.spacing = 2,
    this.expand = true,
  }) : assert(segments.length > 0, 'A group needs at least one segment.');

  /// The options, in order.
  final List<BouncyButtonSegment<T>> segments;

  /// The values of the selected segments.
  final Set<T> selected;

  /// Called with the new selection when a segment is pressed. If null, the
  /// group is disabled.
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Whether more than one segment can be selected.
  final bool multiSelect;

  /// Whether the last selected segment can be deselected.
  final bool emptySelectionAllowed;

  /// The style of unselected segments. Defaults to a medium tonal style.
  /// Its corner radius sets the group's outer corners.
  final BouncyButtonStyle? style;

  /// The style of selected segments. Defaults to [style] with a filled face.
  final BouncyButtonStyle? selectedStyle;

  /// Interaction settings for every segment. Defaults to a selection click
  /// haptic.
  final BouncyButtonInteraction? interaction;

  /// The gap between segments.
  final double spacing;

  /// Whether segments share the available width equally. Ignored where the
  /// width is unbounded, such as in a horizontal scroll view.
  final bool expand;

  void _handlePressed(T value) {
    final next = Set<T>.of(selected);
    if (next.contains(value)) {
      if (next.length == 1 && !emptySelectionAllowed) {
        return;
      }
      next.remove(value);
    } else {
      if (!multiSelect) {
        next.clear();
      }
      next.add(value);
    }
    onSelectionChanged?.call(next);
  }

  /// The corners of the segment at [index]: only the outer ones are round.
  BorderRadiusDirectional _corners(int index, Radius radius) {
    final first = index == 0;
    final last = index == segments.length - 1;
    return BorderRadiusDirectional.only(
      topStart: first ? radius : Radius.zero,
      bottomStart: first ? radius : Radius.zero,
      topEnd: last ? radius : Radius.zero,
      bottomEnd: last ? radius : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = style ??
        BouncyButtonStyle.fromSize(BouncyButtonSize.medium)
            .copyWith(fill: BouncyButtonFill.tonal);
    final chosen =
        selectedStyle ?? base.copyWith(fill: BouncyButtonFill.filled);
    final radius = (base.borderRadius ?? BorderRadius.circular(12))
        .resolve(Directionality.of(context))
        .topLeft;
    final segmentInteraction = interaction ??
        const BouncyButtonInteraction(
          hapticFeedbackType: BouncyHapticFeedbackType.selection,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final share = expand && constraints.hasBoundedWidth;
        final children = <Widget>[];
        for (var i = 0; i < segments.length; i++) {
          final segment = segments[i];
          final isSelected = selected.contains(segment.value);
          final enabled = onSelectionChanged != null && segment.enabled;
          // Merged, so screen readers find the state on the button. Checked,
          // as in Flutter's SegmentedButton, so the off state is read too.
          Widget button = MergeSemantics(
            child: Semantics(
              checked: isSelected,
              inMutuallyExclusiveGroup: !multiSelect,
              child: BouncyButton(
                onPressed: enabled ? () => _handlePressed(segment.value) : null,
                style: (isSelected ? chosen : base).copyWith(
                  borderRadius: _corners(i, radius),
                ),
                interaction: segmentInteraction,
                semanticLabel: segment.semanticLabel,
                leading: segment.label != null ? segment.icon : null,
                child: segment.label ?? segment.icon!,
              ),
            ),
          );
          if (share) {
            button = Expanded(child: button);
          }
          if (i > 0) {
            children.add(SizedBox(width: spacing));
          }
          children.add(button);
        }
        return Semantics(
          container: true,
          explicitChildNodes: true,
          child: Row(
            mainAxisSize: share ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        );
      },
    );
  }
}
