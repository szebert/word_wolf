import "dart:convert";

import "../storage/persistent_storage.dart";

/// {@template app_repository}
/// Repository that handles app-level state persistence.
/// {@endtemplate}
class AppRepository {
  /// {@macro app_repository}
  AppRepository({
    required PersistentStorage persistentStorage,
  }) : _persistentStorage = persistentStorage;

  final PersistentStorage _persistentStorage;
  static const String _kHowToPlayViewedKey = "has_viewed_how_to_play";
  static const String _kAdRemovalKey = "has_paid_for_ad_removal";

  /// Fetches whether the user has viewed the "How to Play" screen.
  Future<bool> fetchHasViewedHowToPlay() async {
    final value = await _persistentStorage.read(key: _kHowToPlayViewedKey);

    if (value == null || value.isEmpty) {
      return false;
    }

    try {
      return jsonDecode(value) as bool;
    } catch (_) {
      return false;
    }
  }

  /// Sets whether the user has viewed the "How to Play" screen.
  Future<void> setHasViewedHowToPlay({required bool hasViewed}) async {
    await _persistentStorage.write(
      key: _kHowToPlayViewedKey,
      value: jsonEncode(hasViewed),
    );
  }

  /// Fetches whether the user has paid for ad removal.
  Future<bool> fetchHasPaidForAdRemoval() async {
    final value = await _persistentStorage.read(key: _kAdRemovalKey);

    if (value == null || value.isEmpty) {
      return false;
    }

    try {
      return jsonDecode(value) as bool;
    } catch (_) {
      return false;
    }
  }

  /// Sets whether the user has paid for ad removal.
  Future<void> setHasPaidForAdRemoval({required bool hasPaid}) async {
    await _persistentStorage.write(
      key: _kAdRemovalKey,
      value: jsonEncode(hasPaid),
    );
  }
}
