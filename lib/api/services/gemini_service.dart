import "../../game/models/word_pair_results.dart";
import "../../l10n/l10n.dart";
import "ai_service.dart";

/// {@template gemini_service}
/// Service for generating word pairs using Google's Gemini AI through Firebase Vertex AI.
/// No configuration required as it uses Firebase project credentials.
/// {@endtemplate}
class GeminiService implements AIService {
  /// {@macro gemini_service}
  GeminiService();

  @override
  bool get isConfigured => true; // Always configured through Firebase

  @override
  Future<WordPairResult?> generateWordPair({
    required String category,
    required double similarity,
    required List<String> excludeWords,
    required AppLocalizations l10n,
  }) async {
    // Implementation will use the Firebase Vertex AI package
    // TODO: Add firebase_vertexai integration

    // Mock implementation for now (replace with actual implementation)
    return null;
  }
}
