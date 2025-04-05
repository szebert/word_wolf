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
}
