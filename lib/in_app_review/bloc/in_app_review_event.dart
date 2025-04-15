part of "in_app_review_bloc.dart";

abstract class InAppReviewEvent extends Equatable {
  const InAppReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Check if a review can be requested
class InAppReviewCheck extends InAppReviewEvent {
  const InAppReviewCheck({
    required this.completedGamesCount,
    this.lastCompletedGame,
  });

  final int completedGamesCount;
  final DateTime? lastCompletedGame;

  @override
  List<Object?> get props => [completedGamesCount, lastCompletedGame];
}

/// Request an in-app review
class InAppReviewRequested extends InAppReviewEvent {
  const InAppReviewRequested();
}

/// Open the app's store listing
class InAppReviewOpenStoreListing extends InAppReviewEvent {
  const InAppReviewOpenStoreListing();
}
