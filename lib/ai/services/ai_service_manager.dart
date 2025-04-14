import "package:http/http.dart" as http;

import "../../analytics/services/logging_service.dart";
import "../models/ai_provider.dart";
import "../repository/ai_config_repository.dart";
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
    required AIConfigRepository aiConfigRepository,
    http.Client? httpClient,
    LoggingService? loggingService,
  })  : _apiConfigRepository = aiConfigRepository,
        _httpClient = httpClient ?? http.Client(),
        _loggingService = loggingService ?? LoggingService() {
    _initializeServices();
  }

  final AIConfigRepository _apiConfigRepository;
  final http.Client _httpClient;
  final LoggingService _loggingService;

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
      loggingService: _loggingService,
    );

    // Initialize Gemini service without configuration
    // It will use Firebase Vertex AI
    _geminiService = GeminiService(
      loggingService: _loggingService,
    );
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

  /// Generate a structured response from the active AI service
  Future<Map<String, dynamic>?> generateStructuredResponse({
    required String systemPrompt,
    required String userPrompt,
    required Map<String, dynamic> schema,
  }) async {
    final activeProvider = await getActiveProvider();

    // Try the active provider first
    Map<String, dynamic>? result;
    if (activeProvider == AIProvider.openAI && _openAIService.isConfigured) {
      try {
        result = await _openAIService.generateStructuredResponse(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          schema: schema,
        );
      } catch (e) {
        _loggingService.logError(
          e,
          StackTrace.current,
          reason: "Error generating response with OpenAI",
        );
      }
    }

    // If OpenAI failed or wasn't used, try Gemini
    if (result == null) {
      try {
        result = await _geminiService.generateStructuredResponse(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          schema: schema,
        );
      } catch (e) {
        _loggingService.logError(
          e,
          StackTrace.current,
          reason: "Error generating response with Gemini",
        );
      }
    }

    return result;
  }
}
