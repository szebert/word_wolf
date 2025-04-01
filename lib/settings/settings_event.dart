part of "settings_bloc.dart";

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => <Object>[];
}

class FetchFeedbackSettings extends SettingsEvent {
  const FetchFeedbackSettings();

  @override
  List<Object> get props => <Object>[];
}

class ToggleSound extends SettingsEvent {
  const ToggleSound();

  @override
  List<Object> get props => <Object>[];
}

class ToggleHaptic extends SettingsEvent {
  const ToggleHaptic();

  @override
  List<Object> get props => <Object>[];
}

class TextScaleChanged extends SettingsEvent {
  const TextScaleChanged(this.scale);

  final double scale;

  @override
  List<Object> get props => <Object>[scale];
}
