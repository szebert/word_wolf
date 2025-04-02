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
    required String? category,
    required int? customWolfCount,
    required bool randomizeWolfCount,
    required bool autoAssignWolves,
    required int discussionTimeInSeconds,
    required double wordPairSimilarity,
  }) async {
    try {
      final settings = {
        'category': category ?? '',
        'customWolfCount': customWolfCount,
        'randomizeWolfCount': randomizeWolfCount,
        'autoAssignWolves': autoAssignWolves,
        'discussionTimeInSeconds': discussionTimeInSeconds,
        'wordPairSimilarity': wordPairSimilarity,
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

    return game.copyWith(
      category: settings['category'] as String? ?? game.category,
      customWolfCount:
          settings['customWolfCount'] as int? ?? game.customWolfCount,
      randomizeWolfCount:
          settings['randomizeWolfCount'] as bool? ?? game.randomizeWolfCount,
      autoAssignWolves:
          settings['autoAssignWolves'] as bool? ?? game.autoAssignWolves,
      discussionTimeInSeconds: settings['discussionTimeInSeconds'] as int? ??
          game.discussionTimeInSeconds,
      wordPairSimilarity:
          settings['wordPairSimilarity'] as double? ?? game.wordPairSimilarity,
    );
  }
}
