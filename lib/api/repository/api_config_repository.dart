import "dart:convert";

import "../../storage/persistent_storage.dart";
import "../models/ai_provider.dart";

/// {@template api_config_repository}
/// Repository for managing API configurations with persistent storage.
/// {@endtemplate}
class APIConfigRepository {
  /// {@macro api_config_repository}
  APIConfigRepository({
    required PersistentStorage persistentStorage,
  }) : _persistentStorage = persistentStorage;

  final PersistentStorage _persistentStorage;
  static const String _kOpenAIConfigKey = "openai_config";

  /// Get the active AI provider based on configurations
  Future<AIProvider> getActiveProvider() async {
    final openAIConfig = await getOpenAIConfig();
    // If OpenAI is enabled, use it as the active provider, otherwise fall back to Gemini
    return openAIConfig.enabled ? AIProvider.openAI : AIProvider.gemini;
  }

  /// Get the OpenAI configuration
  Future<OpenAIConfig> getOpenAIConfig() async {
    try {
      final configJson = await _persistentStorage.read(key: _kOpenAIConfigKey);
      if (configJson == null || configJson.isEmpty) {
        // Return default config - OpenAI is disabled by default
        return const OpenAIConfig(enabled: false);
      }

      final map = jsonDecode(configJson) as Map<String, dynamic>;
      return OpenAIConfig.fromMap(map);
    } catch (e) {
      // If parsing fails, return default config
      return const OpenAIConfig(enabled: false);
    }
  }

  /// Save OpenAI configuration
  Future<void> saveOpenAIConfig(OpenAIConfig config) async {
    try {
      await _persistentStorage.write(
        key: _kOpenAIConfigKey,
        value: jsonEncode(config.toMap()),
      );
    } catch (e) {
      // Silently handle error
    }
  }
}
