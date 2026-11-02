# bouncy_button example

A demo of every `bouncy_button` feature. It needs no network or setup: all data comes from an in-memory mock backend and resets on restart.

```sh
flutter run
```

## Screens

- **Gallery:** every public option, grouped by purpose.
- **Shop:** a mock store with loading, empty, and failed states.
- **Playground:** adjust a button live and copy the code for it.
- **Settings:** control the mock backend and the conditions the demo runs under.

The receipt icon in the app bar opens an event log showing what each button did.

## Scenarios to try

| Try this | Settings to change | What you should see |
| --- | --- | --- |
| Failed load | Turn on **Offline**, then pull to refresh in Shop | An error banner over the products. **Try again** recovers once you're back online |
| Favorite rollback | Set **Failure rate** to 100%, then tap a heart in Shop | The heart changes at once, then reverts with a message |
| Empty state | Turn on **Empty catalog**, then pull to refresh in Shop | An empty message with a **Reload** button |
| Slow network | Set **Latency** to 3000 ms, then reload Shop | A spinner, then the products |
| Large text | Set **Text size** to 3.0x | Buttons grow rather than clip |
| Right to left | Turn on **Right to left** | The whole layout mirrors |
| Reduced motion | Turn on **Reduce motion**, then press buttons | No scale, rotation, or bounce |

## Using the mock backend in tests

Tests can force exact outcomes instead of relying on chance:

```dart
final settings = DemoSettings(latency: Duration.zero);
final backend = MockBackend(settings: settings)
  ..script([MockFailure.network, null]); // Fail once, then succeed.

await tester.pumpWidget(BouncyDemoApp(settings: settings, backend: backend));
```
