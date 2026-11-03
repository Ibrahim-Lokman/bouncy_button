# Release checklist

Run through this before publishing a new version. The automated checks catch most problems, but screen readers, haptics, and the feel of the animations can only be checked by a person on a real device.

## 1. Automated checks

- [ ] `flutter analyze` and `flutter test`, in the package and in `example/`.
- [ ] The same on the oldest supported Flutter (3.27) and the latest stable release. CI runs both on every push.
- [ ] The screenshot tests, on macOS with the Flutter version named in `test/goldens/golden_test.dart`:

  ```sh
  flutter test --tags golden
  ```

  If a change to the look was intended, look at the new images before you accept them:

  ```sh
  flutter test --tags golden --update-goldens
  ```

- [ ] `flutter pub publish --dry-run` reports no warnings.

## 2. Screen readers

Use the example app's Gallery and Checkout screens, with TalkBack on Android and VoiceOver on iOS.

| Try | You should hear |
|---|---|
| A plain button | Its text, then "button". Once, not twice. |
| A button with an icon and text | One stop that reads the text. The icon isn't a separate stop. |
| Pay in Checkout | "Loading", or the loading text, as it starts. Then "Done" or "Failed". |
| The icon-only Share button | "Share". |
| The Mute toggle | "Mute", then "checked" or "not checked". The word "Mute" doesn't change. |
| The Sort menu button | "expanded" or "collapsed". |
| The disabled button with a reason | Its text, "disabled" or "dimmed", then the reason. |
| A button group segment | Its label, "checked" or "not checked", and its position in the group. |
| A product card in Shop | The card, and then its favorite button as a separate stop. |

## 3. Keyboard only

On macOS and in Chrome, without touching the mouse:

- [ ] Tab reaches every enabled button in order, and skips disabled ones.
- [ ] The focus ring is clearly visible on every fill, in light and dark themes.
- [ ] Enter and Space press the focused button.
- [ ] Holding Enter presses it once, not repeatedly.
- [ ] A button with a tooltip shows it while focused.
- [ ] In Checkout, pressing Enter in the card number field pays once.

## 4. Slow and failing networks

In the example's Settings, set the latency to 3 seconds:

- [ ] Double tap Pay. The card is charged once.
- [ ] Turn on offline mode and pay. The error shows, and Try again works.
- [ ] Set the next outcome to "hang". After the timeout, the error shows, and a retry still charges the card only once.

## 5. Motion, haptics, and contrast

On a real phone:

- [ ] The press, the spring, and the success and error states feel right.
- [ ] Haptics play on a press, success, and error, unless turned off.
- [ ] With the system's reduce motion setting on, buttons don't scale, spring, or shake.
- [ ] With high contrast on (Increase Contrast on iOS), the focus ring is thicker and glass buttons are solid.

## 6. Publish

- [ ] Update the version in `pubspec.yaml` and add a `CHANGELOG.md` entry.
- [ ] Commit, then tag the release as `vX.Y.Z`.
- [ ] `flutter pub publish`.
- [ ] Push the commit and the tag, then check that pub.dev shows the new version and that CI passes.
