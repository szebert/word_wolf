import "package:equatable/equatable.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

import "app_repository.dart";

part "app_event.dart";
part "app_state.dart";

class AppBloc extends HydratedBloc<AppEvent, AppState> {
  AppBloc({
    required final AppRepository appRepository,
  })  : _appRepository = appRepository,
        super(const AppState.initial()) {
    on<AppInitialized>(_onAppInitialized);
    on<HowToPlayViewed>(_onHowToPlayViewed);
    on<SetAdRemoval>(_onSetAdRemoval);
    on<GameCompleted>(_onGameCompleted);
  }

  final AppRepository _appRepository;

  /// Gets the number of completed games.
  int get completedGamesCount => state.completedGamesCount;

  /// Gets the date of the last completed game.
  DateTime? get lastCompletedGame => state.lastCompletedGame;

  Future<void> _onAppInitialized(
    final AppInitialized event,
    final Emitter<AppState> emit,
  ) async {
    final appDetails = await _appRepository.fetchAppDetails();

    emit(state.copyWith(
      hasViewedHowToPlay: appDetails.hasViewedHowToPlay,
      hasPaidForAdRemoval: appDetails.hasPaidForAdRemoval,
      completedGamesCount: appDetails.completedGamesCount,
      lastCompletedGame: appDetails.lastCompletedGame,
    ));
  }

  @override
  AppState fromJson(Map<dynamic, dynamic> json) {
    DateTime? lastCompletedGame;
    if (json["last_completed_game"] != null) {
      try {
        lastCompletedGame = DateTime.fromMillisecondsSinceEpoch(
          json["last_completed_game"] as int,
        );
      } catch (_) {
        // Keep as null
      }
    }

    return AppState(
      hasViewedHowToPlay: json["has_viewed_how_to_play"] as bool? ?? false,
      hasPaidForAdRemoval: json["has_paid_for_ad_removal"] as bool? ?? false,
      completedGamesCount: json["completed_games_count"] as int? ?? 0,
      lastCompletedGame: lastCompletedGame,
    );
  }

  @override
  Map<String, dynamic> toJson(AppState state) {
    final json = <String, dynamic>{
      "has_viewed_how_to_play": state.hasViewedHowToPlay,
      "has_paid_for_ad_removal": state.hasPaidForAdRemoval,
      "completed_games_count": state.completedGamesCount,
    };

    if (state.lastCompletedGame != null) {
      json["last_completed_game"] =
          state.lastCompletedGame!.millisecondsSinceEpoch;
    }

    return json;
  }

  Future<void> _onHowToPlayViewed(
    HowToPlayViewed event,
    Emitter<AppState> emit,
  ) async {
    // Update the repository with the new value
    await _appRepository.setHasViewedHowToPlay(hasViewed: true);

    // Update the state
    emit(state.copyWith(hasViewedHowToPlay: true));
  }

  Future<void> _onSetAdRemoval(
    SetAdRemoval event,
    Emitter<AppState> emit,
  ) async {
    final newValue = event.value ?? !state.hasPaidForAdRemoval;

    // Update the repository with the new value
    await _appRepository.setHasPaidForAdRemoval(hasPaid: newValue);

    // Update the state
    emit(state.copyWith(hasPaidForAdRemoval: newValue));
  }

  Future<void> _onGameCompleted(
    GameCompleted event,
    Emitter<AppState> emit,
  ) async {
    final now = DateTime.now();

    // Update the repository with the new values
    await _appRepository.setCompletedGamesCount(
      completedGamesCount: state.completedGamesCount + 1,
    );
    await _appRepository.setLastCompletedGame(now);

    // Update the state
    emit(state.copyWith(
      completedGamesCount: state.completedGamesCount + 1,
      lastCompletedGame: now,
    ));
  }
}
