import 'package:flutter/widgets.dart';

import 'accessibility_demos.dart';
import 'app_demos.dart';
import 'press_demos.dart';
import 'safety_demos.dart';
import 'style_demos.dart';

/// What the README shows for a feature.
enum FeatureMedia {
  /// A screenshot and a GIF.
  gif,

  /// A screenshot only, for features you can't see move, such as haptics.
  screenshot,

  /// Neither, for features that are code, such as the test helper.
  none,
}

/// One feature of the package, as the Features tab and the README show it.
@immutable
class FeatureDemo {
  const FeatureDemo({
    required this.id,
    required this.title,
    required this.summary,
    required this.builder,
    this.media = FeatureMedia.gif,
    this.recordSize = const Size(400, 320),
  });

  /// The name of the feature's screenshot and GIF, such as `01-3d-press`.
  final String id;

  final String title;

  /// One sentence on what it does.
  final String summary;

  final WidgetBuilder builder;

  final FeatureMedia media;

  /// The size the demo is recorded at, in logical pixels.
  final Size recordSize;
}

/// Every feature, in the same order as the README. Its order and ids are
/// also used to record the README's screenshots and GIFs.
final List<FeatureDemo> featureDemos = [
  FeatureDemo(
    id: '01-3d-press',
    title: 'The 3D press',
    summary: 'The face sinks into a darker layer below it and springs back, '
        'like a real key. Even a quick tap shows the full press.',
    builder: (_) => const PressDemo(),
  ),
  FeatureDemo(
    id: '02-loading',
    title: 'Loading, success, and error',
    summary: 'Give it an async function. It shows a spinner while it runs, '
        'then a tick, or an error and a little shake.',
    builder: (_) => const LoadingDemo(),
  ),
  FeatureDemo(
    id: '03-double-taps',
    title: 'No accidental double taps',
    summary: 'Tap each button three times fast. Protected buttons run once.',
    builder: (_) => const DoubleTapDemo(),
  ),
  FeatureDemo(
    id: '04-any-widget',
    title: 'The bounce on any widget',
    summary: 'Cards, images, and list items get the same press. Tapping the '
        'heart leaves the card still.',
    builder: (_) => const AnyWidgetDemo(),
    recordSize: const Size(400, 340),
  ),
  FeatureDemo(
    id: '05-motion',
    title: 'Springy, lively motion',
    summary: 'Springs that follow your finger, corners that change shape, '
        'and a lift when a mouse hovers.',
    builder: (_) => const MotionDemo(),
  ),
  FeatureDemo(
    id: '06-animations',
    title: 'Press animations',
    summary: 'Sink, shrink, tilt, bounce, fade, or slide, plus ready-made '
        'timings.',
    builder: (_) => const AnimationsDemo(),
  ),
  FeatureDemo(
    id: '07-styles',
    title: 'A style for every action',
    summary: 'Strong for the main action, softer for the rest, red for '
        'deleting. Three sizes, and icons on either side.',
    builder: (_) => const StylesDemo(),
    recordSize: const Size(400, 380),
  ),
  FeatureDemo(
    id: '08-timeout-confirm',
    title: 'Timeouts and confirmation',
    summary: 'Ask before something that can\'t be undone, and give up on a '
        'request that never answers.',
    builder: (_) => const TimeoutConfirmDemo(),
    recordSize: const Size(400, 360),
  ),
  FeatureDemo(
    id: '09-any-button',
    title: 'Protect the buttons you already have',
    summary: 'Wrap a Material or Cupertino button to get the same '
        'protection and states.',
    builder: (_) => const AnyButtonDemo(),
  ),
  FeatureDemo(
    id: '10-groups',
    title: 'Button groups',
    summary: 'Connected buttons for picking one option, or several.',
    builder: (_) => const GroupsDemo(),
  ),
  FeatureDemo(
    id: '11-glass',
    title: 'Glass buttons',
    summary: 'A frosted, see-through face for colorful backgrounds.',
    builder: (_) => const GlassDemo(),
  ),
  FeatureDemo(
    id: '12-accessibility',
    title: 'Built for everyone',
    summary: 'Toggles, menus, icon buttons, and disabled buttons that tell '
        'screen readers and keyboard users what is going on.',
    builder: (_) => const AccessibilityDemo(),
    recordSize: const Size(400, 360),
  ),
  FeatureDemo(
    id: '13-debug-checks',
    title: 'Catch mistakes early',
    summary: 'In debug builds, buttons that would be hard to use print a '
        'warning that says how to fix them.',
    builder: (_) => const DebugChecksDemo(),
    recordSize: const Size(400, 460),
  ),
  FeatureDemo(
    id: '14-control',
    title: 'Press from code, one at a time',
    summary: 'Press a button from anywhere, and let only one of several '
        'actions run at once.',
    builder: (_) => const ControlDemo(),
  ),
  FeatureDemo(
    id: '15-theme',
    title: 'Style your whole app at once',
    summary: 'Buttons follow your theme, so a new brand color or dark mode '
        'changes them all.',
    builder: (_) => const ThemeDemo(),
    recordSize: const Size(400, 340),
  ),
  FeatureDemo(
    id: '16-custom-looks',
    title: 'Colors, gradients, and custom looks',
    summary: 'Gradients, borders, shadows, content that changes while '
        'pressed, and color palettes.',
    builder: (_) => const CustomLooksDemo(),
    recordSize: const Size(400, 360),
  ),
  FeatureDemo(
    id: '17-haptics-sound',
    title: 'Haptics and sound',
    summary: 'A light tap by default, or one of five strengths, and an '
        'optional click sound.',
    builder: (_) => const HapticsDemo(),
    media: FeatureMedia.screenshot,
    recordSize: const Size(400, 240),
  ),
  FeatureDemo(
    id: '18-testing',
    title: 'Test your buttons',
    summary: 'One line in a widget test checks a button for screen readers, '
        'tap size, contrast, and double taps.',
    builder: (_) => const TestingDemo(),
    media: FeatureMedia.none,
  ),
];

/// The short demo at the top of the README.
final FeatureDemo heroDemo = FeatureDemo(
  id: '00-hero',
  title: 'Bouncy Button',
  summary: 'Buttons people want to press.',
  builder: (_) => const HeroDemo(),
  recordSize: const Size(400, 300),
);
