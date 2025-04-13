import "dart:async";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";

import "../analytics.dart";

part "analytics_event.dart";
part "analytics_state.dart";

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({
    required final AnalyticsRepository analyticsRepository,
  })  : _analyticsRepository = analyticsRepository,
        super(AnalyticsInitial()) {
    on<TrackAnalyticsEvent>(_onTrackAnalyticsEvent);
  }

  final AnalyticsRepository _analyticsRepository;

  Future<void> _onTrackAnalyticsEvent(
    final TrackAnalyticsEvent event,
    final Emitter<AnalyticsState> emit,
  ) async {
    try {
      await _analyticsRepository.track(event.event);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
