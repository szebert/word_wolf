part of "analytics_bloc.dart";

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
}

class TrackAnalyticsEvent extends AnalyticsEvent {
  const TrackAnalyticsEvent(this.event);

  final FirebaseAnalyticsEvent event;

  @override
  List<Object> get props => <Object>[event];
}
