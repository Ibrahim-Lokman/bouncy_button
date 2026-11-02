# Contributing to bouncy_button

Thanks for helping improve bouncy_button. Bug reports, ideas, and pull requests are all welcome.

By taking part, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting bugs and suggesting features

- **Bugs:** [open a bug report](https://github.com/Ibrahim-Lokman/bouncy_button/issues/new?template=bug_report.yml). A short code sample that shows the problem is the most useful thing you can include.
- **Ideas:** [open a feature request](https://github.com/Ibrahim-Lokman/bouncy_button/issues/new?template=feature_request.yml). Describe the problem you're trying to solve, not only the solution.
- **Security issues:** don't open a public issue. Follow the [security policy](SECURITY.md) instead.

For a large change, open an issue first so we can agree on the approach before you spend time on it.

## Setting up

You need Flutter 3.27 or later, the package's minimum.

```sh
git clone https://github.com/Ibrahim-Lokman/bouncy_button.git
cd bouncy_button
flutter pub get
```

The example app shows every feature and runs on mock data, so it needs no setup:

```sh
cd example
flutter run
```

## How the code is organized

| Path | What it holds |
| --- | --- |
| `lib/src/press_core.dart` | The press behavior shared by every widget: gestures, animation, focus, semantics, and haptics. It must not import Material. |
| `lib/src/bouncy_button_widget.dart` | `BouncyButton`, built on the press core |
| `lib/src/pressable.dart` | `BouncyPressable`, the wrapper for any widget |
| `lib/src/styles.dart`, `animations.dart`, `interactions.dart` | The configuration classes |
| `test/` | Package tests, grouped by feature |
| `example/` | The demo app and its tests |

## Making a change

1. Create a branch from `main`.
2. Make your change, and add or update tests for any change in behavior.
3. Document new public members. The analyzer requires doc comments on public API.
4. Add a line to `CHANGELOG.md` under the next version.
5. Run the checks below, then open a pull request.

### Checks

All of these must pass:

```sh
dart format .
flutter analyze
flutter test
cd example && flutter analyze && flutter test
```

If your change uses a Flutter API that might be newer than 3.27, also run the tests with Flutter 3.27. A version manager such as [fvm](https://fvm.app) makes this easy.

### What reviewers look for

- **Accessibility:** buttons must stay usable with a keyboard and a screen reader, and respect the system "reduce motion" setting.
- **Compatibility:** avoid breaking changes in a minor release. If one is needed, explain why in the pull request.
- **Visual changes:** include before and after screenshots, ideally in both light and dark themes.

## License

bouncy_button is released under the [MIT License](LICENSE). By contributing, you agree that your contributions are licensed under it too.
