import 'package:equatable/equatable.dart';

import 'player.dart';
import 'word_pair_results.dart';

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
    this.citizenWord = '',
    this.wolfWord = '',
    this.discussionTimeInSeconds = 180, // Default 3 minutes
    this.phase = GamePhase.setup,
    this.remainingTimeInSeconds = 0,
    this.customWolfCount,
    this.randomizeWolfCount = false,
    this.autoAssignWolves = true,
    this.wordPairSimilarity = 0.5, // Default medium similarity
    this.icebreakers = const [],
    this.selectedPlayerId,
    this.wolfRevengeEnabled = true, // Enable Wolf's Revenge by default
    this.wolfRevengeAttempted = false,
    this.wolfRevengeSuccessful = false,
  });

  final List<Player> players;
  final String citizenWord;
  final String wolfWord;
  final int discussionTimeInSeconds;
  final GamePhase phase;
  final int remainingTimeInSeconds;
  final int? customWolfCount;
  final bool randomizeWolfCount;
  final bool autoAssignWolves;
  // Controls how similar or different word pairs should be
  final double wordPairSimilarity;
  final List<Icebreaker> icebreakers;
  final String? selectedPlayerId;
  final bool wolfRevengeEnabled;
  final bool wolfRevengeAttempted;
  final bool wolfRevengeSuccessful;

  int get generateWolfCount {
    // Calculate default wolf count based on player count
    final defaultCount = _getDefaultWolfCount(players.length);

    // If randomize is enabled, calculate all valid options and choose randomly
    if (randomizeWolfCount) {
      // Determine valid wolf count options
      final validOptions = <int>[];

      // Consider defaultCount - 1 (if above minimum)
      if (defaultCount > 1) {
        validOptions.add(defaultCount - 1);
      }

      // Always include the default count
      validOptions.add(defaultCount);

      // Consider defaultCount + 1 (if below maximum allowed wolves)
      final maxWolves = ((players.length - 1) / 2).floor();
      if (defaultCount < maxWolves) {
        validOptions.add(defaultCount + 1);
      }

      // Pick a random option from valid choices
      final random =
          DateTime.now().millisecondsSinceEpoch % validOptions.length;
      final selectedOption = validOptions[random];

      return selectedOption;
    }

    // If customWolfCount is explicitly set, use it
    if (customWolfCount != null) {
      return customWolfCount!;
    }

    return defaultCount;
  }

  int _getDefaultWolfCount(int playerCount) {
    return (playerCount / 5).ceil().clamp(1, (playerCount / 2).floor());
  }

  Game copyWith({
    List<Player>? players,
    String? citizenWord,
    String? wolfWord,
    int? discussionTimeInSeconds,
    GamePhase? phase,
    int? remainingTimeInSeconds,
    int? customWolfCount,
    bool? randomizeWolfCount,
    bool? autoAssignWolves,
    double? wordPairSimilarity,
    List<Icebreaker>? icebreakers,
    String? selectedPlayerId,
    bool? wolfRevengeEnabled,
    bool? wolfRevengeAttempted,
    bool? wolfRevengeSuccessful,
  }) {
    return Game(
      players: players ?? this.players,
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
      wordPairSimilarity: wordPairSimilarity ?? this.wordPairSimilarity,
      icebreakers: icebreakers ?? this.icebreakers,
      selectedPlayerId: selectedPlayerId ?? this.selectedPlayerId,
      wolfRevengeEnabled: wolfRevengeEnabled ?? this.wolfRevengeEnabled,
      wolfRevengeAttempted: wolfRevengeAttempted ?? this.wolfRevengeAttempted,
      wolfRevengeSuccessful:
          wolfRevengeSuccessful ?? this.wolfRevengeSuccessful,
    );
  }

  @override
  List<Object?> get props => [
        players,
        citizenWord,
        wolfWord,
        discussionTimeInSeconds,
        phase,
        remainingTimeInSeconds,
        customWolfCount,
        randomizeWolfCount,
        autoAssignWolves,
        wordPairSimilarity,
        icebreakers,
        selectedPlayerId,
        wolfRevengeEnabled,
        wolfRevengeAttempted,
        wolfRevengeSuccessful,
      ];
}
