import 'dart:convert';

import '../../storage/persistent_storage.dart';
import '../models/game.dart';

/// {@template game_repository}
/// Repository for managing game settings with persistent storage.
/// {@endtemplate}
class GameRepository {
  /// {@macro game_repository}
  GameRepository({
    required PersistentStorage persistentStorage,
  }) : _persistentStorage = persistentStorage;

  final PersistentStorage _persistentStorage;
  static const String _kGameSettingsKey = 'game_settings';

  /// Loads game settings from persistent storage
  Future<Map<String, dynamic>> getGameSettings() async {
    try {
      final settingsJson =
          await _persistentStorage.read(key: _kGameSettingsKey);
      if (settingsJson == null || settingsJson.isEmpty) {
        return {};
      }
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      // If parsing fails, return empty settings
      return {};
    }
  }

  /// Saves game settings to persistent storage
  Future<void> saveGameSettings({
    required int? customWolfCount,
    required bool randomizeWolfCount,
    required bool autoAssignWolves,
    required int discussionTimeInSeconds,
    required double wordPairSimilarity,
    required bool wolfRevengeEnabled,
  }) async {
    try {
      final settings = {
        'customWolfCount': customWolfCount,
        'randomizeWolfCount': randomizeWolfCount,
        'autoAssignWolves': autoAssignWolves,
        'discussionTimeInSeconds': discussionTimeInSeconds,
        'wordPairSimilarity': wordPairSimilarity,
        'wolfRevengeEnabled': wolfRevengeEnabled,
      };

      await _persistentStorage.write(
        key: _kGameSettingsKey,
        value: jsonEncode(settings),
      );
    } catch (e) {
      // Silently handle error - could add proper error handling later
    }
  }

  /// Loads and applies saved settings to a game instance
  Future<Game> loadSettings(Game game) async {
    final settings = await getGameSettings();

    final randomizeWolfCount =
        settings['randomizeWolfCount'] as bool? ?? game.randomizeWolfCount;
    final autoAssignWolves =
        settings['autoAssignWolves'] as bool? ?? game.autoAssignWolves;

    // Only keep customWolfCount if we're not using randomize or auto-assign
    final customWolfCount = (randomizeWolfCount || autoAssignWolves)
        ? null
        : settings['customWolfCount'] as int? ?? game.customWolfCount;

    return game.copyWith(
      customWolfCount: customWolfCount,
      randomizeWolfCount: randomizeWolfCount,
      autoAssignWolves: autoAssignWolves,
      discussionTimeInSeconds: settings['discussionTimeInSeconds'] as int? ??
          game.discussionTimeInSeconds,
      wordPairSimilarity:
          settings['wordPairSimilarity'] as double? ?? game.wordPairSimilarity,
      wolfRevengeEnabled:
          settings['wolfRevengeEnabled'] as bool? ?? game.wolfRevengeEnabled,
    );
  }
}
