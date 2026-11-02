# bouncy_button: research notes, November 2026

Tested on Flutter 3.44.9 and Dart 3.12.2. Package data comes from the pub.dev API on 2026-11-02, and download counts cover the previous 30 days. These numbers will go stale, so re-check them before relying on them.

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
- Not confirmed: blog posts give conflicting dates for deprecation and removal. I did not find an official date.
- `m3e_buttons`, a rival released in October 2026, already depends on `material_ui`.

**Springs.** `SpringDescription.withDurationAndBounce` first shipped in Flutter 3.32, which makes real spring physics much easier to tune.

**Material 3 Expressive.** Spring-based motion is the current design direction, but I found no official Flutter SDK support for it. Packages such as `m3e_buttons` and `material_3_expressive` are filling the gap.

## Recommended roadmap

1. **Ship 2.0.0** after checking it on real devices.
2. **Add async support.** Let `onPressed` return a `Future`, showing a loading state and blocking repeat taps until it finishes. This is the clearest demand signal, and double-submit protection is a real need for checkout and form buttons.
3. **Add a `BouncyPressable` wrapper.** Move the press engine into a widget that wraps any child. This enters the largest category, and the button can be rebuilt on top of it.
4. **Add spring physics.** Drive release with a `SpringDescription` so the bounce responds to how far the press got. This would raise the minimum to Flutter 3.32.
5. **Prepare for Material decoupling.** Keep Material use to theme lookup and the optional splash, so a later move to `material_ui` is small. Migrate when Flutter announces a deprecation or 3.47 becomes widely adopted.
6. **Rename generic public names.** `HapticFeedbackType` and `GradientExtension` could collide with other packages. Add prefixed names and deprecate the old ones.
7. **Add CI.** Run analysis and tests on the minimum and latest Flutter versions, since the repository has no automated checks. Add golden tests for visual states.

## Known gaps

- **Not tested on real devices.** Everything ran in Flutter's test environment. Haptics were checked by watching the platform channel, not by feeling them, and animation feel needs a human.
- **Not tested on the minimum Flutter version.** The newer APIs the widget depends on were checked against Flutter's 3.27 source, but the tests only ran on 3.44.9. The tests themselves use newer APIs, so they would need adjusting to run there.
- **Not tested in a browser or with a real screen reader.** Web keyboard activation is wired up but has only been exercised through the standard shortcuts in tests.
- **Pale custom colors** can still produce a vivid depth color, because explicit colors keep the original HSL darkening so existing apps do not change. Set `shadowColor` to override it.
