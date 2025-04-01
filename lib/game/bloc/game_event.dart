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
  List<Object?> get props => [playerId];
}

class PlayerNameUpdated extends GameEvent {
  const PlayerNameUpdated({
    required this.playerId,
    required this.name,
  });

  final String playerId;
  final String name;

  @override
  List<Object?> get props => [playerId, name];
}

class GameCategoryUpdated extends GameEvent {
  const GameCategoryUpdated(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}

class GameSettingsUpdated extends GameEvent {
  const GameSettingsUpdated({
    this.numberOfWolves,
    required this.randomizeWolfCount,
    required this.discussionDuration,
    required this.autoAssignWolves,
  });

  final int? numberOfWolves;
  final bool randomizeWolfCount;
  final int discussionDuration;
  final bool autoAssignWolves;

  @override
  List<Object?> get props => [
        numberOfWolves,
        randomizeWolfCount,
        discussionDuration,
        autoAssignWolves
      ];
}

class GameWordsUpdated extends GameEvent {
  const GameWordsUpdated({
    required this.citizenWord,
    required this.wolfWord,
  });

  final String citizenWord;
  final String wolfWord;

  @override
  List<Object?> get props => [citizenWord, wolfWord];
}

class GameDiscussionTimeUpdated extends GameEvent {
  const GameDiscussionTimeUpdated(this.timeInSeconds);

  final int timeInSeconds;

  @override
  List<Object?> get props => [timeInSeconds];
}

class GameStarted extends GameEvent {
  const GameStarted();
}

class GamePhaseAdvanced extends GameEvent {
  const GamePhaseAdvanced();
}

class GameTimerTicked extends GameEvent {
  const GameTimerTicked(this.remainingSeconds);

  final int remainingSeconds;

  @override
  List<Object?> get props => [remainingSeconds];
}

class GameReset extends GameEvent {
  const GameReset();
}
