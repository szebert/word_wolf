import 'dart:convert';

import '../../storage/storage.dart';

/// {@template used_words_storage}
/// Service for managing the storage of previously used words
/// to avoid repetition in word pairs
/// {@endtemplate}
class UsedWordsStorage {
  /// {@macro used_words_storage}
  UsedWordsStorage({
    required Storage storage,
  }) : _storage = storage;

  final Storage _storage;
  static const String _storageKey = 'previously_used_words';
  static const int _maxStoredWords = 50;

  /// Retrieves the list of previously used words
  Future<List<String>> getPreviouslyUsedWords() async {
    try {
      final storedData = await _storage.read(key: _storageKey);
      if (storedData == null || storedData.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(storedData) as List<dynamic>;
      return decodedList.cast<String>();
    } catch (e) {
      // If there's an error reading, return an empty list
      return [];
    }
  }

  /// Adds new words to the list of previously used words
  /// Maintains a maximum of [_maxStoredWords] by removing oldest entries
  Future<void> addUsedWords(List<String> newWords) async {
    try {
      // Get current words
      final currentWords = await getPreviouslyUsedWords();

      // Add new words (ensuring uniqueness)
      final Set<String> uniqueWords = {...currentWords};
      for (final word in newWords) {
        // Only add words that aren't already in the list
        uniqueWords.add(word.toLowerCase().trim());
      }

      // Convert back to list and limit size
      final List<String> updatedWords = uniqueWords.toList();
      if (updatedWords.length > _maxStoredWords) {
        // Remove oldest words to maintain max size
        updatedWords.removeRange(0, updatedWords.length - _maxStoredWords);
      }

      // Save to storage
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(updatedWords),
      );
    } catch (e) {
      // Silently handle errors - we don't want this to crash the app
      // if storage fails
    }
  }

  /// Clears all previously used words
  Future<void> clearUsedWords() async {
    await _storage.delete(key: _storageKey);
  }
}
