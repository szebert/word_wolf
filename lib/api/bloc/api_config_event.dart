part of "api_config_bloc.dart";

abstract class APIConfigEvent extends Equatable {
  const APIConfigEvent();

  @override
  List<Object> get props => [];
}

class APIConfigInitialized extends APIConfigEvent {
  const APIConfigInitialized();
}

/// Event to update OpenAI configuration
class OpenAIConfigUpdated extends APIConfigEvent {
  const OpenAIConfigUpdated({
    required this.config,
  });

  final OpenAIConfig config;

  @override
  List<Object> get props => [config];
}
