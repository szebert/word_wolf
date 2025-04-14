part of "app_bloc.dart";

class AppState extends Equatable {
  const AppState({
    this.hasViewedHowToPlay = false,
    this.hasPaidForAdRemoval = false,
  });

  const AppState.initial() : this();

  final bool hasViewedHowToPlay;
  final bool hasPaidForAdRemoval;

  AppState copyWith({
    bool? hasViewedHowToPlay,
    bool? hasPaidForAdRemoval,
  }) {
    return AppState(
      hasViewedHowToPlay: hasViewedHowToPlay ?? this.hasViewedHowToPlay,
      hasPaidForAdRemoval: hasPaidForAdRemoval ?? this.hasPaidForAdRemoval,
    );
  }

  @override
  List<Object> get props => [hasViewedHowToPlay, hasPaidForAdRemoval];
}
