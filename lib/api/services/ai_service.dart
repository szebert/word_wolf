import "../../game/models/word_pair_results.dart";
import "../../l10n/l10n.dart";

/// {@template ai_service}
/// Interface for AI services that generate word pairs
/// {@endtemplate}
abstract class AIService {
  /// {@macro ai_service}
  const AIService();

  /// Generates a word pair using an AI service
  ///
  /// [category] - The category for the words (optional)
  /// [similarity] - How similar the words should be (0.0-1.0)
  /// [excludeWords] - Words to exclude from generation
  /// [l10n] - Localization for text
  Future<WordPairResult?> generateWordPair({
    required String category,
    required double similarity,
    required List<String> excludeWords,
    required AppLocalizations l10n,
  });

  /// Check if the service is available and properly configured
  bool get isConfigured;
}
