import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/mock_backend.dart';
import '../state/demo_scope.dart';
import '../tour/accessibility_demos.dart';
import '../widgets/demo_section.dart';

/// Shows every public option of the package, grouped by purpose.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _toggleEnabled = true;
  final BouncyButtonController _controller = BouncyButtonController();
  int _cooldownPresses = 0;
  int _plainPresses = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _externalLoading = false;
  Set<String> _view = {'week'};
  Set<String> _formats = {'bold'};

  VoidCallback _log(String name) =>
      () => DemoScope.read(context).log.add('$name pressed');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _constructors(),
        _animationTypes(),
        _animationPresets(),
        _motion(),
        _stylePresets(),
        _fills(),
        _sizes(),
        _icons(),
        _accessibility(),
        _colors(),
        _sizing(),
        _states(),
        _async(),
        _protection(),
        _destructive(),
        _interactions(),
        _groups(),
        _glass(),
        _pressables(),
        _themed(context),
        _colorUtilities(),
      ],
    );
  }

  Widget _constructors() {
    return DemoSection(
      title: 'Constructors',
      subtitle: 'Each one takes its default style from the theme or a preset.',
      children: [
        BouncyButton(
          onPressed: _log('BouncyButton'),
          child: const Text('BouncyButton'),
        ),
        BouncyButton.primary(
          onPressed: _log('Primary'),
          child: const Text('Primary'),
        ),
        BouncyButton.secondary(
          onPressed: _log('Secondary'),
          child: const Text('Secondary'),
        ),
        BouncyButton.tertiary(
          onPressed: _log('Tertiary'),
          child: const Text('Tertiary'),
        ),
      ],
    );
  }

  Widget _animationTypes() {
    return DemoSection(
      title: 'Animation types',
      subtitle: 'Every type also pushes the face into its depth.',
      children: [
        for (final type in BouncyButtonAnimationType.values)
          BouncyButton(
            onPressed: _log('Animation ${type.name}'),
            animation: BouncyButtonAnimation(
              type: type,
              duration: const Duration(milliseconds: 150),
            ),
            child: Text(type.name),
          ),
      ],
    );
  }

  Widget _animationPresets() {
    return DemoSection(
      title: 'Animation presets',
      subtitle: 'Ready-made timing and curves.',
      children: [
        BouncyButton(
          onPressed: _log('Quick'),
          animation: BouncyButtonAnimation.quick,
          child: const Text('Quick'),
        ),
        BouncyButton(
          onPressed: _log('Smooth'),
          animation: BouncyButtonAnimation.smooth,
          child: const Text('Smooth'),
        ),
        BouncyButton(
          onPressed: _log('Bouncy'),
          animation: BouncyButtonAnimation.bouncy,
          child: const Text('Bouncy'),
        ),
      ],
    );
  }

  Widget _motion() {
    return DemoSection(
      title: 'Springs and shape',
      subtitle: 'A spring reverses smoothly if you press again mid-release. '
          'With a mouse, buttons also rise slightly on hover.',
      children: [
        for (final (name, spring) in [
          ('snappy', BouncyPressSpring.snappy),
          ('bouncy', BouncyPressSpring.bouncy),
          ('gentle', BouncyPressSpring.gentle),
        ])
          BouncyButton(
            onPressed: _log('Spring $name'),
            animation: BouncyButtonAnimation(spring: spring),
            child: Text('Spring $name'),
          ),
        BouncyButton(
          onPressed: _log('springy preset'),
          animation: BouncyButtonAnimation.springy,
          child: const Text('springy preset'),
        ),
        BouncyButton(
          onPressed: _log('Morph pill'),
          style: BouncyButtonStyle.pill.copyWith(
            pressedBorderRadius: BorderRadius.circular(8),
          ),
          animation: const BouncyButtonAnimation(
            duration: Duration(milliseconds: 160),
          ),
          child: const Text('Pill to square'),
        ),
        BouncyButton(
          onPressed: _log('Morph circle'),
          semanticLabel: 'Circle to rounded square',
          style: BouncyButtonStyle.circle.copyWith(
            pressedBorderRadius: BorderRadius.circular(14),
          ),
          animation: const BouncyButtonAnimation(
            spring: BouncyPressSpring.snappy,
          ),
          child: const Icon(Icons.play_arrow),
        ),
        BouncyButton(
          onPressed: _log('No hover lift'),
          interaction: const BouncyButtonInteraction(hoverLift: 0),
          child: const Text('hoverLift: 0'),
        ),
      ],
    );
  }

  Widget _stylePresets() {
    return DemoSection(
      title: 'Style presets',
      subtitle: 'Static values on BouncyButtonStyle.',
      children: [
        BouncyButton(
          onPressed: _log('Style primary'),
          style: BouncyButtonStyle.primary,
          child: const Text('primary'),
        ),
        BouncyButton(
          onPressed: _log('Style secondary'),
          style: BouncyButtonStyle.secondary,
          child: const Text('secondary'),
        ),
        BouncyButton(
          onPressed: _log('Style flat'),
          style: BouncyButtonStyle.flat,
          child: const Text('flat'),
        ),
        BouncyButton(
          onPressed: _log('Style pill'),
          style: BouncyButtonStyle.pill,
          child: const Text('pill'),
        ),
        BouncyButton(
          onPressed: _log('Style circle'),
          semanticLabel: 'Circle style',
          style: BouncyButtonStyle.circle,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _fills() {
    return DemoSection(
      title: 'Fills',
      subtitle: 'From most to least prominent, so secondary actions do not '
          'compete with the main one.',
      children: [
        for (final fill in BouncyButtonFill.values)
          BouncyButton(
            onPressed: _log('Fill ${fill.name}'),
            style: BouncyButtonStyle.fromSize(BouncyButtonSize.medium)
                .copyWith(fill: fill),
            child: Text(fill.name),
          ),
        BouncyButton(
          onPressed: _log('Outlined teal'),
          style: BouncyButtonStyle.outlined.copyWith(
            // Lighter in dark themes, so the text stays readable.
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.teal.shade200
                : Colors.teal.shade700,
          ),
          child: const Text('outlined, custom color'),
        ),
        for (final fill in BouncyButtonFill.values)
          BouncyButton(
            onPressed: null,
            style: BouncyButtonStyle(fill: fill, height: 48, elevation: 4),
            child: Text('${fill.name} disabled'),
          ),
      ],
    );
  }

  Widget _sizes() {
    return DemoSection(
      title: 'Sizes',
      subtitle: 'BouncyButtonStyle.fromSize scales height, depth, padding, '
          'and text together. Every size is at least 48 tall.',
      children: [
        for (final size in BouncyButtonSize.values)
          BouncyButton(
            onPressed: _log('Size ${size.name}'),
            style: BouncyButtonStyle.fromSize(size),
            leading: const Icon(Icons.bolt),
            child: Text(size.name),
          ),
        BouncyButton(
          onPressed: _log('simple'),
          style: BouncyButtonStyle.simple(
            color: Colors.deepOrange.shade900,
            width: 180,
          ),
          child: const Text('BouncyButtonStyle.simple'),
        ),
      ],
    );
  }

  Widget _icons() {
    return DemoSection(
      title: 'Icons',
      subtitle: 'leading and trailing, which swap sides in right-to-left '
          'layouts.',
      children: [
        BouncyButton(
          onPressed: _log('Leading'),
          leading: const Icon(Icons.add_shopping_cart),
          child: const Text('Add to cart'),
        ),
        BouncyButton(
          onPressed: _log('Trailing'),
          style: BouncyButtonStyle.tonal,
          trailing: const Icon(Icons.arrow_forward),
          child: const Text('Continue'),
        ),
        BouncyButton(
          onPressed: _log('Both'),
          style: BouncyButtonStyle.outlined,
          leading: const Icon(Icons.download),
          trailing: const Icon(Icons.expand_more),
          gap: 12,
          child: const Text('gap: 12'),
        ),
      ],
    );
  }

  Widget _accessibility() {
    return DemoSection(
      title: 'Accessibility',
      subtitle: 'Screen readers hear names and states, keyboard users see '
          'tooltips on focus, and small buttons still have room to tap.',
      children: [
        // The toggle, menu, icon, and disabled buttons, shared with the
        // Features tab.
        const AccessibilityDemo(),
        BouncyButton(
          onPressed: _log('minWidth'),
          style: BouncyButtonStyle.fromSize(BouncyButtonSize.medium)
              .copyWith(minWidth: 160),
          child: const Text('OK'),
        ),
        // Drawn small, but the tap area is 48 by 48.
        BouncyButton(
          onPressed: _log('Small with a tap area'),
          style: const BouncyButtonStyle(
            height: 32,
            elevation: 3,
            padding: EdgeInsets.symmetric(horizontal: 12),
            textStyle: TextStyle(fontSize: 13),
            minTapTarget: 48,
          ),
          child: const Text('minTapTarget'),
        ),
      ],
    );
  }

  Widget _colors() {
    return DemoSection(
      title: 'Color and decoration',
      subtitle: 'Fields of BouncyButtonStyle that change how the face looks.',
      children: [
        BouncyButton(
          onPressed: _log('backgroundColor'),
          style: BouncyButtonStyle(backgroundColor: Colors.teal.shade700),
          child: const Text('backgroundColor'),
        ),
        BouncyButton(
          onPressed: _log('foregroundColor'),
          style: const BouncyButtonStyle(
            backgroundColor: Color(0xFFFFF59D),
            foregroundColor: Color(0xFF4E342E),
          ),
          child: const Text('foregroundColor'),
        ),
        BouncyButton(
          onPressed: _log('hslColor'),
          style: const BouncyButtonStyle(
            hslColor: HSLColor.fromAHSL(1, 280, 0.6, 0.45),
          ),
          child: const Text('hslColor'),
        ),
        BouncyButton(
          onPressed: _log('gradient'),
          style: const BouncyButtonStyle(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFC2185B)],
            ),
            shadowColor: Color(0xFF4A148C),
          ),
          child: const Text('gradient'),
        ),
        BouncyButton(
          onPressed: _log('shadowDarkness'),
          style: const BouncyButtonStyle(
            backgroundColor: Colors.indigo,
            shadowDarkness: 0.12,
          ),
          child: const Text('shadowDarkness'),
        ),
        BouncyButton(
          onPressed: _log('border'),
          style: BouncyButtonStyle(
            backgroundColor: Colors.white,
            shadowColor: Colors.black54,
            border: Border.all(color: Colors.black87, width: 2),
          ),
          child: const Text('border'),
        ),
        BouncyButton(
          onPressed: _log('shadows'),
          style: BouncyButtonStyle(
            backgroundColor: Colors.blueGrey.shade700,
            shadows: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
          ),
          child: const Text('shadows'),
        ),
        BouncyButton(
          onPressed: _log('decoration'),
          style: const BouncyButtonStyle(
            decoration: BoxDecoration(
              color: Color(0xFF004D40),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            shadowDecoration: BoxDecoration(
              color: Color(0xFF00251A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          child: const Text('decoration'),
        ),
        BouncyButton(
          onPressed: _log('opacity'),
          style: BouncyButtonStyle(
            backgroundColor: Colors.teal.shade700,
            opacity: 0.7,
          ),
          child: const Text('opacity'),
        ),
        BouncyButton(
          onPressed: _log('transform'),
          style: BouncyButtonStyle(
            backgroundColor: Colors.deepOrange.shade900,
            transform: Matrix4.rotationZ(-0.04),
            transformAlignment: Alignment.center,
          ),
          child: const Text('transform'),
        ),
      ],
    );
  }

  Widget _sizing() {
    return DemoSection(
      title: 'Sizing',
      subtitle: 'A button fits its child unless told otherwise.',
      children: [
        BouncyButton(
          onPressed: _log('Fits child'),
          child: const Text('Fits child'),
        ),
        BouncyButton(
          onPressed: _log('Width 160'),
          style: const BouncyButtonStyle(width: 160, height: 44),
          child: const Text('Width 160'),
        ),
        BouncyButton(
          onPressed: _log('Full width'),
          style: const BouncyButtonStyle(width: double.infinity),
          child: const Text('double.infinity'),
        ),
        Row(
          children: [
            Expanded(
              child: BouncyButton(
                onPressed: _log('Expanded left'),
                child: const Text('Expanded'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BouncyButton(
                onPressed: _log('Expanded right'),
                child: const Text('Expanded'),
              ),
            ),
          ],
        ),
        BouncyButton(
          onPressed: _log('Aligned'),
          style: const BouncyButtonStyle(
            width: double.infinity,
            alignment: AlignmentDirectional.centerStart,
          ),
          child: const Text('alignment'),
        ),
      ],
    );
  }

  Widget _states() {
    return DemoSection(
      title: 'States',
      subtitle: 'Disable a button by clearing onPressed or setting enabled.',
      children: [
        const BouncyButton(onPressed: null, child: Text('onPressed: null')),
        BouncyButton(
          onPressed: _log('Never'),
          enabled: false,
          child: const Text('enabled: false'),
        ),
        const BouncyButton(
          onPressed: null,
          style: BouncyButtonStyle(disabledColor: Color(0xFF8D6E63)),
          child: Text('disabledColor'),
        ),
        const BouncyButton(
          onPressed: null,
          style: BouncyButtonStyle(
            gradient: LinearGradient(colors: [Colors.indigo, Colors.teal]),
          ),
          child: Text('Disabled gradient'),
        ),
        BouncyButton(
          onPressed: _log('Toggled'),
          enabled: _toggleEnabled,
          animation: const BouncyButtonAnimation(animateOpacity: true),
          child: Text(_toggleEnabled ? 'Enabled' : 'Disabled'),
        ),
        OutlinedButton(
          onPressed: () => setState(() => _toggleEnabled = !_toggleEnabled),
          child: const Text('Toggle the button'),
        ),
      ],
    );
  }

  /// Runs a mock request, which follows the latency and failure rate set in
  /// Settings.
  Future<void> _request(String name) async {
    final scope = DemoScope.read(context);
    await scope.backend.fetchProducts();
    scope.log.add('$name finished');
  }

  void _failed(Object error, StackTrace stackTrace) {
    final message =
        error is MockApiException ? error.message : error.toString();
    DemoScope.read(context).log.add('Failed: $message');
  }

  Widget _async() {
    return DemoSection(
      title: 'Async buttons',
      subtitle: 'onPressedAsync shows loading, then success or an error, and '
          'ignores presses meanwhile. Requests follow the latency and failure '
          'rate in Settings.',
      children: [
        BouncyButton(
          onPressedAsync: () => _request('Save'),
          onError: _failed,
          child: const Text('Save'),
        ),
        BouncyButton(
          onPressedAsync: () async {
            await Future<void>.delayed(const Duration(milliseconds: 600));
            throw const MockApiException(MockFailure.server);
          },
          onError: _failed,
          child: const Text('Always fails'),
        ),
        BouncyButton(
          onPressedAsync: () => _request('Quiet save'),
          onError: _failed,
          feedback: const BouncyButtonFeedback(showSuccess: false),
          child: const Text('showSuccess: false'),
        ),
        BouncyButton(
          onPressedAsync: () => _request('Custom feedback'),
          onError: _failed,
          feedback: BouncyButtonFeedback(
            loadingBuilder: (_) => const Text('Sending...'),
            successBuilder: (_) => const Text('Sent!'),
            resultDuration: const Duration(seconds: 2),
          ),
          child: const Text('Custom builders'),
        ),
        BouncyButton(
          onPressed: _log('isLoading button'),
          isLoading: _externalLoading,
          child: const Text('isLoading'),
        ),
        OutlinedButton(
          onPressed: () => setState(() => _externalLoading = !_externalLoading),
          child: Text(_externalLoading ? 'Stop loading' : 'Start loading'),
        ),
      ],
    );
  }

  Widget _protection() {
    return DemoSection(
      title: 'Double-tap protection',
      subtitle: 'Tap each button twice quickly. Requests follow the latency '
          'and failure rate in Settings.',
      children: [
        BouncyButton(
          onPressed: () => setState(() => _plainPresses++),
          style: BouncyButtonStyle.tonal,
          child: Text('No cooldown: $_plainPresses'),
        ),
        BouncyButton(
          onPressed: () => setState(() => _cooldownPresses++),
          cooldown: const Duration(milliseconds: 800),
          child: Text('cooldown 800 ms: $_cooldownPresses'),
        ),
        BouncyAsyncBuilder(
          onPressed: () => _request('ElevatedButton'),
          onError: _failed,
          builder: (context, onPressed, status) => ElevatedButton(
            onPressed: onPressed,
            child: Text(
              status == BouncyButtonStatus.idle
                  ? 'ElevatedButton'
                  : 'ElevatedButton: ${status.name}',
            ),
          ),
        ),
        BouncyAsyncBuilder(
          onPressed: () => _request('CupertinoButton'),
          onError: _failed,
          disableWhileBusy: true,
          builder: (context, onPressed, status) => CupertinoButton.filled(
            onPressed: onPressed,
            child: status == BouncyButtonStatus.loading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text('CupertinoButton'),
          ),
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BouncyButton(
                controller: _controller,
                onPressedAsync: () => _request('Controlled'),
                onError: _failed,
                feedback: const BouncyButtonFeedback(loadingText: 'Saving…'),
                child: const Text('Controlled'),
              ),
              OutlinedButton(
                onPressed: _controller.press,
                child: const Text('Press from code'),
              ),
              TextButton(
                onPressed: _controller.reset,
                child: const Text('Reset'),
              ),
              Text('Status: ${_controller.status.name}'),
            ],
          ),
        ),
        BouncyExclusiveScope(
          lockDuringLoading: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('lockDuringLoading: one sign-in at a time'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  BouncyButton(
                    onPressedAsync: () => _request('Google sign-in'),
                    onError: _failed,
                    style: BouncyButtonStyle.outlined,
                    leading: const Icon(Icons.g_mobiledata),
                    child: const Text('Google'),
                  ),
                  BouncyButton(
                    onPressedAsync: () => _request('Apple sign-in'),
                    onError: _failed,
                    style: BouncyButtonStyle.outlined,
                    leading: const Icon(Icons.apple),
                    child: const Text('Apple'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _destructive() {
    return DemoSection(
      title: 'Destructive, tooltips, and tap targets',
      subtitle: 'Error colors work with every fill. Small buttons can keep a '
          '48 pixel tap area.',
      children: [
        for (final fill in [
          BouncyButtonFill.filled,
          BouncyButtonFill.tonal,
          BouncyButtonFill.outlined,
          BouncyButtonFill.ghost,
        ])
          BouncyButton(
            onPressed: _log('Delete ${fill.name}'),
            style: BouncyButtonStyle.destructive.copyWith(fill: fill),
            leading: const Icon(Icons.delete_outline),
            child: Text('Delete (${fill.name})'),
          ),
        BouncyButton(
          onPressed: _log('Tooltip'),
          tooltip: 'Share this page',
          style: BouncyButtonStyle.circle,
          child: const Icon(Icons.share),
        ),
        BouncyButton(
          onPressed: _log('Small with tap target'),
          tooltip: 'Close',
          style: const BouncyButtonStyle(
            width: 32,
            height: 28,
            elevation: 3,
            padding: EdgeInsets.zero,
            minTapTarget: 48,
          ),
          child: const Icon(Icons.close, size: 18),
        ),
      ],
    );
  }

  Widget _interactions() {
    return DemoSection(
      title: 'Interaction',
      subtitle: 'Haptics, ripple, long press, and accessibility.',
      children: [
        for (final type in BouncyHapticFeedbackType.values)
          BouncyButton(
            onPressed: _log('Haptic ${type.name}'),
            interaction: BouncyButtonInteraction(hapticFeedbackType: type),
            child: Text('Haptic ${type.name}'),
          ),
        BouncyButton(
          onPressed: _log('No haptics'),
          interaction:
              const BouncyButtonInteraction(enableHapticFeedback: false),
          child: const Text('No haptics'),
        ),
        BouncyButton(
          onPressed: _log('Splash'),
          interaction: const BouncyButtonInteraction(
            enableSplash: true,
            splashColor: Colors.white30,
            highlightColor: Colors.white10,
          ),
          child: const Text('Splash'),
        ),
        BouncyButton(
          onPressed: _log('Tap'),
          onLongPress: _log('Long press'),
          child: const Text('Tap or long press'),
        ),
        BouncyButton(
          onPressed: _log('Cursor'),
          interaction: const BouncyButtonInteraction(
            cursor: SystemMouseCursors.grab,
            hoverColor: Colors.white24,
            focusColor: Colors.amber,
          ),
          child: const Text('Cursor, hover, focus'),
        ),
        BouncyButton(
          onPressed: _log('Semantic label'),
          semanticLabel: 'Add to favorites',
          style: BouncyButtonStyle.circle,
          child: const Icon(Icons.favorite),
        ),
        BouncyButton(
          onPressed: _log('Builder'),
          builder: (context, isPressed) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(isPressed ? 'Pressed!' : 'builder'),
            ),
          ),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _pressables() {
    final scheme = Theme.of(context).colorScheme;
    Widget tile(String label, Color color) => DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(label, style: TextStyle(color: scheme.onPrimary)),
          ),
        );

    return DemoSection(
      title: 'BouncyPressable',
      subtitle: 'The press effect on any widget. Hold the inner tile: the '
          'outer one stays still.',
      children: [
        BouncyPressable(
          onTap: _log('Pressable tile'),
          child: tile('Any widget', scheme.primary),
        ),
        BouncyPressable(
          onTap: _log('Pressable tile'),
          onLongPress: _log('Pressable long press'),
          scaleFactor: 0.85,
          haptic: BouncyHapticFeedbackType.medium,
          child: tile('scaleFactor 0.85', scheme.tertiary),
        ),
        BouncyPressable(
          onTap: _log('Outer tile'),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Outer', style: TextStyle(color: scheme.onSecondary)),
                  const SizedBox(height: 12),
                  BouncyPressable(
                    onTap: _log('Inner tile'),
                    child: tile('Inner', scheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        BouncyExclusiveScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('BouncyExclusiveScope: press both with two fingers'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  BouncyButton(
                    onPressed: _log('Exclusive A'),
                    child: const Text('A'),
                  ),
                  BouncyButton(
                    onPressed: _log('Exclusive B'),
                    child: const Text('B'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groups() {
    return DemoSection(
      title: 'BouncyButtonGroup',
      subtitle: 'Connected buttons for choosing one option, or several. '
          'showSelectedIcon marks the choice with more than color.',
      children: [
        BouncyButtonGroup<String>(
          showSelectedIcon: true,
          segments: const [
            BouncyButtonSegment(value: 'day', label: Text('Day')),
            BouncyButtonSegment(value: 'week', label: Text('Week')),
            BouncyButtonSegment(value: 'month', label: Text('Month')),
          ],
          selected: _view,
          onSelectionChanged: (selection) {
            setState(() => _view = selection);
            DemoScope.read(context).log.add('View: ${selection.join(', ')}');
          },
        ),
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
          onSelectionChanged: (selection) {
            setState(() => _formats = selection);
            DemoScope.read(context).log.add(
                'Formats: ${selection.isEmpty ? 'none' : selection.join(', ')}');
          },
        ),
      ],
    );
  }

  Widget _glass() {
    return DemoSection(
      title: 'Glass',
      subtitle: 'A translucent, blurred face. It turns solid with the high '
          'contrast setting, and is best kept out of long lists.',
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6F61),
                  Color(0xFF6A1B9A),
                  Color(0xFF00897B)
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  BouncyButton(
                    onPressed: _log('Glass'),
                    style: BouncyButtonStyle.glass,
                    leading: const Icon(Icons.play_arrow),
                    child: const Text('Glass'),
                  ),
                  BouncyButton(
                    onPressed: _log('Glass tinted'),
                    style: BouncyButtonStyle.glass.copyWith(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text('Tinted'),
                  ),
                  BouncyButton(
                    onPressed: _log('Glass circle'),
                    semanticLabel: 'Glass circle',
                    style: BouncyButtonStyle.circle.copyWith(
                      fill: BouncyButtonFill.glass,
                    ),
                    child: const Icon(Icons.favorite),
                  ),
                ],
              ),
            ),
          ),
        ),
        BouncyButton(
          onPressed: _log('Sound'),
          interaction: const BouncyButtonInteraction(enableSound: true),
          leading: const Icon(Icons.volume_up),
          child: const Text('Press sound'),
        ),
      ],
    );
  }

  Widget _themed(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: const [
          BouncyButtonTheme(
            primaryStyle: BouncyButtonStyle(
              height: 48,
              backgroundColor: Color(0xFFAD1457),
            ),
            secondaryStyle: BouncyButtonStyle(
              height: 48,
              backgroundColor: Color(0xFF00695C),
            ),
            tertiaryStyle: BouncyButtonStyle(
              height: 46,
              elevation: 2,
              backgroundColor: Color(0xFF37474F),
            ),
            defaultAnimation: BouncyButtonAnimation.smooth,
          ),
        ],
      ),
      child: DemoSection(
        title: 'BouncyButtonTheme',
        subtitle: 'These buttons have no style of their own.',
        children: [
          BouncyButton.primary(
            onPressed: _log('Themed primary'),
            child: const Text('Themed primary'),
          ),
          BouncyButton.secondary(
            onPressed: _log('Themed secondary'),
            child: const Text('Themed secondary'),
          ),
          BouncyButton.tertiary(
            onPressed: _log('Themed tertiary'),
            child: const Text('Themed tertiary'),
          ),
        ],
      ),
    );
  }

  Widget _colorUtilities() {
    const base = Color(0xFF3F51B5);
    Widget palette(String name, List<Color> colors) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final color in colors)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const SizedBox.square(dimension: 28),
                ),
            ],
          ),
        ],
      );
    }

    return DemoSection(
      title: 'BouncyButtonColors',
      subtitle: 'Palette helpers, generated from one color.',
      children: [
        palette('complementary', [
          base,
          BouncyButtonColors.complementary(base),
        ]),
        palette('analogous', BouncyButtonColors.analogous(base)),
        palette('triadic', BouncyButtonColors.triadic(base)),
        palette('tetradic', BouncyButtonColors.tetradic(base)),
        palette('monochromatic', BouncyButtonColors.monochromatic(base)),
        BouncyButton(
          onPressed: _log('gradientFromColor'),
          style: BouncyButtonStyle(
            // A darker base and a small spread keep white text readable on
            // the light end.
            gradient: BouncyButtonColors.gradientFromColor(
              const Color(0xFF303F9F),
              spread: 0.1,
            ),
          ),
          child: const Text('gradientFromColor'),
        ),
      ],
    );
  }
}
