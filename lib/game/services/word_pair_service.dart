import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/word_pair_results.dart';

/// {@template word_pair_service}
/// Service for managing word pairs for the game.
/// Can provide word pairs from offline data or API.
/// {@endtemplate}
class WordPairService {
  /// {@macro word_pair_service}
  WordPairService();

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
  Future<WordPairResult> getRandomOfflineWordPair() async {
    final random = Random();
    final pairs = await _loadOfflineWordPairs();

    // Select random pair from the offline list
    final randomPair = pairs[random.nextInt(pairs.length)];

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
    // TODO: Implement online word pair retrieval
    return getRandomOfflineWordPair();
  }
}
