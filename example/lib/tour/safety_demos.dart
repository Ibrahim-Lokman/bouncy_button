import 'dart:async';

import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 2. Loading, success, and error.
class LoadingDemo extends StatelessWidget {
  const LoadingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          BouncyButton(
            onPressedAsync: () =>
                Future<void>.delayed(const Duration(milliseconds: 1200)),
            feedback: const BouncyButtonFeedback(loadingText: 'Paying…'),
            style: BouncyButtonStyle.primary.copyWith(width: double.infinity),
            child: const Text(r'Pay $24.00'),
          ),
          const SizedBox(height: 16),
          BouncyButton(
            onPressedAsync: () async {
              await Future<void>.delayed(const Duration(milliseconds: 900));
              throw StateError('The card was declined.');
            },
            // Handled, so the demo shows the error state without a report.
            onError: (error, stackTrace) {},
            style: BouncyButtonStyle.tonal.copyWith(width: double.infinity),
            child: const Text('Try a failing payment'),
          ),
        ],
      ),
    );
  }
}

/// 3. No accidental double taps.
class DoubleTapDemo extends StatefulWidget {
  const DoubleTapDemo({super.key});

  @override
  State<DoubleTapDemo> createState() => _DoubleTapDemoState();
}

class _DoubleTapDemoState extends State<DoubleTapDemo> {
  int _plain = 0;
  int _cooled = 0;
  int _charges = 0;

  Widget _row(Widget button, String result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 180, child: button),
          const SizedBox(width: 12),
          Expanded(child: Text(result)),
        ],
      ),
    );
  }

  String _times(int count) => '$count ${count == 1 ? 'time' : 'times'}';

  @override
  Widget build(BuildContext context) {
    final style = BouncyButtonStyle.fromSize(BouncyButtonSize.medium)
        .copyWith(width: double.infinity);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row(
          BouncyButton(
            onPressed: () => setState(() => _plain++),
            style: style.copyWith(fill: BouncyButtonFill.tonal),
            child: const Text('No protection'),
          ),
          'Ran ${_times(_plain)}',
        ),
        _row(
          BouncyButton(
            onPressed: () => setState(() => _cooled++),
            cooldown: const Duration(milliseconds: 800),
            style: style,
            child: const Text('With cooldown'),
          ),
          'Ran ${_times(_cooled)}',
        ),
        _row(
          BouncyButton(
            onPressedAsync: () async {
              setState(() => _charges++);
              await Future<void>.delayed(const Duration(milliseconds: 700));
            },
            style: style.copyWith(
              backgroundColor: Colors.teal.shade700,
              shadowDarkness: BouncyButtonStyle.shadowLight,
            ),
            child: const Text('Pay (async)'),
          ),
          'Charged ${_times(_charges)}',
        ),
      ],
    );
  }
}

/// 8. Timeouts and confirmation.
class TimeoutConfirmDemo extends StatefulWidget {
  const TimeoutConfirmDemo({super.key});

  @override
  State<TimeoutConfirmDemo> createState() => _TimeoutConfirmDemoState();
}

class _TimeoutConfirmDemoState extends State<TimeoutConfirmDemo> {
  String _result = '';

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            BouncyButton(
              onPressedAsync: () async {
                await Future<void>.delayed(const Duration(milliseconds: 800));
                if (mounted) {
                  setState(() => _result = 'Account deleted.');
                }
              },
              confirm: _confirmDelete,
              style: BouncyButtonStyle.destructive,
              leading: const Icon(Icons.delete_forever),
              child: const Text('Delete account'),
            ),
            BouncyButton(
              // A request that never answers.
              onPressedAsync: () => Completer<void>().future,
              timeout: const Duration(seconds: 2),
              onError: (error, stackTrace) => setState(
                () => _result = error is TimeoutException
                    ? 'Gave up after 2 seconds.'
                    : 'Something went wrong.',
              ),
              style: BouncyButtonStyle.tonal,
              child: const Text('Slow request'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(_result),
      ],
    );
  }
}

/// 9. Protect the buttons you already have.
class AnyButtonDemo extends StatefulWidget {
  const AnyButtonDemo({super.key});

  @override
  State<AnyButtonDemo> createState() => _AnyButtonDemoState();
}

class _AnyButtonDemoState extends State<AnyButtonDemo> {
  int _sent = 0;

  Future<void> _send() async {
    setState(() => _sent++);
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BouncyAsyncBuilder(
          onPressed: _send,
          builder: (context, onPressed, status) => ElevatedButton(
            onPressed: onPressed,
            child: Text(switch (status) {
              BouncyButtonStatus.loading => 'Sending…',
              BouncyButtonStatus.success => 'Sent',
              BouncyButtonStatus.error => 'Failed',
              BouncyButtonStatus.idle => 'Send with Material',
            }),
          ),
        ),
        const SizedBox(height: 16),
        BouncyAsyncBuilder(
          onPressed: _send,
          disableWhileBusy: true,
          builder: (context, onPressed, status) => CupertinoButton.filled(
            onPressed: onPressed,
            child: status == BouncyButtonStatus.loading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text('Send with Cupertino'),
          ),
        ),
        const SizedBox(height: 16),
        Text('Sent $_sent ${_sent == 1 ? 'time' : 'times'}'),
      ],
    );
  }
}

/// 14. Press from code, one at a time.
class ControlDemo extends StatefulWidget {
  const ControlDemo({super.key});

  @override
  State<ControlDemo> createState() => _ControlDemoState();
}

class _ControlDemoState extends State<ControlDemo> {
  final BouncyButtonController _save = BouncyButtonController();

  @override
  void dispose() {
    _save.dispose();
    super.dispose();
  }

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 1500));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BouncyButton(
              controller: _save,
              onPressedAsync: _wait,
              feedback: const BouncyButtonFeedback(loadingText: 'Saving…'),
              // Wide enough for the loading text, as the button keeps its
              // size while loading.
              style: BouncyButtonStyle.fromSize(BouncyButtonSize.medium)
                  .copyWith(minWidth: 130),
              child: const Text('Save'),
            ),
            OutlinedButton(
              onPressed: _save.press,
              child: const Text('Press Save from code'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Only one sign-in at a time:'),
        const SizedBox(height: 8),
        BouncyExclusiveScope(
          lockDuringLoading: true,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              BouncyButton(
                onPressedAsync: _wait,
                style: BouncyButtonStyle.outlined,
                leading: const Icon(Icons.g_mobiledata),
                child: const Text('Google'),
              ),
              BouncyButton(
                onPressedAsync: _wait,
                style: BouncyButtonStyle.outlined,
                leading: const Icon(Icons.apple),
                child: const Text('Apple'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
