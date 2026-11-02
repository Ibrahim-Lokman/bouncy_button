# bouncy_button: research notes, November 2026

Tested on Flutter 3.27.4, the minimum supported version, plus 3.44.9 and 3.47.9, the current stable release. Package data comes from the pub.dev API on 2026-11-02, and download counts cover the previous 30 days. These numbers will go stale, so re-check them before relying on them.

## Summary

- **Version 1.0.4 scored 160/160 on pub.dev, but several documented features did not work.** pub.dev points measure packaging and conventions, not widget behaviour.
- **3D push buttons are a small niche.** Press-effect wrappers and loading buttons get far more downloads, so those are the best directions for growth.
- **Don't migrate to `material_ui` yet.** It requires Flutter 3.47 or later, which would exclude many users. Flutter says current imports keep working for now.

## What 1.0.4 actually did

Each row was measured with a widget test against the 1.0.4 code. `test/behavior_test.dart` keeps these as regression tests.

| Area | Measured in 1.0.4 | Now |
| --- | --- | --- |
| Quick tap | Face moved 0 of 8px on holds up to 90ms, and only 2.63px at 170ms | Full 8px on a 30ms tap |
| Press delay | First movement about 120ms after touch | Immediate, unless a scroll view or long press has to compete for the gesture |
| Width | Always filled its parent, though the docs said it sized to its child | Sizes to its child, or fills a parent that forces a width |
| Inside a `Row` | Threw "A Stack requires bounded constraints" | Works |
| `BouncyButtonTheme` | Never read: a red theme style still rendered the default purple | Applied |
| Keyboard | Took focus, but Enter and Space did nothing | Both activate it, with a focus ring |
| Disabled focus | A disabled button could take focus | It cannot |
| Screen reader | Not announced as a button unless `semanticLabel` was set, and offered scroll actions | Always a button, no scroll actions |
| Reduce motion | Ignored | Respected |
| Large text | At 3x scale, text needing 60px got 36px and was clipped | Button grows |
| Dark theme defaults | Face matched the page, at 1.00:1 contrast, so the button was invisible | Uses `colorScheme.primary` |
| Light theme defaults | Text on the face was 2.65:1, below the 4.5:1 WCAG minimum | Above 4.5:1 |
| `enableSplash` | A quick tap lost its press animation and haptics | Both kept |
| `enableSplash` with `BorderRadiusDirectional` | Threw a type error | Works |
| Disabled while held | Threw "setState() called during build" and stayed stuck down, even after re-enabling | Releases cleanly |
| Long press | Button rose at 500ms while the finger was still down | Stays down until release |
| `bouncy` preset | Scale returned to 1.0 while held, so it showed no scale effect | Holds at `scaleAmount`, then springs past rest on release |
| Disabled gradient | `gradient.scale()` called Flutter's own method, giving 60% opacity rather than darkening | Darkened and opaque |
| Runtime curve change | Ignored | Applied |
| `builder` | Rebuilt on every animation frame (11 builds over 10 frames) | 0 rebuilds from animation frames |
| `BouncyButtonStyle.flat` | 46px in total, under the 48px tap target | 48px |
| Package archive | 28 MB, because it included the demo GIFs | 910 KB |

Two suspicions did **not** hold up. Dragging from the button did not press it by accident in a `PageView`, a vertical `ListView`, or a horizontal list. Scrolling also worked normally in all three. The drag handling was removed for other reasons: it delayed every press by 100ms and caused the scroll actions offered to screen readers.

Other problems found:

- The README install snippet was `bouncy_button: //updated_version`, and two links were literally titled "Link Text".
- `example/test/widget_test.dart` was the unmodified Flutter counter template, and it failed.
- All changelog dates said 2024-01-15, but pub.dev shows 2025-08-15.
- `flutter: ">=3.10.0"` contradicted `sdk: ^3.6.0`, which needs Flutter 3.27.

## The market

Downloads and likes are per package. The feature notes come from a keyword search of each pub.dev page, so treat them as leads rather than confirmed capabilities.

### 3D push buttons (direct competitors)

| Package | Downloads | Likes | Last release | Notes |
| --- | --- | --- | --- | --- |
| `animated_button` | 647 | 169 | 2025-03 | Category leader |
| `pushable_button` | 134 | 50 | 2024-02 | |
| `rcaferati_flutter_awesome_button` | 116 | 4 | 2026-08 | Active. Mentions loading, keyboard, reduced motion, and theming, so it is the closest feature rival |
| **`bouncy_button`** | **101** | **10** | **2025-08** | |
| `nice_buttons` | 70 | 64 | 2023-06 | Mentions progress |
| `flat_3d_button` | 53 | 39 | 2022-07 | |
| `pressable_button` | 15 | 2 | 2026-05 | Mentions loading |

### Press-effect wrappers for any widget

| Package | Downloads | Likes | Last release |
| --- | --- | --- | --- |
| `flutter_bounceable` | 3,729 | 226 | 2025-01 |
| `spring_button` | 2,312 | 42 | 2021-05 |
| `flutter_bounce` | 1,195 | 162 | 2021-06 |
| `bounce` | 1,066 | 52 | 2024-03 |
| `pressable` | 676 | 6 | 2025-09 |

### Loading buttons and double-tap protection

| Package | Downloads | Likes | Last release |
| --- | --- | --- | --- |
| `tap_debouncer` | 17,165 | 120 | 2023-05 |
| `rounded_loading_button_plus` | 2,708 | 79 | 2024-02 |
| `loading_icon_button` | 933 | 41 | 2026-09 |
| `flow_button` | 313 | 2 | 2026-09 |

### What this suggests

- `flutter_bounceable` alone gets about three times the downloads of all the 3D buttons above combined. Several wrappers have not been updated in years: `spring_button` and `flutter_bounce` date from 2021.
- Few of the 3D buttons mention accessibility at all. Being the correct, accessible choice is a realistic position for this package to claim.
- Download counts alone can mislead: some of these packages may be pulled in as dependencies of others rather than chosen directly.

## Platform changes

**Material and Cupertino are moving out of the Flutter SDK.**

- Confirmed: `material_ui` 1.9.0 and `cupertino_ui` 1.1.5 are on pub.dev from the `flutter.dev` publisher, and both require Flutter 3.47 or later and Dart `^3.13.0`.
- Confirmed: Flutter's [issue #184093](https://github.com/flutter/flutter/issues/184093) says the SDK's copies are frozen from the 3.44 cutoff, that nothing should change for now, and that users will eventually need to migrate. Work is tracked in [issue #101479](https://github.com/flutter/flutter/issues/101479).
- Confirmed: Flutter's `master` branch marks `package:flutter/material.dart` as `@Deprecated`, pointing to `material_ui`. Stable 3.47.9 has no such marker yet, and this package analyzes cleanly and passes its tests there.
- Confirmed: `material_ui` defines its own `Theme`, `ThemeExtension`, `InkWell`, and `Material` classes rather than re-exporting the SDK's.
- Flutter's [migration guide](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui) makes 3.47 opt-in and says formal deprecation comes "in an upcoming stable release", with no version or removal date. It tells package authors to treat migrating as a major version bump. It describes a `MaterialUiCompatibilityBridge` that passes theme data to children still calling the SDK's `Theme.of`, but not across public API types. So `BouncyButtonTheme`, a `ThemeExtension` from the SDK, can't go in a `material_ui` theme's `extensions`, and those apps need a non-Material route to theme this package. I read the guide through a summarizing fetch, so check its exact wording before quoting it.
- `m3e_buttons`, a rival released in October 2026, already depends on `material_ui`.

**Springs.** `SpringDescription.withDurationAndBounce` first shipped in Flutter 3.32, which makes real spring physics much easier to tune.

**Material 3 Expressive.** Spring-based motion is the current design direction, but I found no official Flutter SDK support for it. Packages such as `m3e_buttons` and `material_3_expressive` are filling the gap.

## Roadmap progress

Done on the `improve/v2-foundations` branch, unpublished:

| Item | Result |
| --- | --- |
| Async support | `onPressedAsync`, with loading, success, and error states and double-submit protection. It is a separate parameter, not a `FutureOr` `onPressed`, because that would silently put existing callers like `() => Navigator.push(...)` into a loading state |
| `BouncyPressable` | A wrapper for any widget, built on a shared press core with no Material imports. Also adds nested-press handling and an opt-in `BouncyExclusiveScope` |
| Spring physics | Built with `SpringDescription.withDampingRatio`, which exists on 3.27, so the minimum did not need to rise to 3.32 |
| Material decoupling | `BouncyButtonScope` themes buttons without the Material `Theme`. A `material_ui` bridge package is deferred until Flutter sets a deprecation date |
| Gaps from the rival review | Icons, size presets, tonal, outlined, ghost, and glass fills, hover lift, shape morphing, button groups, and press sounds |

Still open:

1. **Check on real devices before publishing.** See the known gaps below.
2. **Rename generic public names.** `HapticFeedbackType` and `GradientExtension` could collide with other packages. Add prefixed names and deprecate the old ones.
3. **Add CI.** Run analysis and tests on 3.27 and the latest stable, as was done by hand here. Add golden tests for visual states.
4. **Move to `material_ui`** once Flutter sets a deprecation date, as a major version, which Flutter's migration guide recommends for packages.

## Known gaps

- **Not tested on real devices.** Everything ran in Flutter's test environment. Haptics were checked by watching the platform channel, not by feeling them, and animation feel needs a human.
- **Not tested in a browser or with a real screen reader.** Web keyboard activation is wired up but has only been exercised through the standard shortcuts in tests. The example app was built for the web and its first screen checked in headless Chrome, but nobody has interacted with it in a browser.
- **Not checked by eye:** springs, hover lift, shape morphing, the error shake, and glass blur are tested by measuring positions and decorations, not by looking at them. Glass in particular needs a visual check over real content.
- **Press sounds** were checked by watching the platform channel. Whether a click is heard depends on the platform and device settings.
- **Pale custom colors** can still produce a vivid depth color, because explicit colors keep the original HSL darkening so existing apps do not change. Set `shadowColor` to override it.
