part of "api_config_bloc.dart";

enum APIConfigStatus {
  initial,
  loading,
  loaded,
  error,
}

class APIConfigState extends Equatable {
  const APIConfigState({
    this.status = APIConfigStatus.initial,
    this.activeProvider = AIProvider.gemini,
    this.openAIConfig = const OpenAIConfig(enabled: false),
    this.error,
  });

  const APIConfigState.initial()
      : status = APIConfigStatus.initial,
        activeProvider = AIProvider.gemini,
        openAIConfig = const OpenAIConfig(enabled: false),
        error = null;

  final APIConfigStatus status;
  final AIProvider activeProvider;
  final OpenAIConfig openAIConfig;
  final String? error;

  APIConfigState copyWith({
    APIConfigStatus? status,
    AIProvider? activeProvider,
    OpenAIConfig? openAIConfig,
    String? error,
  }) {
    return APIConfigState(
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
