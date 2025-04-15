import "dart:convert";

import "../storage/persistent_storage.dart";

/// {@template app_details}
/// Contains all persistent app-level state.
/// {@endtemplate}
class AppRepositoryDetails {
  /// {@macro app_details}
  const AppRepositoryDetails({
    required this.hasViewedHowToPlay,
    required this.hasPaidForAdRemoval,
    required this.completedGamesCount,
    this.lastCompletedGame,
  });

  /// Whether the user has viewed the "How to Play" screen.
  final bool hasViewedHowToPlay;

  /// Whether the user has paid for ad removal.
  final bool hasPaidForAdRemoval;

  /// Number of completed games.
  final int completedGamesCount;

  /// Date of the last completed game, null if no games completed.
  final DateTime? lastCompletedGame;
}

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
  static const String _kCompletedGamesCountKey = "completed_games_count";
  static const String _kLastCompletedGameKey = "last_completed_game";

  /// Fetches all app details in a single call.
  Future<AppRepositoryDetails> fetchAppDetails() async {
    // Read all values in parallel
    final howToPlayFuture = _persistentStorage.read(key: _kHowToPlayViewedKey);
    final adRemovalFuture = _persistentStorage.read(key: _kAdRemovalKey);
    final completedGamesFuture =
        _persistentStorage.read(key: _kCompletedGamesCountKey);
    final lastCompletedGameFuture =
        _persistentStorage.read(key: _kLastCompletedGameKey);

    // Wait for all futures to complete
    final results = await Future.wait([
      howToPlayFuture,
      adRemovalFuture,
      completedGamesFuture,
      lastCompletedGameFuture,
    ]);

    // Parse results
    bool hasViewedHowToPlay = false;
    bool hasPaidForAdRemoval = false;
    int completedGamesCount = 0;
    DateTime? lastCompletedGame;

    // Parse howToPlay
    final howToPlayValue = results[0];
    if (howToPlayValue != null && howToPlayValue.isNotEmpty) {
      try {
        hasViewedHowToPlay = jsonDecode(howToPlayValue) as bool;
      } catch (_) {
        // Keep default value
      }
    }

    // Parse adRemoval
    final adRemovalValue = results[1];
    if (adRemovalValue != null && adRemovalValue.isNotEmpty) {
      try {
        hasPaidForAdRemoval = jsonDecode(adRemovalValue) as bool;
      } catch (_) {
        // Keep default value
      }
    }

    // Parse completedGames
    final completedGamesValue = results[2];
    if (completedGamesValue != null && completedGamesValue.isNotEmpty) {
      try {
        completedGamesCount = jsonDecode(completedGamesValue) as int;
      } catch (_) {
        // Keep default value
      }
    }

    // Parse lastCompletedGameDate
    final lastCompletedGameValue = results[3];
    if (lastCompletedGameValue != null && lastCompletedGameValue.isNotEmpty) {
      try {
        final milliseconds = jsonDecode(lastCompletedGameValue) as int;
        lastCompletedGame = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      } catch (_) {
        // Keep default value
      }
    }

    return AppRepositoryDetails(
      hasViewedHowToPlay: hasViewedHowToPlay,
      hasPaidForAdRemoval: hasPaidForAdRemoval,
      completedGamesCount: completedGamesCount,
      lastCompletedGame: lastCompletedGame,
    );
  }

  /// Sets whether the user has viewed the "How to Play" screen.
  Future<void> setHasViewedHowToPlay({required bool hasViewed}) async {
    await _persistentStorage.write(
      key: _kHowToPlayViewedKey,
      value: jsonEncode(hasViewed),
    );
  }

  /// Sets whether the user has paid for ad removal.
  Future<void> setHasPaidForAdRemoval({required bool hasPaid}) async {
    await _persistentStorage.write(
      key: _kAdRemovalKey,
      value: jsonEncode(hasPaid),
    );
  }

  /// Sets the number of completed games.
  Future<void> setCompletedGamesCount(
      {required int completedGamesCount}) async {
    await _persistentStorage.write(
      key: _kCompletedGamesCountKey,
      value: jsonEncode(completedGamesCount),
    );
  }

  /// Sets the date of the last completed game.
  Future<void> setLastCompletedGame(DateTime date) async {
    await _persistentStorage.write(
      key: _kLastCompletedGameKey,
      value: jsonEncode(date.millisecondsSinceEpoch),
    );
  }
}
