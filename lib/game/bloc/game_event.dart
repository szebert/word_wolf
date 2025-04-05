part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameInitialized extends GameEvent {
  const GameInitialized();
}

class PlayerAdded extends GameEvent {
  const PlayerAdded();
}

class PlayerRemoved extends GameEvent {
  const PlayerRemoved({
    required this.playerId,
  });

  final String playerId;

  @override
  List<Object> get props => [playerId];
}

class PlayerNameUpdated extends GameEvent {
  const PlayerNameUpdated({
    required this.playerId,
    required this.name,
  });

  final String playerId;
  final String name;

  @override
  List<Object> get props => [playerId, name];
}

class WolvesCountUpdated extends GameEvent {
  const WolvesCountUpdated({
    this.customWolfCount,
    required this.randomizeWolfCount,
    required this.autoAssignWolves,
  });

  final int? customWolfCount;
  final bool randomizeWolfCount;
  final bool autoAssignWolves;

  @override
  List<Object?> get props =>
      [customWolfCount, randomizeWolfCount, autoAssignWolves];
}

class GameDiscussionTimeUpdated extends GameEvent {
  const GameDiscussionTimeUpdated({
    required this.timeInSeconds,
  });

  final int timeInSeconds;

  @override
  List<Object> get props => [timeInSeconds];
}

class WordPairSimilarityUpdated extends GameEvent {
  const WordPairSimilarityUpdated({
    required this.similarity,
  });

  final double similarity;

  @override
  List<Object> get props => [similarity];
}

class GameStarted extends GameEvent {
  const GameStarted({
    required this.category,
  });

  final String category;

  @override
  List<Object> get props => [category];
}

class DiscussionStarted extends GameEvent {
  const DiscussionStarted();
}

class GameTimerTicked extends GameEvent {
  const GameTimerTicked({
    required this.remainingSeconds,
  });

  final int remainingSeconds;

  @override
  List<Object> get props => [remainingSeconds];
}

class GameTimerPaused extends GameEvent {
  const GameTimerPaused({required this.paused});

  final bool paused;

  @override
  List<Object> get props => [paused];
}

class GameTimerAdjusted extends GameEvent {
  const GameTimerAdjusted({
    required this.newTimeInSeconds,
  });

  final int newTimeInSeconds;

  @override
  List<Object> get props => [newTimeInSeconds];
}

class VotingStarted extends GameEvent {
  const VotingStarted();
}

class SuddenDeathStarted extends GameEvent {
  const SuddenDeathStarted();
}

class PlayerVoted extends GameEvent {
  const PlayerVoted({
    required this.selectedPlayerId,
  });

  final String selectedPlayerId;

  @override
  List<Object> get props => [selectedPlayerId];
}
