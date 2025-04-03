part of 'game_bloc.dart';

enum GameStatus {
  initial,
  loading,
  ready,
  inProgress,
  error,
}

class GameState extends Equatable {
  const GameState({
    this.status = GameStatus.initial,
    this.game = const Game(),
    this.error = '',
  });

  final GameStatus status;
  final Game game;
  final String error;

  GameState copyWith({
    GameStatus? status,
    Game? game,
    String? error,
  }) {
    return GameState(
      status: status ?? this.status,
      game: game ?? this.game,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, game, error];
}
