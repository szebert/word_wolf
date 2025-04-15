import "dart:async";
import "dart:convert";
import "dart:math";

import "package:flutter/services.dart";

import "../../ai/ai.dart";
import "../../analytics/analytics.dart";
import "../../l10n/l10n.dart";
import "../models/game.dart";
import "../models/word_pair_results.dart";
import "used_words_storage.dart";

/// Schema for generating word pairs with AI
class WordPairSchema {
  /// Gets the schema for word pair generation
  static Map<String, dynamic> getSchema() {
    return {
      "type": "object",
      "properties": {
        "category": {
          "type": "string",
          "description": "The general category for the word pair."
        },
        "words": {
          "type": "object",
          "properties": {
            "first_word": {
              "type": "string",
              "description": "The first word in the word pair."
            },
            "first_alternative": {
              "type": "array",
              "description":
                  "A list of 5-10 words that would fit as an alternative to the first word in the word pair.",
              "items": {"type": "string"}
            },
            "second_word": {
              "type": "string",
              "description": "The second word in the word pair."
            },
            "second_alternative": {
              "type": "array",
              "description":
                  "A list of 5-10 words that would fit as an alternative to the second word in the word pair.",
              "items": {"type": "string"}
            },
          },
          "required": [
            "first_word",
            "second_word",
            "first_alternative",
            "second_alternative"
          ],
          "additionalProperties": false
        },
        "icebreakers": {
          "type": "array",
          "description":
              "Between 3 to 6 neutral icebreaker statements to encourage discussion.",
          "items": {
            "type": "object",
            "properties": {
              "label": {
                "type": "string",
                "description": "Concise 1-2 word label."
              },
              "statement": {
                "type": "string",
                "description":
                    "Engaging conversational icebreaker that shall never include the the word pair or any of the alternatives."
              }
            },
            "required": ["label", "statement"],
            "additionalProperties": false
          }
        }
      },
      "required": ["category", "words", "icebreakers"],
      "additionalProperties": false
    };
  }
}

/// Handles generating prompts for AI services
class WordPairPromptGenerator {
  /// Generates the system prompt for word pair generation
  static String getSystemPrompt() {
    return """
You are a helpful, creative assistant who generates word pairs and 3-6 relevant icebreaker prompts for an engaging and fun 'Word Wolf' game. Every player is given a secret word (or short phrase). The majority of players (citizens) are each given the same secret word, and the minority (wolf/wolves) are secretly given a different one. No one knows if they are a citizen or a wolf.

The word pair should be roughly within the same category, though this is not strictly required. The word pairs shall never be the category itself.

Each pair must consist of entirely distinct lexical roots—never pairs that differ by prefixes (e.g., "anti-", "bi-", "counter-", "dis-", "un-") or suffixes (e.g., "-less", "-ful", "-tion", "-al"), such as "cycle"/"bicycle", "claim"/"counterclaim", "thesis"/"antithesis", "directional"/"bidirectional", "concord"/"discord", or "happy"/"unhappy".

Generate icebreakers that are neutral and inclusive to encourage discussion of the word pairs without benefiting citizens or wolves, and without revealing details about the secret word pair. The icebreakers shall never explicitly include the words from the word pair.

For each word in the pair, provide legitimate alternative words or short phrases that could feasibly replace the original word in the same category or context. For example, if the category is "90s movies" and you pick "Titanic," then suitable alternatives might include "Romeo + Juliet," "The English Patient," "Sleepless in Seattle," "Ghost," or "Pretty Woman." In contrast, purely descriptive terms like "boat," "ocean," "love," or "ship" are not acceptable as alternatives, because they are not legitimate replacements of the original word in that category.

Ensure all responses comply with any excluded words or phrases specified by the user.
""";
  }

  /// Generates the user prompt for word pair generation
  static String getUserPrompt({
    required String category,
    required double similarity,
    required List<String> excludeWords,
    required AppLocalizations l10n,
  }) {
    return """
Generate a word pair and relevant icebreakers for a 'Word Wolf' game.

${category.isEmpty ? "There is currently no assigned category to the word pair." : "The category is '$category'."}

On a scale of 0.0 to 1.0, where 0.0 means the words are near identical (e.g. 'Sofa' and 'Couch') in meaning, where 0.3 means there's a strong connection between the words (e.g. 'Sofa' and 'Coffee table'), where 0.5 means they have some vague similarity (e.g. 'Sofa' and 'Indoors'), where 0.7 means they have almost no connection at all (e.g. 'Sofa' and 'Helicopter'), and where 1.0 means they have no connection at all and are extremely different in meaning and/or concept (e.g. 'Sofa' and 'Algebra'), the current word pair would be a $similarity (${Game.getSimilarityDescription(l10n, similarity)}) on that scale.

${excludeWords.isNotEmpty ? "You must NEVER use any of these in either of the words in the word pair: ${excludeWords.join(', ')}." : ""}

${category.isEmpty ? "The icebreakers should be extremely general, and not specific to the word pair since the players won't know the assigned category." : ""}
""";
  }
}

/// {@template word_pair_service}
/// Service for generating word pairs for the game.
/// Uses AI services to generate new words based on categories and similarity.
/// Has fallback to offline words if AI services are unavailable.
/// {@endtemplate}
class WordPairService {
  /// {@macro word_pair_service}
  WordPairService({
    required UsedWordsStorage usedWordsStorage,
    AIServiceManager? aiServiceManager,
    LoggingService? loggingService,
  })  : _usedWordsStorage = usedWordsStorage,
        _aiServiceManager = aiServiceManager,
        _loggingService = loggingService ?? LoggingService();

  final UsedWordsStorage _usedWordsStorage;
  final AIServiceManager? _aiServiceManager;
  final LoggingService _loggingService;
  static const String _kOfflineWordsPath = "assets/data/offline_words.json";
  List<WordPairResult>? _offlinePairsCache;

  /// Check if the AI service is properly configured
  Future<bool> get isAIConfigured async =>
      _aiServiceManager != null ? await _aiServiceManager.isConfigured : false;

  /// Loads word pairs from the offline JSON file
  Future<List<WordPairResult>> _loadOfflineWordPairs() async {
    if (_offlinePairsCache != null) {
      return _offlinePairsCache!;
    }

    try {
      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString(_kOfflineWordsPath);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Extract the pairs list
      final pairs = List<WordPairResult>.from(
        (data["pairs"] as List).map((e) => WordPairResult.fromMap(e)),
      );

      // Cache the results
      _offlinePairsCache = pairs;

      return pairs;
    } catch (e) {
      // If loading fails, return a default list of pairs
      return [
        WordPairResult(
          category: "Fruits",
          words: Words(
            firstWord: "Apple",
            secondWord: "Banana",
            firstAlternative: ["Orange", "Pear", "Grape", "Kiwi", "Mango"],
            secondAlternative: [
              "Pineapple",
              "Watermelon",
              "Strawberry",
              "Cherry",
              "Peach"
            ],
          ),
          icebreakers: [
            Icebreaker(
              label: "When",
              statement: "When was the last time you ate this fruit?",
            ),
            Icebreaker(
              label: "Preference",
              statement:
                  "How do you prefer to eat this fruit - raw, cooked, or in a dish?",
            ),
            Icebreaker(
              label: "Memory",
              statement: "Share a childhood memory involving this fruit.",
            ),
          ],
        ),
        WordPairResult(
          category: "Sports",
          words: Words(
            firstWord: "Basketball",
            secondWord: "Hockey",
            firstAlternative: [
              "Football",
              "Tennis",
              "Golf",
              "Cricket",
              "Baseball"
            ],
            secondAlternative: [
              "Soccer",
              "Volleyball",
              "Track and Field",
              "Gymnastics",
              "Swimming"
            ],
          ),
          icebreakers: [
            Icebreaker(
              label: "Experience",
              statement: "Have you ever played or watched this sport?",
            ),
            Icebreaker(
              label: "Famous",
              statement: "Name a famous player in this sport you admire.",
            ),
            Icebreaker(
              label: "Rules",
              statement:
                  "Explain one rule of this sport that you find interesting.",
            ),
          ],
        ),
        WordPairResult(
          category: "Vehicles",
          words: Words(
            firstWord: "Car",
            secondWord: "Truck",
            firstAlternative: [
              "Motorcycle",
              "Scooter",
              "Van",
              "Jeep",
              "Convertible"
            ],
            secondAlternative: [
              "Pickup",
              "Semi",
              "Trailer",
              "Lorry",
              "Dump Truck"
            ],
          ),
          icebreakers: [
            Icebreaker(
              label: "Dream",
              statement: "Describe your dream version of this vehicle.",
            ),
            Icebreaker(
              label: "Memory",
              statement:
                  "What's a memorable journey you've taken in this type of vehicle?",
            ),
            Icebreaker(
              label: "Feature",
              statement:
                  "What feature do you think is most important in this vehicle?",
            ),
          ],
        ),
        WordPairResult(
          category: "Musical Instruments",
          words: Words(
            firstWord: "Guitar",
            secondWord: "Piano",
            firstAlternative: ["Ukulele", "Banjo", "Mandolin", "Bass", "Harp"],
            secondAlternative: [
              "Keyboard",
              "Organ",
              "Harpsichord",
              "Synthesizer",
              "Accordion"
            ],
          ),
          icebreakers: [
            Icebreaker(
              label: "Play",
              statement: "Have you ever tried to play this instrument?",
            ),
            Icebreaker(
              label: "Song",
              statement: "What's a famous song featuring this instrument?",
            ),
            Icebreaker(
              label: "Musician",
              statement:
                  "Who's your favorite musician who plays this instrument?",
            ),
          ],
        ),
        WordPairResult(
          category: "Animals",
          words: Words(
            firstWord: "Cat",
            secondWord: "Dog",
            firstAlternative: [
              "Hamster",
              "Rabbit",
              "Guinea Pig",
              "Ferret",
              "Parakeet"
            ],
            secondAlternative: ["Fish", "Bird", "Turtle", "Lizard", "Snake"],
          ),
          icebreakers: [
            Icebreaker(
              label: "Pet",
              statement: "Have you ever had this animal as a pet?",
            ),
            Icebreaker(
              label: "Breed",
              statement: "What's your favorite breed of this animal?",
            ),
            Icebreaker(
              label: "Interaction",
              statement:
                  "Describe a memorable interaction you've had with this animal.",
            ),
          ],
        ),
      ];
    }
  }

  /// Returns a random word pair result with specified category and similarity
  Future<WordPairResult> getRandomOfflineWordPair() async {
    final random = Random();
    final pairs = await _loadOfflineWordPairs();

    // Get previously used words if storage is available
    List<String> previouslyUsedWords =
        await _usedWordsStorage.getPreviouslyUsedWords();

    // Filter out pairs containing any of the previously used words (case insensitive)
    final lowerExcludeWords =
        previouslyUsedWords.map((w) => w.toLowerCase()).toList();

    // Filter pairs that don't contain any excluded words
    final eligiblePairs = pairs.where((pair) {
      final firstWord = pair.words.firstWord;
      final secondWord = pair.words.secondWord;
      // Check if any word in this pair is in the excluded list
      return !lowerExcludeWords.contains(firstWord.toLowerCase()) &&
          !lowerExcludeWords.contains(secondWord.toLowerCase());
    }).toList();

    // If all pairs are excluded (extreme case), just use all pairs
    WordPairResult pairsToUse;
    if (eligiblePairs.isNotEmpty) {
      pairsToUse = eligiblePairs[random.nextInt(eligiblePairs.length)];
    } else {
      pairsToUse = pairs[random.nextInt(pairs.length)];
      // Use alternatives if possible
      pairsToUse = pairsToUse.avoidingWords(
        excludeWords: previouslyUsedWords,
      );
    }

    // Create a new result with shuffled words
    return pairsToUse.shuffle();
  }

  /// Returns a word pair result with specified category and similarity
  /// Uses AI API - will throw an exception if API is not configured or fails
  Future<WordPairResult> getRandomWordPair({
    String category = "",
    double similarity = 0.5,
    required AppLocalizations l10n,
  }) async {
    // Get previously used words if storage is available
    List<String> previouslyUsedWords =
        await _usedWordsStorage.getPreviouslyUsedWords();

    // Create prompts and schema for AI services
    final systemPrompt = WordPairPromptGenerator.getSystemPrompt();
    final userPrompt = WordPairPromptGenerator.getUserPrompt(
      category: category,
      similarity: similarity,
      excludeWords: previouslyUsedWords,
      l10n: l10n,
    );
    final schema = WordPairSchema.getSchema();

    // Try to get word pair from AI service manager
    if (_aiServiceManager == null) {
      throw Exception("AI service is not properly configured.");
    }

    final jsonResponse = await _aiServiceManager.generateStructuredResponse(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      schema: schema,
    );

    // Convert to WordPairResult if successful
    if (jsonResponse == null) {
      throw Exception("Failed to generate word pair from AI API.");
    }

    try {
      final wordPairResult = WordPairResult.fromMap(jsonResponse);

      // Apply additional processing
      final processedResult = wordPairResult
          .avoidingWords(
            excludeWords: previouslyUsedWords,
          )
          .shuffle();

      // Store the new words for future use
      await _usedWordsStorage.addUsedWords(processedResult.words);

      return processedResult;
    } catch (e) {
      _loggingService.logError(
        e,
        StackTrace.current,
        reason: "Error converting AI response to WordPairResult",
        information: ["JSON response: $jsonResponse"],
      );
      throw Exception(
          "Failed to convert AI response to a valid WordPair object.");
    }
  }
}
