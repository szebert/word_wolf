part of "app_bloc.dart";

class AppState extends Equatable {
  const AppState({
    required this.hasViewedHowToPlay,
    required this.hasPaidForAdRemoval,
    required this.completedGamesCount,
    this.lastCompletedGame,
  });

  const AppState.initial()
      : hasViewedHowToPlay = false,
        hasPaidForAdRemoval = false,
        completedGamesCount = 0,
        lastCompletedGame = null;

  final bool hasViewedHowToPlay;
  final bool hasPaidForAdRemoval;
  final int completedGamesCount;
  final DateTime? lastCompletedGame;

  AppState copyWith({
    bool? hasViewedHowToPlay,
    bool? hasPaidForAdRemoval,
    int? completedGamesCount,
    DateTime? lastCompletedGame,
  }) {
    return AppState(
      hasViewedHowToPlay: hasViewedHowToPlay ?? this.hasViewedHowToPlay,
      hasPaidForAdRemoval: hasPaidForAdRemoval ?? this.hasPaidForAdRemoval,
      completedGamesCount: completedGamesCount ?? this.completedGamesCount,
      lastCompletedGame: lastCompletedGame ?? this.lastCompletedGame,
    );
  }

  @override
  List<Object?> get props => [
        hasViewedHowToPlay,
        hasPaidForAdRemoval,
        completedGamesCount,
        lastCompletedGame,
      ];
}
