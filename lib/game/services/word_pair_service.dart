import "dart:convert";
import "dart:math";

import "package:flutter/services.dart";

import "../../api/services/ai_service_manager.dart";
import "../../l10n/l10n.dart";
import "../models/word_pair_results.dart";
import "used_words_storage.dart";

/// {@template word_pair_service}
/// Service for managing word pairs for the game.
/// Can provide word pairs from offline data or AI API.
/// {@endtemplate}
class WordPairService {
  /// {@macro word_pair_service}
  WordPairService({
    required UsedWordsStorage usedWordsStorage,
    AIServiceManager? aiServiceManager,
  })  : _usedWordsStorage = usedWordsStorage,
        _aiServiceManager = aiServiceManager;

  final UsedWordsStorage _usedWordsStorage;
  final AIServiceManager? _aiServiceManager;
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

    // Try to get word pair from AI service manager
    WordPairResult? aiWordPair;
    if (_aiServiceManager != null) {
      aiWordPair = await _aiServiceManager.generateWordPair(
        category: category,
        similarity: similarity,
        excludeWords: previouslyUsedWords,
        l10n: l10n,
      );

      // If AI word pair generation succeeded, use it
      if (aiWordPair != null) {
        aiWordPair = aiWordPair.avoidingWords(
          excludeWords: previouslyUsedWords,
        );

        // Create a new result with shuffled words
        aiWordPair = aiWordPair.shuffle();

        // Store the new words for future use
        await _usedWordsStorage.addUsedWords(aiWordPair.words);

        return aiWordPair;
      }
    }

    // If we get here, API call failed
    throw Exception("Failed to generate word pair from AI API");
  }
}
