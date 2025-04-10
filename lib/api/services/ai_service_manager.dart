import "package:http/http.dart" as http;

import "../../game/models/word_pair_results.dart";
import "../../l10n/l10n.dart";
import "../models/ai_provider.dart";
import "../repository/api_config_repository.dart";
import "gemini_service.dart";
import "openai_service.dart";

/// {@template ai_service_manager}
/// Manages multiple AI services and provides a unified interface.
/// Gemini AI is provided through Firebase Vertex AI and doesn't require configuration.
/// OpenAI is optional and requires an API key.
/// {@endtemplate}
class AIServiceManager {
  /// {@macro ai_service_manager}
  AIServiceManager({
    required APIConfigRepository apiConfigRepository,
    http.Client? httpClient,
  })  : _apiConfigRepository = apiConfigRepository,
        _httpClient = httpClient ?? http.Client() {
    _initializeServices();
  }

  final APIConfigRepository _apiConfigRepository;
  final http.Client _httpClient;

  late final OpenAIService _openAIService;
  late final GeminiService _geminiService;

  /// Initialize all AI services
  Future<void> _initializeServices() async {
    // Load OpenAI configuration from repository
    final openAIConfig = await _apiConfigRepository.getOpenAIConfig();

    // Create service instances
    _openAIService = OpenAIService(
      config: openAIConfig,
      httpClient: _httpClient,
    );

    // Initialize Gemini service without configuration
    // It will use Firebase Vertex AI
    _geminiService = GeminiService();
  }

  /// Update configurations for all services
  Future<void> refreshConfigurations() async {
    final openAIConfig = await _apiConfigRepository.getOpenAIConfig();
    _openAIService.updateConfig(openAIConfig);
    // No need to update Gemini as it uses Firebase
  }

  /// Get the current active provider
  Future<AIProvider> getActiveProvider() async {
    return _apiConfigRepository.getActiveProvider();
  }

  /// Save OpenAI configuration
  Future<void> saveOpenAIConfig(OpenAIConfig config) async {
    await _apiConfigRepository.saveOpenAIConfig(config);
    _openAIService.updateConfig(config);
  }

  /// Check if the active service is properly configured
  Future<bool> get isConfigured async {
    final activeProvider = await getActiveProvider();
    switch (activeProvider) {
      case AIProvider.openAI:
        return _openAIService.isConfigured;
      case AIProvider.gemini:
        return true; // Gemini is always configured as it uses Firebase
    }
  }

  /// Generate a word pair using the active AI service
  Future<WordPairResult?> generateWordPair({
    required String category,
    required double similarity,
    required List<String> excludeWords,
    required AppLocalizations l10n,
  }) async {
    final activeProvider = await getActiveProvider();

    // Try the active provider first
    WordPairResult? result;
    if (activeProvider == AIProvider.openAI && _openAIService.isConfigured) {
      try {
        result = await _openAIService.generateWordPair(
          category: category,
          similarity: similarity,
          excludeWords: excludeWords,
          l10n: l10n,
        );
      } catch (e) {
        print("Error generating word pair with OpenAI: $e");
      }
    }

    // If OpenAI failed or wasn't used, try Gemini
    if (result == null) {
      try {
        result = await _geminiService.generateWordPair(
          category: category,
          similarity: similarity,
          excludeWords: excludeWords,
          l10n: l10n,
        );
      } catch (e) {
        print("Error generating word pair with Gemini: $e");
      }
    }

    return result;
  }
}
