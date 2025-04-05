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
    on<HowToPlayViewed>(_onHowToPlayViewed);
    _initialize();
  }

  final AppRepository _appRepository;

  Future<void> _initialize() async {
    final hasViewedHowToPlay = await _appRepository.fetchHasViewedHowToPlay();
    if (hasViewedHowToPlay) {
      add(const HowToPlayViewed());
    }
  }

  @override
  AppState fromJson(Map<dynamic, dynamic> json) {
    return AppState(
      hasViewedHowToPlay: json["has_viewed_how_to_play"] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson(AppState state) {
    return <String, dynamic>{
      "has_viewed_how_to_play": state.hasViewedHowToPlay,
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
}
