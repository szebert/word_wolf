import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static final ValueNotifier<FeedbackSettings> feedbackSettingsNotifier =
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
      (value) => feedbackSettingsNotifier.value = FeedbackSettings(
        hapticEnabled: value.$1,
        soundEnabled: value.$2,
      ),
    );
  }

  /// Play feedback if enabled
  static void playFeedback() {
    final feedbackSettings = feedbackSettingsNotifier.value;
    if (feedbackSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    if (feedbackSettings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
