import "package:flutter/material.dart";
import "package:flutter/services.dart";

/// Feedback settings for app UI components across the app
class FeedbackSettings {
  /// Feedback settings
  const FeedbackSettings({
    required this.hapticEnabled,
    required this.soundEnabled,
  });

  /// Whether haptic feedback is enabled
  final bool hapticEnabled;

  /// Whether sound feedback is enabled
  final bool soundEnabled;

  /// Copy with new values
  FeedbackSettings copyWith({
    bool? hapticEnabled,
    bool? soundEnabled,
  }) {
    return FeedbackSettings(
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

/// Configuration settings for app UI components across the app
class AppConfig {
  /// Single notifier that holds UI settings
  static final ValueNotifier<FeedbackSettings> _feedbackSettingsNotifier =
      ValueNotifier(
    const FeedbackSettings(
      hapticEnabled: true,
      soundEnabled: true,
    ),
  );

  /// Initialize UI configuration from persisted setting values
  static void initialize(
    Future<(bool, bool)> Function() fetchFeedbackSettings,
  ) {
    fetchFeedbackSettings().then(
      (value) => _feedbackSettingsNotifier.value = FeedbackSettings(
        hapticEnabled: value.$1,
        soundEnabled: value.$2,
      ),
    );
  }

  /// Play feedback if enabled
  static void playFeedback() {
    final feedbackSettings = _feedbackSettingsNotifier.value;
    if (feedbackSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    if (feedbackSettings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Get the current feedback settings
  static FeedbackSettings get feedbackSettings =>
      _feedbackSettingsNotifier.value;

  /// Set the sound settings
  static void setSoundEnabled(bool enabled) {
    _feedbackSettingsNotifier.value = feedbackSettings.copyWith(
      soundEnabled: enabled,
    );
  }

  /// Set the haptic settings
  static void setHapticEnabled(bool enabled) {
    _feedbackSettingsNotifier.value = feedbackSettings.copyWith(
      hapticEnabled: enabled,
    );
  }
}
