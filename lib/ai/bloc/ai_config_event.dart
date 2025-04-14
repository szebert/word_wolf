part of "ai_config_bloc.dart";

abstract class AIConfigEvent extends Equatable {
  const AIConfigEvent();

  @override
  List<Object> get props => [];
}

class AIConfigInitialized extends AIConfigEvent {
  const AIConfigInitialized();
}

/// Event to update OpenAI configuration
class OpenAIConfigUpdated extends AIConfigEvent {
  const OpenAIConfigUpdated({
    required this.config,
    required this.l10n,
  });

  final OpenAIConfig config;
  final AppLocalizations l10n;

  @override
  List<Object> get props => [config, l10n];
}
