part of "in_app_review_bloc.dart";

enum InAppReviewStatus {
  initial,
  loading,
  available,
  unavailable,
  success,
  failure,
}

class InAppReviewState extends Equatable {
  const InAppReviewState({
    required this.status,
    required this.completedGamesCount,
    required this.lastCompletedGame,
    this.errorMessage,
  });

  const InAppReviewState.initial()
      : status = InAppReviewStatus.initial,
        completedGamesCount = 0,
        lastCompletedGame = null,
        errorMessage = null;

  final InAppReviewStatus status;
  final int completedGamesCount;
  final DateTime? lastCompletedGame;
  final String? errorMessage;

  InAppReviewState copyWith({
    InAppReviewStatus? status,
    int? completedGamesCount,
    DateTime? lastCompletedGame,
    String? errorMessage,
  }) {
    return InAppReviewState(
      status: status ?? this.status,
      completedGamesCount: completedGamesCount ?? this.completedGamesCount,
      lastCompletedGame: lastCompletedGame ?? this.lastCompletedGame,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        completedGamesCount,
        lastCompletedGame,
        errorMessage,
      ];
}
