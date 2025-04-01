import 'package:equatable/equatable.dart';

import 'player.dart';

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

  bool get isValid {
    return players.length >= 3 &&
        category.isNotEmpty &&
        citizenWord.isNotEmpty &&
        wolfWord.isNotEmpty;
  }

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
        // Make sure we don't exceed half the players
        final maxWolves = (players.length / 2).floor();
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
      ];
}
