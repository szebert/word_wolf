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
    required this.l10n,
  });

  final OpenAIConfig config;
  final AppLocalizations l10n;

  @override
  List<Object> get props => [config, l10n];
}
