import 'package:equatable/equatable.dart';

import 'player.dart';
import 'saved_category.dart';

enum GamePhase {
  setup,
  wordAssignment,
  discussion,
  voting,
  results,
}

class Game extends Equatable {
  const Game({
    this.players = const [],
    this.category = '',
    this.citizenWord = '',
    this.wolfWord = '',
    this.discussionTimeInSeconds = 180, // Default 3 minutes
    this.phase = GamePhase.setup,
    this.remainingTimeInSeconds = 0,
    this.customWolfCount,
    this.randomizeWolfCount = false,
    this.autoAssignWolves = true,
    this.categorySearchText = '',
    this.savedCategories = const [],
    this.presetCategories = const [],
    this.wordPairSimilarity = 0.5, // Default medium similarity
  });

  final List<Player> players;
  final String category;
  final String citizenWord;
  final String wolfWord;
  final int discussionTimeInSeconds;
  final GamePhase phase;
  final int remainingTimeInSeconds;
  final int? customWolfCount;
  final bool randomizeWolfCount;
  final bool autoAssignWolves;
  final String categorySearchText;
  final List<SavedCategory> savedCategories;
  final List<String> presetCategories;
  // Controls how similar or different word pairs should be
  final double wordPairSimilarity;

  int get wolfCount {
    if (customWolfCount != null) {
      return customWolfCount!;
    }

    // Calculate based on player count if no custom count is set
    final defaultCount = _getDefaultWolfCount(players.length);

    // If randomize is enabled, add or subtract 1 (keeping at least 1 wolf)
    if (randomizeWolfCount) {
      final random = DateTime.now().millisecondsSinceEpoch % 3; // 0, 1, or 2
      if (random == 0 && defaultCount > 1) {
        return defaultCount - 1;
      } else if (random == 1) {
        // Keep default
        return defaultCount;
      } else {
        // Make sure wolves stay less than citizens
        final maxWolves = ((players.length - 1) / 2).floor();
        return defaultCount < maxWolves ? defaultCount + 1 : defaultCount;
      }
    }

    return defaultCount;
  }

  int _getDefaultWolfCount(int playerCount) {
    return (playerCount / 5).ceil().clamp(1, (playerCount / 2).floor());
  }

  Game copyWith({
    List<Player>? players,
    String? category,
    String? citizenWord,
    String? wolfWord,
    int? discussionTimeInSeconds,
    GamePhase? phase,
    int? remainingTimeInSeconds,
    int? customWolfCount,
    bool? randomizeWolfCount,
    bool? autoAssignWolves,
    String? categorySearchText,
    List<SavedCategory>? savedCategories,
    List<String>? presetCategories,
    double? wordPairSimilarity,
  }) {
    return Game(
      players: players ?? this.players,
      category: category ?? this.category,
      citizenWord: citizenWord ?? this.citizenWord,
      wolfWord: wolfWord ?? this.wolfWord,
      discussionTimeInSeconds:
          discussionTimeInSeconds ?? this.discussionTimeInSeconds,
      phase: phase ?? this.phase,
      remainingTimeInSeconds:
          remainingTimeInSeconds ?? this.remainingTimeInSeconds,
      customWolfCount: customWolfCount ?? this.customWolfCount,
      randomizeWolfCount: randomizeWolfCount ?? this.randomizeWolfCount,
      autoAssignWolves: autoAssignWolves ?? this.autoAssignWolves,
      categorySearchText: categorySearchText ?? this.categorySearchText,
      savedCategories: savedCategories ?? this.savedCategories,
      presetCategories: presetCategories ?? this.presetCategories,
      wordPairSimilarity: wordPairSimilarity ?? this.wordPairSimilarity,
    );
  }

  @override
  List<Object?> get props => [
        players,
        category,
        citizenWord,
        wolfWord,
        discussionTimeInSeconds,
        phase,
        remainingTimeInSeconds,
        customWolfCount,
        randomizeWolfCount,
        autoAssignWolves,
        categorySearchText,
        savedCategories,
        presetCategories,
        wordPairSimilarity,
      ];
}
