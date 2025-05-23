part of "game_bloc.dart";

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameInitialized extends GameEvent {
  const GameInitialized();
}

class SetupStarted extends GameEvent {
  const SetupStarted();
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

class AutoAssignUpdated extends GameEvent {
  const AutoAssignUpdated({
    required this.enabled,
  });

  final bool enabled;

  @override
  List<Object> get props => [enabled];
}

class RandomizeWolfCountUpdated extends GameEvent {
  const RandomizeWolfCountUpdated({
    required this.enabled,
  });

  final bool enabled;

  @override
  List<Object> get props => [enabled];
}

class WolvesCountUpdated extends GameEvent {
  const WolvesCountUpdated({
    required this.count,
  });

  final int count;

  @override
  List<Object> get props => [count];
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

class WolfRevengeUpdated extends GameEvent {
  const WolfRevengeUpdated({
    required this.enabled,
  });

  final bool enabled;

  @override
  List<Object> get props => [enabled];
}

class GameStarted extends GameEvent {
  const GameStarted({
    required this.category,
    required this.l10n,
  });

  final String category;
  final AppLocalizations l10n;

  @override
  List<Object> get props => [category];
}

class GameStartedOffline extends GameEvent {
  const GameStartedOffline({
    required this.category,
    required this.l10n,
  });

  final String category;
  final AppLocalizations l10n;

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

class IcebreakerLabelRevealed extends GameEvent {
  const IcebreakerLabelRevealed({
    required this.index,
  });

  final int index;

  @override
  List<Object> get props => [index];
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

class WolfRevengeGuess extends GameEvent {
  const WolfRevengeGuess({
    required this.guess,
  });

  final String guess;

  @override
  List<Object> get props => [guess];
}

class WolfRevengeVerbalGuess extends GameEvent {
  const WolfRevengeVerbalGuess({
    required this.correct,
  });

  final bool correct;

  @override
  List<Object> get props => [correct];
}

class WolfRevengeSkipped extends GameEvent {
  const WolfRevengeSkipped();
}
