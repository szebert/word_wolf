import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends HydratedBloc<AppEvent, AppState> {
  AppBloc() : super(const AppState.initial()) {
    on<HowToPlayViewed>(_onHowToPlayViewed);
  }

  @override
  AppState fromJson(Map<dynamic, dynamic> json) {
    return AppState(
      hasViewedHowToPlay: json['has_viewed_how_to_play'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson(AppState state) {
    return <String, dynamic>{
      'has_viewed_how_to_play': state.hasViewedHowToPlay,
    };
  }

  void _onHowToPlayViewed(
    HowToPlayViewed event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(hasViewedHowToPlay: true));
  }
}
