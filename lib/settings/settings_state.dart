part of "settings_bloc.dart";

enum FeedbackStatus {
  initial,
  loading,
  success,
  failure,
}

class SettingsState extends Equatable {
  const SettingsState({
    this.soundStatus = FeedbackStatus.initial,
    this.hapticStatus = FeedbackStatus.initial,
    this.fetchStatus = FeedbackStatus.initial,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.textScale = 1.0,
  });

  const SettingsState.initial()
      : this(
          soundStatus: FeedbackStatus.initial,
          hapticStatus: FeedbackStatus.initial,
          fetchStatus: FeedbackStatus.initial,
        );

  final FeedbackStatus soundStatus;
  final FeedbackStatus hapticStatus;
  final FeedbackStatus fetchStatus;
  final bool soundEnabled;
  final bool hapticEnabled;
  final double textScale;

  SettingsState copyWith({
    FeedbackStatus? soundStatus,
    FeedbackStatus? hapticStatus,
    FeedbackStatus? fetchStatus,
    bool? soundEnabled,
    bool? hapticEnabled,
    double? textScale,
  }) {
    return SettingsState(
      soundStatus: soundStatus ?? this.soundStatus,
      hapticStatus: hapticStatus ?? this.hapticStatus,
      fetchStatus: fetchStatus ?? this.fetchStatus,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      textScale: textScale ?? this.textScale,
    );
  }

  @override
  List<Object> get props => <Object>[
        soundStatus,
        hapticStatus,
        fetchStatus,
        soundEnabled,
        hapticEnabled,
        textScale,
      ];
}
