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
  const GameDiscussionTimeUpdated(this.timeInSeconds);

  final int timeInSeconds;

  @override
  List<Object?> get props => [timeInSeconds];
}

class GameStarted extends GameEvent {
  const GameStarted();
}

class DiscussionStarted extends GameEvent {
  const DiscussionStarted();
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

class GameCategorySearchUpdated extends GameEvent {
  const GameCategorySearchUpdated(this.searchText);

  final String searchText;

  @override
  List<Object?> get props => [searchText];
}

class SavedCategoriesLoaded extends GameEvent {
  const SavedCategoriesLoaded();
}

class PresetCategoriesLoaded extends GameEvent {
  const PresetCategoriesLoaded();
}

class CategorySaved extends GameEvent {
  const CategorySaved(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}

class CategoryRemoved extends GameEvent {
  const CategoryRemoved(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}

class WordPairSimilarityUpdated extends GameEvent {
  const WordPairSimilarityUpdated(this.similarity);

  final double similarity;

  @override
  List<Object?> get props => [similarity];
}

class GameTimerPaused extends GameEvent {
  const GameTimerPaused({required this.paused});

  final bool paused;

  @override
  List<Object?> get props => [paused];
}

class GameTimerAdjusted extends GameEvent {
  const GameTimerAdjusted(this.newTimeInSeconds);

  final int newTimeInSeconds;

  @override
  List<Object?> get props => [newTimeInSeconds];
}

class SuddenDeathStarted extends GameEvent {
  const SuddenDeathStarted();
}

class VotingStarted extends GameEvent {
  const VotingStarted();
}
