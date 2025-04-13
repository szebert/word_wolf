/// {@template ai_service}
/// Generic interface for AI services that generate structured responses
/// {@endtemplate}
abstract class AIService {
  /// {@macro ai_service}
  const AIService();

  /// Generates a structured JSON response from the AI service
  ///
  /// [systemPrompt] - System instructions for the AI
  /// [userPrompt] - User query or instructions
  /// [schema] - The schema for structured output
  Future<Map<String, dynamic>?> generateStructuredResponse({
    required String systemPrompt,
    required String userPrompt,
    required Map<String, dynamic> schema,
  });

  /// Check if the service is available and properly configured
  bool get isConfigured;
}
