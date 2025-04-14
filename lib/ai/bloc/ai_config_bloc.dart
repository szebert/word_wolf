import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";

import "../../l10n/l10n.dart";
import "../models/ai_provider.dart";
import "../repository/ai_config_repository.dart";
import "../services/openai_service.dart";

part "ai_config_event.dart";
part "ai_config_state.dart";

class AIConfigBloc extends Bloc<AIConfigEvent, AIConfigState> {
  AIConfigBloc({
    required AIConfigRepository aiConfigRepository,
  })  : _aiConfigRepository = aiConfigRepository,
        _openAIService = OpenAIService(
          config: OpenAIConfig.defaultConfig,
        ),
        super(const AIConfigState.initial()) {
    on<AIConfigInitialized>(_onAPIConfigInitialized);
    on<OpenAIConfigUpdated>(_onOpenAIConfigUpdated);
  }

  final AIConfigRepository _aiConfigRepository;
  final OpenAIService _openAIService;

  Future<void> _onAPIConfigInitialized(
    AIConfigInitialized event,
    Emitter<AIConfigState> emit,
  ) async {
    emit(state.copyWith(status: AIConfigStatus.loading));

    try {
      // Get OpenAI configuration
      final openAIConfig = await _aiConfigRepository.getOpenAIConfig();
      _openAIService.updateConfig(openAIConfig);

      // Determine active provider based on OpenAI config
      final activeProvider =
          openAIConfig.enabled ? AIProvider.openAI : AIProvider.gemini;

      emit(
        state.copyWith(
          status: AIConfigStatus.loaded,
          activeProvider: activeProvider,
          openAIConfig: openAIConfig,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AIConfigStatus.error,
          error: "Failed to load API configuration: $error",
        ),
      );
    }
  }

  Future<void> _onOpenAIConfigUpdated(
    OpenAIConfigUpdated event,
    Emitter<AIConfigState> emit,
  ) async {
    emit(state.copyWith(status: AIConfigStatus.loading));

    try {
      // Only test if OpenAI is enabled
      if (event.config.enabled) {
        _openAIService.updateConfig(event.config);
        final error = await _openAIService.testConfiguration();

        if (error != null) {
          emit(
            state.copyWith(
              status: AIConfigStatus.error,
              error: OpenAIService.getErrorMessage(error, event.l10n),
            ),
          );
          return;
        }
      }

      await _aiConfigRepository.saveOpenAIConfig(event.config);

      // Determine active provider based on new OpenAI config
      final activeProvider =
          event.config.enabled ? AIProvider.openAI : AIProvider.gemini;

      emit(
        state.copyWith(
          status: AIConfigStatus.loaded,
          activeProvider: activeProvider,
          openAIConfig: event.config,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AIConfigStatus.error,
          error: "Failed to update OpenAI configuration: $error",
        ),
      );
    }
  }
}
