part of "settings_bloc.dart";

enum SettingsStatus {
  initial,
  fetchingFeedbackSettings,
  fetchingFeedbackSettingsFailed,
  fetchingFeedbackSettingsSucceeded,
  togglingSound,
  togglingSoundFailed,
  togglingSoundSucceeded,
  togglingHaptic,
  togglingHapticFailed,
  togglingHapticSucceeded,
}

class SettingsState extends Equatable {
  const SettingsState({
    required this.status,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.textScale = 1.0,
  });

  const SettingsState.initial() : this(status: SettingsStatus.initial);

  final SettingsStatus status;
  final bool soundEnabled;
  final bool hapticEnabled;
  final double textScale;

  SettingsState copyWith({
    final SettingsStatus? status,
    final bool? soundEnabled,
    final bool? hapticEnabled,
    final double? textScale,
  }) {
    return SettingsState(
      status: status ?? this.status,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      textScale: textScale ?? this.textScale,
    );
  }

  @override
  List<Object> get props => <Object>[
        status,
        soundEnabled,
        hapticEnabled,
        textScale,
      ];
}
