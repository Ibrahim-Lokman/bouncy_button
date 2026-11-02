import 'package:flutter/material.dart';

/// What an async button is showing.
enum BouncyButtonStatus {
  /// Ready to be pressed.
  idle,

  /// Waiting for `onPressedAsync` to finish, or `isLoading` is true.
  loading,

  /// `onPressedAsync` finished. Shown for [BouncyButtonFeedback.resultDuration].
  success,

  /// `onPressedAsync` threw. Shown for [BouncyButtonFeedback.resultDuration].
  error,
}

/// How a button shows loading, success, and error.
///
/// Used with `BouncyButton.onPressedAsync` and `BouncyButton.isLoading`. The
/// button keeps its size while the content changes, and ignores presses
/// until it returns to [BouncyButtonStatus.idle].
@immutable
class BouncyButtonFeedback {
  /// Creates a feedback configuration.
  const BouncyButtonFeedback({
    this.loadingBuilder,
    this.successBuilder,
    this.errorBuilder,
    this.showSuccess = true,
    this.showError = true,
    this.shakeOnError = true,
    this.resultDuration = const Duration(milliseconds: 1200),
    this.loadingLabel = 'Loading',
    this.successLabel = 'Done',
    this.errorLabel = 'Failed',
  });

  /// Builds the loading indicator. Defaults to a small progress spinner.
  final WidgetBuilder? loadingBuilder;

  /// Builds the success content. Defaults to a check mark.
  final WidgetBuilder? successBuilder;

  /// Builds the error content. Defaults to an error icon.
  final WidgetBuilder? errorBuilder;

  /// Whether to show success, or return straight to the normal content.
  final bool showSuccess;

  /// Whether to show the error, or return straight to the normal content.
  final bool showError;

  /// Whether the button shakes on error. Skipped when the system asks for
  /// reduced motion.
  final bool shakeOnError;

  /// How long success or error stays visible.
  final Duration resultDuration;

  /// Read by screen readers while loading. Translate it for your app.
  final String loadingLabel;

  /// Read by screen readers on success. Translate it for your app.
  final String successLabel;

  /// Read by screen readers on error. Translate it for your app.
  final String errorLabel;

  /// Returns the screen reader label for [status], or null when idle.
  String? labelFor(BouncyButtonStatus status) => switch (status) {
        BouncyButtonStatus.idle => null,
        BouncyButtonStatus.loading => loadingLabel,
        BouncyButtonStatus.success => successLabel,
        BouncyButtonStatus.error => errorLabel,
      };

  /// Creates a copy with modified fields.
  BouncyButtonFeedback copyWith({
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? successBuilder,
    WidgetBuilder? errorBuilder,
    bool? showSuccess,
    bool? showError,
    bool? shakeOnError,
    Duration? resultDuration,
    String? loadingLabel,
    String? successLabel,
    String? errorLabel,
  }) {
    return BouncyButtonFeedback(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      successBuilder: successBuilder ?? this.successBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      showSuccess: showSuccess ?? this.showSuccess,
      showError: showError ?? this.showError,
      shakeOnError: shakeOnError ?? this.shakeOnError,
      resultDuration: resultDuration ?? this.resultDuration,
      loadingLabel: loadingLabel ?? this.loadingLabel,
      successLabel: successLabel ?? this.successLabel,
      errorLabel: errorLabel ?? this.errorLabel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BouncyButtonFeedback &&
        other.loadingBuilder == loadingBuilder &&
        other.successBuilder == successBuilder &&
        other.errorBuilder == errorBuilder &&
        other.showSuccess == showSuccess &&
        other.showError == showError &&
        other.shakeOnError == shakeOnError &&
        other.resultDuration == resultDuration &&
        other.loadingLabel == loadingLabel &&
        other.successLabel == successLabel &&
        other.errorLabel == errorLabel;
  }

  @override
  int get hashCode => Object.hash(
        loadingBuilder,
        successBuilder,
        errorBuilder,
        showSuccess,
        showError,
        shakeOnError,
        resultDuration,
        loadingLabel,
        successLabel,
        errorLabel,
      );
}
