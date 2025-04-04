import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/word_pair_results.dart';
import 'used_words_storage.dart';

/// {@template word_pair_service}
/// Service for managing word pairs for the game.
/// Can provide word pairs from offline data or API.
/// {@endtemplate}
class WordPairService {
  /// {@macro word_pair_service}
  WordPairService({
    required UsedWordsStorage usedWordsStorage,
  }) : _usedWordsStorage = usedWordsStorage;

  final UsedWordsStorage _usedWordsStorage;
  static const String _kOfflineWordsPath = 'assets/data/offline_words.json';
  List<Map<String, dynamic>>? _offlinePairsCache;

  /// Loads word pairs from the offline JSON file
  Future<List<Map<String, dynamic>>> _loadOfflineWordPairs() async {
    if (_offlinePairsCache != null) {
      return _offlinePairsCache!;
    }

    try {
      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString(_kOfflineWordsPath);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Extract the pairs list
      final pairs = List<Map<String, dynamic>>.from(
        (data['pairs'] as List).map((e) => e as Map<String, dynamic>),
      );

      // Cache the results
      _offlinePairsCache = pairs;

      return pairs;
    } catch (e) {
      // If loading fails, return a default pair
      return [
        {
          'words': ['Cat', 'Dog'],
          'category': 'Animals',
        },
      ];
    }
  }

  /// Returns a random word pair result with specified category and similarity
  Future<WordPairResult> getRandomOfflineWordPair({
    List<String> excludeWords = const [],
  }) async {
    final random = Random();
    final pairs = await _loadOfflineWordPairs();

    // Filter out pairs containing any of the excluded words (case insensitive)
    final lowerExcludeWords = excludeWords.map((w) => w.toLowerCase()).toList();

    // Filter pairs that don't contain any excluded words
    final eligiblePairs = pairs.where((pair) {
      final words = (pair['words'] as List).cast<String>();
      // Check if any word in this pair is in the excluded list
      return !words
          .any((word) => lowerExcludeWords.contains(word.toLowerCase()));
    }).toList();

    // If all pairs are excluded (extreme case), just use all pairs
    final pairsToUse = eligiblePairs.isNotEmpty ? eligiblePairs : pairs;

    // Select random pair from the filtered list
    final randomPair = pairsToUse[random.nextInt(pairsToUse.length)];

    // Create a WordPairResult and validate it
    final result = WordPairResult.fromMap(randomPair);

    // Shuffle the words
    final shuffledWords = List<String>.from(result.words)..shuffle();

    // Create a new result with shuffled words
    return WordPairResult(
      words: shuffledWords,
      category: result.category,
    );
  }

  /// Returns a random word pair result with specified category and similarity
  Future<WordPairResult> getRandomWordPair({
    String category = '',
    double similarity = 0.5,
  }) async {
    // Get previously used words if storage is available
    List<String> previouslyUsedWords =
        await _usedWordsStorage.getPreviouslyUsedWords();

    // TODO: Implement online word pair retrieval

    // Get random pair, excluding previously used words
    final result = await getRandomOfflineWordPair(
      excludeWords: previouslyUsedWords,
    );

    // Store the new words for future use
    await _usedWordsStorage.addUsedWords(result.words);

    return result;
  }
}
