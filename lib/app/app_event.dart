part of "app_bloc.dart";

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppInitialized extends AppEvent {
  const AppInitialized();
}

class HowToPlayViewed extends AppEvent {
  const HowToPlayViewed();
}

class SetAdRemoval extends AppEvent {
  const SetAdRemoval({
    this.value,
  });

  final bool? value;

  @override
  List<Object?> get props => [value];
}

class GameCompleted extends AppEvent {
  const GameCompleted();
}
