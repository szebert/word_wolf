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
      emit(state.copyWith(fetchStatus: FeedbackStatus.loading));

      final (bool hapticEnabled, bool soundEnabled) feedbackSettings =
          await _feedbackRepository.fetchFeedbackSettings();

      emit(
        state.copyWith(
          fetchStatus: FeedbackStatus.success,
          hapticEnabled: feedbackSettings.$1,
          soundEnabled: feedbackSettings.$2,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          fetchStatus: FeedbackStatus.failure,
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
          soundStatus: FeedbackStatus.loading,
        ),
      );

      await _feedbackRepository.toggleSound(enable: updatedSoundEnabled);

      emit(
        state.copyWith(
          soundStatus: FeedbackStatus.success,
          soundEnabled: updatedSoundEnabled,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          soundStatus: FeedbackStatus.failure,
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
          hapticStatus: FeedbackStatus.loading,
        ),
      );

      await _feedbackRepository.toggleHaptic(enable: updatedHapticEnabled);

      emit(
        state.copyWith(
          hapticStatus: FeedbackStatus.success,
          hapticEnabled: updatedHapticEnabled,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          hapticStatus: FeedbackStatus.failure,
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
