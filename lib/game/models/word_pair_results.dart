/// Represents an icebreaker to help facilitate discussion
class Icebreaker {
  /// Short label for the icebreaker
  final String label;

  /// The icebreaker statement or question
  final String statement;

  Icebreaker({
    required this.label,
    required this.statement,
  });

  /// Creates an Icebreaker from a map
  factory Icebreaker.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey("label") || !map.containsKey("statement")) {
      throw FormatException(
        "Invalid format: icebreaker must have label and statement",
      );
    }

    return Icebreaker(
      label: map["label"] as String,
      statement: map["statement"] as String,
    );
  }

  /// Converts to a Map representation
  Map<String, dynamic> toMap() {
    return {
      "label": label,
      "statement": statement,
    };
  }
}

/// Represents the result of a word pair request
class WordPairResult {
  /// List of words in the pair
  final List<String> words;

  /// Category the words belong to
  final String category;

  /// List of icebreakers for this word pair
  final List<Icebreaker> icebreakers;

  WordPairResult({
    required this.words,
    this.category = "",
    this.icebreakers = const [],
  }) {
    // Validate the structure
    if (words.isEmpty) {
      throw FormatException("Invalid format: must contain at least one word");
    }
  }

  /// Creates a WordPairResult from a map, with validation
  static WordPairResult fromMap(Map<String, dynamic> map) {
    // Validate required fields exist
    if (!map.containsKey("words")) {
      throw FormatException(
        "Invalid format: missing required words field",
      );
    }

    final wordsValue = map["words"];
    // Category is optional, default to empty string
    final categoryValue = map["category"] as String? ?? "";

    // Icebreakers are optional
    final icebreakersValue = map["icebreakers"] as List? ?? [];

    // Validate types
    if (wordsValue is! List) {
      throw FormatException(
        "Invalid format: words field must be a list",
      );
    }

    // Convert and validate words list
    final wordsList = List<String>.from(
      wordsValue.map((item) {
        if (item is! String) {
          throw FormatException(
            "Invalid format: words must be strings",
          );
        }
        return item;
      }),
    );

    if (wordsList.length < 2) {
      throw FormatException(
        "Invalid format: must contain at least two words",
      );
    }

    // Convert icebreakers list
    final icebreakersList = List<Icebreaker>.from(
      icebreakersValue
          .map((item) => Icebreaker.fromMap(item as Map<String, dynamic>)),
    );

    return WordPairResult(
      words: wordsList,
      category: categoryValue,
      icebreakers: icebreakersList,
    );
  }

  /// Converts to a Map representation
  Map<String, dynamic> toMap() {
    return {
      "words": words,
      "category": category,
      "icebreakers":
          icebreakers.map((icebreaker) => icebreaker.toMap()).toList(),
    };
  }
}
