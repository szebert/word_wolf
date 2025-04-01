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
  });

  final List<Player> players;
  final String category;
  final String citizenWord;
  final String wolfWord;
  final int discussionTimeInSeconds;
  final GamePhase phase;
  final int remainingTimeInSeconds;

  bool get isValid {
    return players.length >= 3 &&
        category.isNotEmpty &&
        citizenWord.isNotEmpty &&
        wolfWord.isNotEmpty;
  }

  int get wolfCount {
    // For 3-4 players: 1 wolf
    // For 5-7 players: 2 wolves
    // For 8+ players: 3 wolves
    if (players.length <= 4) return 1;
    if (players.length <= 7) return 2;
    return 3;
  }

  Game copyWith({
    List<Player>? players,
    String? category,
    String? citizenWord,
    String? wolfWord,
    int? discussionTimeInSeconds,
    GamePhase? phase,
    int? remainingTimeInSeconds,
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
      ];
}
