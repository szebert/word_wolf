import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:in_app_review/in_app_review.dart";

import "../in_app_review_repository.dart";

part "in_app_review_event.dart";
part "in_app_review_state.dart";

class InAppReviewBloc extends Bloc<InAppReviewEvent, InAppReviewState> {
  InAppReviewBloc({
    required InAppReviewRepository repository,
    InAppReview? inAppReview,
  })  : _repository = repository,
        _inAppReview = inAppReview ?? InAppReview.instance,
        super(const InAppReviewState.initial()) {
    on<InAppReviewCheck>(_onCheckReview);
    on<InAppReviewRequested>(_onRequestReview);
    on<InAppReviewOpenStoreListing>(_onOpenStoreListing);
  }

  final InAppReviewRepository _repository;
  final InAppReview _inAppReview;

  /// The number of completed games required before requesting a review
  static const int minCompletedGames = 5;

  /// The minimum number of days between review requests
  static const int minDaysBetweenRequests = 90;

  /// The maximum number of days since the last game to request a review
  static const int maxInactiveDays = 1;

  /// The iOS App Store ID for this app
  /// Required for opening the store listing on iOS
  static const String? appStoreId = null; // Replace with your App Store ID

  Future<void> _onCheckReview(
    InAppReviewCheck event,
    Emitter<InAppReviewState> emit,
  ) async {
    emit(state.copyWith(
      status: InAppReviewStatus.loading,
      completedGamesCount: event.completedGamesCount,
    ));

    try {
      final canRequest = await _shouldRequestReview(
        completedGamesCount: event.completedGamesCount,
        lastCompletedGame: event.lastCompletedGame,
        minCompletedGames: minCompletedGames,
        minDaysBetweenRequests: minDaysBetweenRequests,
        maxInactiveDays: maxInactiveDays,
      );

      if (!canRequest) {
        emit(state.copyWith(status: InAppReviewStatus.unavailable));
        return;
      }

      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        emit(state.copyWith(status: InAppReviewStatus.available));
      } else {
        emit(state.copyWith(status: InAppReviewStatus.unavailable));
      }
    } catch (e) {
      emit(state.copyWith(
        status: InAppReviewStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Checks if a review should be requested.
  ///
  /// A review should be requested if:
  /// - The user has completed at least [minCompletedGames] games
  /// - The last review request was at least [minDaysBetweenRequests] days ago,
  ///   or no review has been requested yet
  /// - The user has completed a game recently (within [maxInactiveDays])
  Future<bool> _shouldRequestReview({
    required int completedGamesCount,
    DateTime? lastCompletedGame,
    int minCompletedGames = 5,
    int minDaysBetweenRequests = 90,
    int maxInactiveDays = 1,
  }) async {
    // Only request review if the user has played enough games
    if (completedGamesCount < minCompletedGames) {
      return false;
    }

    // Don't request if user hasn't played recently
    if (lastCompletedGame != null) {
      final now = DateTime.now();
      final daysSinceLastGame = now.difference(lastCompletedGame).inDays;

      // If the user hasn't played a game recently, don't show the review prompt
      if (daysSinceLastGame > maxInactiveDays) {
        return false;
      }
    }

    // Check the last request date
    final lastRequestDate = await _repository.getLastReviewRequestDate();
    if (lastRequestDate != null) {
      final now = DateTime.now();
      final difference = now.difference(lastRequestDate);
      if (difference.inDays < minDaysBetweenRequests) {
        return false;
      }
    }

    return true;
  }

  Future<void> _onRequestReview(
    InAppReviewRequested event,
    Emitter<InAppReviewState> emit,
  ) async {
    try {
      if (state.status != InAppReviewStatus.available) {
        // Check if review is available again
        await _onCheckReview(
          InAppReviewCheck(
            completedGamesCount: state.completedGamesCount,
            lastCompletedGame: state.lastCompletedGame,
          ),
          emit,
        );

        if (state.status != InAppReviewStatus.available) {
          return;
        }
      }

      await _inAppReview.requestReview();

      // We don't know if the user actually left a review,
      // but we mark it as requested for this session
      final now = DateTime.now();
      await _repository.setLastReviewRequestDate(now);

      emit(state.copyWith(
        status: InAppReviewStatus.unavailable,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InAppReviewStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onOpenStoreListing(
    InAppReviewOpenStoreListing event,
    Emitter<InAppReviewState> emit,
  ) async {
    try {
      await _inAppReview.openStoreListing(appStoreId: appStoreId);
      emit(state.copyWith(status: InAppReviewStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: InAppReviewStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
