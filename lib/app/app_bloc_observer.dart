import "dart:async";
import "dart:developer";

import "package:bloc/bloc.dart";

import "../analytics/analytics.dart";

class AppBlocObserver extends BlocObserver {
  AppBlocObserver({
    required final AnalyticsRepository analyticsRepository,
  }) : _analyticsRepository = analyticsRepository;

  final AnalyticsRepository _analyticsRepository;

  @override
  void onTransition(
    final Bloc<dynamic, dynamic> bloc,
    final Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log("onTransition ${bloc.runtimeType}: $transition");
  }

  @override
  void onError(
    final BlocBase<dynamic> bloc,
    final Object error,
    final StackTrace stackTrace,
  ) {
    super.onError(bloc, error, stackTrace);
    log("onError ${bloc.runtimeType}", error: error, stackTrace: stackTrace);
  }

  @override
  void onChange(final BlocBase<dynamic> bloc, final Change<dynamic> change) {
    super.onChange(bloc, change);
    final dynamic state = change.nextState;
    if (state is AnalyticsEventMixin) {
      unawaited(_analyticsRepository.track(state.event));
    }
  }

  @override
  void onEvent(final Bloc<dynamic, dynamic> bloc, final Object? event) {
    super.onEvent(bloc, event);
    if (event is AnalyticsEventMixin) {
      unawaited(_analyticsRepository.track(event.event));
    }
  }
}
