import "dart:async";

import "package:equatable/equatable.dart";

import "../storage/storage.dart";

part "feedback_storage.dart";

/// {@template feedback_failure}
/// A base failure for the feedback repository failures.
/// {@endtemplate}
abstract class FeedbackFailure with EquatableMixin implements Exception {
  /// {@macro feedback_failure}
  const FeedbackFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  List<Object> get props => <Object>[error];
}

/// {@template toggle_sound_failure}
/// Thrown when toggling sound fails.
/// {@endtemplate}
class ToggleSoundFailure extends FeedbackFailure {
  /// {@macro toggle_sound_failure}
  const ToggleSoundFailure(super.error);
}

/// {@template toggle_haptic_failure}
/// Thrown when toggling haptic feedback fails.
/// {@endtemplate}
class ToggleHapticFailure extends FeedbackFailure {
  /// {@macro toggle_haptic_failure}
  const ToggleHapticFailure(super.error);
}

/// {@template fetch_feedback_settings_failure}
/// Thrown when fetching feedback settings fails.
/// {@endtemplate}
class FetchFeedbackSettingsFailure extends FeedbackFailure {
  /// {@macro fetch_feedback_settings_failure}
  const FetchFeedbackSettingsFailure(super.error);
}

/// {@template feedback_repository}
/// A repository that manages feedback settings.
///
/// Access to the device's sound and haptic feedback can be toggled with
/// [toggleSound] and [toggleHaptic] respectively, and checked with
/// [fetchFeedbackSettings].
/// {@endtemplate}
class FeedbackRepository {
  /// {@macro feedback_repository}
  FeedbackRepository({
    required final FeedbackStorage storage,
  }) : _storage = storage;

  final FeedbackStorage _storage;

  /// Toggles the haptic feedback based on the [enable].
  ///
  /// When [enable] is true, marks the haptic feedback setting as enabled.
  ///
  /// When [enable] is false, marks the haptic feedback setting as disabled.
  Future<void> toggleHaptic({required final bool enable}) async {
    try {
      await _storage.setHapticEnabled(enabled: enable);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ToggleHapticFailure(error), stackTrace);
    }
  }

  /// Toggles the sound based on the [enable].
  ///
  /// When [enable] is true, marks the sound setting as enabled.
  ///
  /// When [enable] is false, marks the sound setting as disabled.
  Future<void> toggleSound({required final bool enable}) async {
    try {
      await _storage.setSoundEnabled(enabled: enable);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ToggleSoundFailure(error), stackTrace);
    }
  }

  /// Returns feedback settings.
  Future<(bool hapticEnabled, bool soundEnabled)>
      fetchFeedbackSettings() async {
    try {
      return await _storage.fetchFeedbackSettings();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FetchFeedbackSettingsFailure(error),
        stackTrace,
      );
    }
  }
}
