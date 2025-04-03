/// Represents the result of a word pair request
class WordPairResult {
  /// List of words in the pair
  final List<String> words;

  /// Category the words belong to
  final String category;

  WordPairResult({
    required this.words,
    this.category = '',
  }) {
    // Validate the structure
    if (words.isEmpty) {
      throw FormatException('Invalid format: must contain at least one word');
    }
  }

  /// Creates a WordPairResult from a map, with validation
  static WordPairResult fromMap(Map<String, dynamic> map) {
    // Validate required fields exist
    if (!map.containsKey('words')) {
      throw FormatException(
        'Invalid format: missing required words field',
      );
    }

    final wordsValue = map['words'];
    // Category is optional, default to empty string
    final categoryValue = map['category'] as String? ?? '';

    // Validate types
    if (wordsValue is! List) {
      throw FormatException(
        'Invalid format: words field must be a list',
      );
    }

    // Convert and validate words list
    final wordsList = List<String>.from(
      wordsValue.map((item) {
        if (item is! String) {
          throw FormatException(
            'Invalid format: words must be strings',
          );
        }
        return item;
      }),
    );

    if (wordsList.length < 2) {
      throw FormatException(
        'Invalid format: must contain at least two words',
      );
    }

    return WordPairResult(
      words: wordsList,
      category: categoryValue,
    );
  }

  /// Converts to a Map representation
  Map<String, dynamic> toMap() {
    return {
      'words': words,
      'category': category,
    };
  }
}
