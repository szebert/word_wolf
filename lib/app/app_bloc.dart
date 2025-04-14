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
  }

  final AppRepository _appRepository;

  Future<void> _onAppInitialized(
    final AppInitialized event,
    final Emitter<AppState> emit,
  ) async {
    final hasViewedHowToPlay = await _appRepository.fetchHasViewedHowToPlay();
    final hasPaidForAdRemoval = await _appRepository.fetchHasPaidForAdRemoval();

    if (hasViewedHowToPlay) {
      add(const HowToPlayViewed());
    }

    if (hasPaidForAdRemoval) {
      emit(state.copyWith(hasPaidForAdRemoval: true));
    }
  }

  @override
  AppState fromJson(Map<dynamic, dynamic> json) {
    return AppState(
      hasViewedHowToPlay: json["has_viewed_how_to_play"] as bool? ?? false,
      hasPaidForAdRemoval: json["has_paid_for_ad_removal"] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson(AppState state) {
    return <String, dynamic>{
      "has_viewed_how_to_play": state.hasViewedHowToPlay,
      "has_paid_for_ad_removal": state.hasPaidForAdRemoval,
    };
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
}
