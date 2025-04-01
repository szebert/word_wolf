part of "feedback_repository.dart";

/// Storage keys for the [FeedbackStorage].
abstract class FeedbackStorageKeys {
  /// Whether the haptic feedback is enabled.
  static const String hapticEnabled = "__haptic_enabled_storage_key__";

  /// Whether the sound is enabled.
  static const String soundEnabled = "__sound_enabled_storage_key__";
}

/// {@template feedback_storage}
/// Storage for the [FeedbackRepository].
/// {@endtemplate}
class FeedbackStorage {
  /// {@macro feedback_storage}
  const FeedbackStorage({
    required final Storage storage,
  }) : _storage = storage;

  final Storage _storage;

  /// Sets the haptic feedback enabled to [enabled] in Storage.
  Future<void> setHapticEnabled({required final bool enabled}) =>
      _storage.write(
        key: FeedbackStorageKeys.hapticEnabled,
        value: enabled.toString(),
      );

  /// Sets the sound enabled to [enabled] in Storage.
  Future<void> setSoundEnabled({required final bool enabled}) => _storage.write(
        key: FeedbackStorageKeys.soundEnabled,
        value: enabled.toString(),
      );

  /// Fetches the feedback settings from Storage.
  Future<(bool hapticEnabled, bool soundEnabled)>
      fetchFeedbackSettings() async => (
            (await _storage.read(key: FeedbackStorageKeys.hapticEnabled))
                    ?.parseBool() ??
                false,
            (await _storage.read(key: FeedbackStorageKeys.soundEnabled))
                    ?.parseBool() ??
                false,
          );
}

extension _BoolFromStringParsing on String {
  bool parseBool() {
    return toLowerCase() == "true";
  }
}
