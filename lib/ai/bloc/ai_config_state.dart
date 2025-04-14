part of "ai_config_bloc.dart";

enum AIConfigStatus {
  initial,
  loading,
  loaded,
  error,
}

class AIConfigState extends Equatable {
  const AIConfigState({
    this.status = AIConfigStatus.initial,
    this.activeProvider = AIProvider.gemini,
    this.openAIConfig = const OpenAIConfig(enabled: false),
    this.error,
  });

  const AIConfigState.initial()
      : status = AIConfigStatus.initial,
        activeProvider = AIProvider.gemini,
        openAIConfig = const OpenAIConfig(enabled: false),
        error = null;

  final AIConfigStatus status;
  final AIProvider activeProvider;
  final OpenAIConfig openAIConfig;
  final String? error;

  AIConfigState copyWith({
    AIConfigStatus? status,
    AIProvider? activeProvider,
    OpenAIConfig? openAIConfig,
    String? error,
  }) {
    return AIConfigState(
      status: status ?? this.status,
      activeProvider: activeProvider ?? this.activeProvider,
      openAIConfig: openAIConfig ?? this.openAIConfig,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeProvider,
        openAIConfig,
        error,
      ];
}
