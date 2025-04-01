part of 'app_bloc.dart';

class AppState extends Equatable {
  const AppState({
    this.hasViewedHowToPlay = false,
  });

  const AppState.initial() : this();

  final bool hasViewedHowToPlay;

  AppState copyWith({
    bool? hasViewedHowToPlay,
  }) {
    return AppState(
      hasViewedHowToPlay: hasViewedHowToPlay ?? this.hasViewedHowToPlay,
    );
  }

  @override
  List<Object> get props => [hasViewedHowToPlay];
}
