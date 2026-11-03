# bouncy_button 2.2 to-do list

2.2 went through a checklist of common button mistakes. Each item was either already handled, adopted in 2.2, or left out for a reason. This list keeps what is still open.

## Still needs a person

- [ ] **Real devices:** go through [the release checklist](release-checklist.md) with TalkBack and VoiceOver, a keyboard on macOS and in Chrome, and a real phone for haptics and motion. Nothing in 2.0, 2.1, or 2.2 has been checked this way yet.

## Later, in 3.0

These change how existing apps look or behave, so they wait for a major version. They add to the list in [the 2.1 to-do](todo-2.1.md#later-in-30).

- **Disabled color:** a disabled filled button uses `Colors.grey`, which is brighter than enabled buttons in dark themes. Use the theme's `onSurface` color instead, as the tonal fill already does.
- **Focus ring color of `BouncyPressable`:** it defaults to a fixed blue. Take it from the theme or `BouncyButtonScope`.
- **Text color:** the automatic text color follows `ThemeData.estimateBrightnessForColor`, which picks white on Material red (3.7:1). Pick whichever of white and black has the higher contrast instead.
- **A default timeout,** such as 30 seconds, once apps have had a release to try `timeout`.

## Left out, and why

- **Lint rules** for buttons built from a `GestureDetector`: they need a separate package, with its own releases and Dart version support.
- **A Widgetbook catalog:** the example app's Gallery already shows every option, without a new dependency.
- **Warnings for vague labels, such as "OK":** too many false alarms, since "OK" is often right.
- **A warning for more than one primary button on a screen:** it would need a registry of every button, and would be noisy in lists.
- **Moving focus after a button disappears:** only the app knows where focus should go next.
- **Stopping the spinner under reduce motion:** the spinner is the only sign that something is happening, and it turns in place rather than moving across the screen. Apps that want a still indicator can pass their own `loadingBuilder`.
