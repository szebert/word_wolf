import "dart:math";

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

/// Represents the structured words object in the word pair result
class Words {
  /// The first word in the word pair
  final String firstWord;

  /// Alternative words for the first word
  final List<String> firstAlternative;

  /// The second word in the word pair
  final String secondWord;

  /// Alternative words for the second word
  final List<String> secondAlternative;

  Words({
    required this.firstWord,
    required this.secondWord,
    this.firstAlternative = const [],
    this.secondAlternative = const [],
  });

  /// Shuffles the words in the Words object
  Words shuffle() {
    // randomize between first and second word
    final random = Random();
    final coinFlip = random.nextBool();
    final firstWord = coinFlip ? this.firstWord : this.secondWord;
    final secondWord = coinFlip ? this.secondWord : this.firstWord;
    return Words(
      firstWord: firstWord,
      secondWord: secondWord,
      firstAlternative: firstAlternative,
      secondAlternative: secondAlternative,
    );
  }

  /// Creates a Words object from a map
  factory Words.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey("first_word") || !map.containsKey("second_word")) {
      throw FormatException(
        "Invalid format: words object must contain first_word and second_word",
      );
    }

    final firstWord = map["first_word"] as String;
    final secondWord = map["second_word"] as String;

    List<String> firstAlternative = [];
    if (map.containsKey("first_alternative") &&
        map["first_alternative"] is List) {
      firstAlternative = List<String>.from(map["first_alternative"] as List);
    }

    List<String> secondAlternative = [];
    if (map.containsKey("second_alternative") &&
        map["second_alternative"] is List) {
      secondAlternative = List<String>.from(map["second_alternative"] as List);
    }

    return Words(
      firstWord: firstWord,
      secondWord: secondWord,
      firstAlternative: firstAlternative,
      secondAlternative: secondAlternative,
    );
  }

  /// Converts to a Map representation
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      "first_word": firstWord,
      "second_word": secondWord,
    };

    if (firstAlternative.isNotEmpty) {
      map["first_alternative"] = firstAlternative;
    }

    if (secondAlternative.isNotEmpty) {
      map["second_alternative"] = secondAlternative;
    }

    return map;
  }
}

/// Represents the result of a word pair request
class WordPairResult {
  /// Structured words object
  final Words words;

  /// Category the words belong to
  final String category;

  /// List of icebreakers for this word pair
  final List<Icebreaker> icebreakers;

  WordPairResult({
    required this.words,
    this.category = "",
    this.icebreakers = const [],
  });

  /// Updates a WordPairResult object to avoid words in the exclude list
  WordPairResult avoidingWords({
    required List<String> excludeWords,
  }) {
    // Convert exclude words to lowercase for case-insensitive comparison
    final lowerExcludeWords = excludeWords.map((w) => w.toLowerCase()).toList();

    // Try to find a non-excluded first word
    String selectedFirstWord = words.firstWord;

    // Check if current first word is excluded
    if (lowerExcludeWords.contains(selectedFirstWord.toLowerCase())) {
      // Try to find an alternative not in the exclude list
      final availableAlternatives = words.firstAlternative
          .where((w) => !lowerExcludeWords.contains(w.toLowerCase()))
          .toList();

      if (availableAlternatives.isNotEmpty) {
        // Pick a random non-excluded alternative
        selectedFirstWord = availableAlternatives[
            Random().nextInt(availableAlternatives.length)];
      }
    }

    // Try to find a non-excluded second word
    String selectedSecondWord = words.secondWord;

    // Check if current second word is excluded
    if (lowerExcludeWords.contains(selectedSecondWord.toLowerCase())) {
      // Try to find an alternative not in the exclude list
      final availableAlternatives = words.secondAlternative
          .where((w) => !lowerExcludeWords.contains(w.toLowerCase()))
          .toList();

      if (availableAlternatives.isNotEmpty) {
        // Pick a random non-excluded alternative
        selectedSecondWord = availableAlternatives[
            Random().nextInt(availableAlternatives.length)];
      }
    }

    return WordPairResult(
      words: Words(
        firstWord: selectedFirstWord,
        secondWord: selectedSecondWord,
        firstAlternative: words.firstAlternative,
        secondAlternative: words.secondAlternative,
      ),
      category: category,
      icebreakers: icebreakers,
    );
  }

  /// Shuffles the words in the WordPairResult
  WordPairResult shuffle() {
    return WordPairResult(
      words: words.shuffle(),
      category: category,
      icebreakers: icebreakers,
    );
  }

  /// Creates a WordPairResult from a map, with validation
  factory WordPairResult.fromMap(Map<String, dynamic> map) {
    // Category is optional, default to empty string
    final categoryValue = map["category"] as String? ?? "";
    // Icebreakers are optional
    final icebreakersValue = map["icebreakers"] as List? ?? [];
    // Convert icebreakers list
    final icebreakersList = List<Icebreaker>.from(
      icebreakersValue
          .map((item) => Icebreaker.fromMap(item as Map<String, dynamic>)),
    );

    // Check if words exists in the map
    if (!map.containsKey("words")) {
      throw FormatException(
        "Invalid format: missing required words field",
      );
    }

    final wordsValue = map["words"];
    Words wordsObj;

    if (wordsValue is Map<String, dynamic>) {
      // New schema with structured words
      wordsObj = Words.fromMap(wordsValue);
    } else {
      throw FormatException(
        "Invalid format: words field must be an object",
      );
    }

    return WordPairResult(
      words: wordsObj,
      category: categoryValue,
      icebreakers: icebreakersList,
    );
  }

  /// Converts to a Map representation
  Map<String, dynamic> toMap() {
    return {
      "words": words.toMap(),
      "category": category,
      "icebreakers":
          icebreakers.map((icebreaker) => icebreaker.toMap()).toList(),
    };
  }
}
