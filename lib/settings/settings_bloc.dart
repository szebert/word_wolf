import "package:equatable/equatable.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

import "../feedback_repository/feedback_repository.dart";

part "settings_event.dart";
part "settings_state.dart";

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required final FeedbackRepository feedbackRepository,
  })  : _feedbackRepository = feedbackRepository,
        super(const SettingsState.initial()) {
    on<FetchFeedbackSettings>(_onFetchFeedbackSettings);
    on<ToggleSound>(_onToggleSound);
    on<ToggleHaptic>(_onToggleHaptic);
    on<TextScaleChanged>(_onTextScaleChanged);
  }

  final FeedbackRepository _feedbackRepository;

  @override
  SettingsState fromJson(final Map<dynamic, dynamic> json) {
    return SettingsState(
      status: SettingsStatus.initial,
      textScale: (json["text_scale"] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson(final SettingsState state) {
    return <String, dynamic>{
      "text_scale": state.textScale,
    };
  }

  Future<void> _onFetchFeedbackSettings(
    final FetchFeedbackSettings event,
    final Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SettingsStatus.fetchingFeedbackSettings));

      final (bool hapticEnabled, bool soundEnabled) feedbackSettings =
          await _feedbackRepository.fetchFeedbackSettings();

      emit(
        state.copyWith(
          status: SettingsStatus.fetchingFeedbackSettingsSucceeded,
          hapticEnabled: feedbackSettings.$1,
          soundEnabled: feedbackSettings.$2,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: SettingsStatus.fetchingFeedbackSettingsFailed,
        ),
      );
      addError(error, stackTrace);
    }
  }

  Future<void> _onToggleSound(
    final ToggleSound event,
    final Emitter<SettingsState> emit,
  ) async {
    final bool initialSoundEnabled = state.soundEnabled;
    final bool updatedSoundEnabled = !initialSoundEnabled;

    try {
      emit(
        state.copyWith(
          status: SettingsStatus.togglingSound,
          soundEnabled: updatedSoundEnabled,
        ),
      );

      await _feedbackRepository.toggleSound(enable: updatedSoundEnabled);

      emit(
        state.copyWith(
          status: SettingsStatus.togglingSoundSucceeded,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: SettingsStatus.togglingSoundFailed,
          soundEnabled: initialSoundEnabled,
        ),
      );
      addError(error, stackTrace);
    }
  }

  Future<void> _onToggleHaptic(
    final ToggleHaptic event,
    final Emitter<SettingsState> emit,
  ) async {
    final bool initialHapticEnabled = state.hapticEnabled;
    final bool updatedHapticEnabled = !initialHapticEnabled;

    try {
      emit(
        state.copyWith(
          status: SettingsStatus.togglingHaptic,
          hapticEnabled: updatedHapticEnabled,
        ),
      );

      await _feedbackRepository.toggleHaptic(enable: updatedHapticEnabled);

      emit(
        state.copyWith(
          status: SettingsStatus.togglingHapticSucceeded,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: SettingsStatus.togglingHapticFailed,
          hapticEnabled: initialHapticEnabled,
        ),
      );
      addError(error, stackTrace);
    }
  }

  void _onTextScaleChanged(
    final TextScaleChanged event,
    final Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(textScale: event.scale));
  }
}
