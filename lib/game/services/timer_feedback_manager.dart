import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../../app_ui/app_config.dart';

/// Manages audio and haptic feedback for timers throughout the application.
/// Ensures resource sharing and proper cleanup.
class TimerFeedbackManager {
  // Static shared resources
  static AudioPlayer? _sharedTickPlayer;
  static AudioPlayer? _sharedTockPlayer;
  static int _instanceCount = 0;
  static bool _hasVibrator = false;

  // Local instance tracking
  bool _isInitialized = false;
  int _lastTickedSecond = -1;

  // Getters for shared players
  AudioPlayer? get _tickPlayer => _sharedTickPlayer;
  AudioPlayer? get _tockPlayer => _sharedTockPlayer;

  /// Initialize audio players and check for vibration support
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Check if vibration is supported
    _hasVibrator = await Vibration.hasVibrator() ?? false;

    try {
      // Increment instance counter
      _instanceCount++;

      // Create the shared players only once
      if (_sharedTickPlayer == null) {
        // Create the audio player
        _sharedTickPlayer = AudioPlayer();
        // Set the release mode to keep the source after playback has completed
        await _sharedTickPlayer?.setReleaseMode(ReleaseMode.stop);
        // Set the source to the asset
        await _sharedTickPlayer?.setSource(AssetSource("audio/tick.mp3"));
      }

      if (_sharedTockPlayer == null) {
        _sharedTockPlayer = AudioPlayer();
        await _sharedTockPlayer?.setReleaseMode(ReleaseMode.stop);
        await _sharedTockPlayer?.setSource(AssetSource("audio/tock.mp3"));
      }

      _isInitialized = true;
    } catch (e) {
      // Do nothing on error
    }
  }

  /// Play tick-tock sound for countdown - alternating between tick and tock
  Future<void> playTickTock(int seconds) async {
    if (!_isInitialized) return;

    final feedbackSettings = AppConfig.feedbackSettings;

    // Only play tick if we haven't played it for this second yet
    if (seconds == _lastTickedSecond) return;
    _lastTickedSecond = seconds;

    // Choose between tick and tock based on even/odd seconds
    final isTick = seconds % 2 == 0;

    // Vibrate with pattern
    if (_hasVibrator && feedbackSettings.hapticEnabled) {
      Vibration.cancel();
      if (isTick) {
        Vibration.vibrate(
          pattern: [0, 100],
          intensities: [0, 200],
        );
      } else {
        Vibration.vibrate(
          pattern: [0, 100],
          intensities: [0, 125],
        );
      }
    }

    // Don't attempt to play if audio isn't ready or sound is disabled
    if (_tickPlayer == null ||
        _tockPlayer == null ||
        !feedbackSettings.soundEnabled) {
      return;
    }

    try {
      if (isTick) {
        // Stop any previous tick audio
        await _tickPlayer!.pause();
        // Reset position to beginning
        await _tickPlayer!.seek(Duration.zero);
        // Use resume instead of play to avoid reloading
        await _tickPlayer!.resume();
      } else {
        await _tockPlayer!.pause();
        await _tockPlayer!.seek(Duration.zero);
        await _tockPlayer!.resume();
      }
    } catch (e) {
      // Do nothing on error
    }
  }

  /// Stop all sounds and vibration
  void stopFeedback() {
    try {
      _tickPlayer?.stop();
      _tockPlayer?.stop();
      Vibration.cancel();
    } catch (e) {
      // Do nothing on error
    }
  }

  /// Reset tick tracking (useful when adjusting timer)
  void resetTickTracking() {
    _lastTickedSecond = -1;
  }

  /// Dispose of resources
  void dispose() {
    stopFeedback();

    // Decrement instance counter
    _instanceCount--;

    // Only dispose when the last instance is disposed
    if (_instanceCount <= 0) {
      try {
        _sharedTickPlayer?.dispose();
        _sharedTockPlayer?.dispose();
        _sharedTickPlayer = null;
        _sharedTockPlayer = null;
        _instanceCount = 0; // Reset counter to prevent negative counts
      } catch (e) {
        // Do nothing on error
      }
    }

    _isInitialized = false;
  }
}
