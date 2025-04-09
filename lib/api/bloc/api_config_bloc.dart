import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";

import "../models/ai_provider.dart";
import "../repository/api_config_repository.dart";

part "api_config_event.dart";
part "api_config_state.dart";

class APIConfigBloc extends Bloc<APIConfigEvent, APIConfigState> {
  APIConfigBloc({
    required APIConfigRepository apiConfigRepository,
  })  : _apiConfigRepository = apiConfigRepository,
        super(const APIConfigState.initial()) {
    on<APIConfigInitialized>(_onAPIConfigInitialized);
    on<OpenAIConfigUpdated>(_onOpenAIConfigUpdated);
  }

  final APIConfigRepository _apiConfigRepository;

  Future<void> _onAPIConfigInitialized(
    APIConfigInitialized event,
    Emitter<APIConfigState> emit,
  ) async {
    emit(state.copyWith(status: APIConfigStatus.loading));

    try {
      // Get OpenAI configuration
      final openAIConfig = await _apiConfigRepository.getOpenAIConfig();

      // Determine active provider based on OpenAI config
      final activeProvider =
          openAIConfig.enabled ? AIProvider.openAI : AIProvider.gemini;

      emit(
        state.copyWith(
          status: APIConfigStatus.loaded,
          activeProvider: activeProvider,
          openAIConfig: openAIConfig,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: APIConfigStatus.error,
          error: "Failed to load API configuration: $error",
        ),
      );
    }
  }

  Future<void> _onOpenAIConfigUpdated(
    OpenAIConfigUpdated event,
    Emitter<APIConfigState> emit,
  ) async {
    emit(state.copyWith(status: APIConfigStatus.loading));

    try {
      await _apiConfigRepository.saveOpenAIConfig(event.config);

      // Determine active provider based on new OpenAI config
      final activeProvider =
          event.config.enabled ? AIProvider.openAI : AIProvider.gemini;

      emit(
        state.copyWith(
          status: APIConfigStatus.loaded,
          activeProvider: activeProvider,
          openAIConfig: event.config,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: APIConfigStatus.error,
          error: "Failed to update OpenAI configuration: $error",
        ),
      );
    }
  }
}
