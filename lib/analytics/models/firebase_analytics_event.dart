import "package:equatable/equatable.dart";

/// {@template analytics_event}
/// An analytic event which can be tracked.
/// Consists of the unique event name and an optional
/// map of properties.
/// {@endtemplate}
class FirebaseAnalyticsEvent extends Equatable {
  /// {@macro analytics_event}
  const FirebaseAnalyticsEvent(this.name, {this.properties});

  /// Unique event name.
  final String name;

  /// Optional map of event properties.
  final Map<String, Object>? properties;

  @override
  List<Object?> get props => [name, properties];
}

/// Mixin for tracking analytics events.
mixin AnalyticsEventMixin on Equatable {
  /// Analytics event which will be tracked.
  FirebaseAnalyticsEvent get event;

  @override
  List<Object> get props => [event];
}
