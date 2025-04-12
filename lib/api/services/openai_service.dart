import "dart:convert";

import "package:http/http.dart" as http;

import "../../game/models/game.dart";
import "../../game/models/word_pair_results.dart";
import "../../l10n/l10n.dart";
import "../models/ai_provider.dart";
import "ai_service.dart";

/// Error types that can occur when testing OpenAI configuration
enum OpenAIConfigError {
  /// No network connection available
  offline,

  /// Invalid API key
  invalidKey,

  /// API key lacks required permissions
  insufficientPermissions,

  /// Selected model does not exist or you do not have access to it
  invalidModel,

  /// Selected model doesn't support JSON mode
  modelNotSupported,

  /// Unknown or unexpected error
  unknown,
}

/// {@template openai_service}
/// Implementation of [AIService] that uses OpenAI API to generate word pairs
/// {@endtemplate}
class OpenAIService implements AIService {
  /// {@macro openai_service}
  OpenAIService({
    required OpenAIConfig config,
    http.Client? httpClient,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client();

  OpenAIConfig _config;
  final http.Client _httpClient;

  /// Updates the API configuration
  void updateConfig(OpenAIConfig config) {
    _config = config;
  }

  @override
  bool get isConfigured => _config.isValid;

  /// Tests the OpenAI configuration by making a minimal API call
  /// Returns null if successful, or an [OpenAIConfigError] if there's an issue
  Future<OpenAIConfigError?> testConfiguration() async {
    if (!isConfigured) {
      return OpenAIConfigError.invalidKey;
    }

    try {
      final response = await _httpClient.post(
        Uri.parse(
          _config.apiUrl ?? "https://api.openai.com/v1/chat/completions",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_config.apiKey}",
        },
        body: jsonEncode({
          "model": _config.model,
          "messages": [
            {
              "role": "user",
              "content": "Test message",
            }
          ],
          "max_completion_tokens": 25,
          "response_format": {
            "type": "json_schema",
            "json_schema": {
              "name": "output",
              "strict": true,
              "schema": {
                "type": "object",
                "properties": {
                  "test": {"type": "string"}
                },
                "required": ["test"],
                "additionalProperties": false,
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        return null;
      }

      final error = jsonDecode(response.body) as Map<String, dynamic>;
      final errorCode = error["error"]?["code"] as String?;
      final errorMessage = error["error"]?["message"] as String?;

      if (errorCode == "invalid_api_key") {
        return OpenAIConfigError.invalidKey;
      }

      if (errorCode == "model_not_found") {
        return OpenAIConfigError.invalidModel;
      }

      if (errorMessage?.contains(
              "You have insufficient permissions for this operation.") ==
          true) {
        return OpenAIConfigError.insufficientPermissions;
      }

      if (errorMessage?.contains(
              "Invalid parameter: 'response_format' of type 'json_schema' is not supported with this model.") ==
          true) {
        return OpenAIConfigError.modelNotSupported;
      }

      return OpenAIConfigError.unknown;
    } on http.ClientException {
      return OpenAIConfigError.offline;
    } catch (e) {
      print("OpenAI test configuration error: $e");
      return OpenAIConfigError.unknown;
    }
  }

  /// Gets a user-friendly error message for an OpenAI configuration error
  static String getErrorMessage(
    OpenAIConfigError error,
    AppLocalizations l10n,
  ) {
    switch (error) {
      case OpenAIConfigError.offline:
        return l10n.openaiOfflineError;
      case OpenAIConfigError.invalidKey:
        return l10n.openaiInvalidKeyError;
      case OpenAIConfigError.insufficientPermissions:
        return l10n.openaiInsufficientPermissionsError;
      case OpenAIConfigError.invalidModel:
        return l10n.openaiInvalidModelError;
      case OpenAIConfigError.modelNotSupported:
        return l10n.openaiModelNotSupportedError;
      case OpenAIConfigError.unknown:
        return l10n.unknownError;
    }
  }

  @override
  Future<WordPairResult?> generateWordPair({
    required String category,
    required double similarity,
    required List<String> excludeWords,
    required AppLocalizations l10n,
  }) async {
    if (!isConfigured) {
      return null;
    }

    final systemContent = """
You are a helpful, creative assistant who generates word pairs and 3-6 relevant icebreaker prompts for an engaging and fun 'Word Wolf' game. Every player is given a secret word (or short phrase). The majority of players (citizens) are each given the same secret word, and the minority (wolf/wolves) are secretly given a different one. No one knows if they are a citizen or a wolf.

The word pair should be roughly within the same category, though this is not strictly required. The word pairs shall never be the category itself.

Each pair must consist of entirely distinct lexical roots—never pairs that differ by prefixes (e.g., "anti-", "bi-", "counter-", "dis-", "un-") or suffixes (e.g., "-less", "-ful", "-tion", "-al"), such as "claim"/"counterclaim", "thesis"/"antithesis", "directional"/"bidirectional", "concord"/"discord", or "happy"/"unhappy".

Generate icebreakers that are neutral and inclusive to encourage discussion of the word pairs without benefiting citizens or wolves, and without revealing details about the secret word pair. The icebreakers shall never explicitly include the words from the word pair.

**For each word in the pair, provide legitimate alternative words or short phrases that could feasibly replace the original word in the same category or context.** For example, if the category is "90s movies" and you pick "Titanic," then suitable alternatives might include "Romeo + Juliet," "The English Patient," "Sleepless in Seattle," "Ghost," or "Pretty Woman." In contrast, purely descriptive terms like "boat," "ocean," "love," or "ship" are **not** acceptable as alternatives, because they are not legitimate replacements of the original word in that category.

Ensure all responses comply with any excluded words or phrases specified by the user. 
""";

    final userContent = """
Generate a word pair and relevant icebreakers for a 'Word Wolf' game.

${category.isEmpty ? "There is currently no assigned category to the word pair." : "The category is '$category'."}

On a scale of 0.0 to 1.0, where 0.0 means the words are near identical (e.g. 'Sofa' and 'Couch') in meaning, where 0.3 means there's a strong connection between the words (e.g. 'Sofa' and 'Coffee table'), where 0.5 means they have some vague similarity (e.g. 'Sofa' and 'Indoors'), where 0.7 means they have almost no connection at all (e.g. 'Sofa' and 'Helicopter'), and where 1.0 means they have no connection at all and are extremely different in meaning and/or concept (e.g. 'Sofa' and 'Algebra'), the current word pair would be a $similarity (${Game.getSimilarityDescription(l10n, similarity)}) on that scale.

${excludeWords.isNotEmpty ? "You must NEVER use any of these in either of the words in the word pair: ${excludeWords.join(', ')}." : ""}

${category.isEmpty ? "The icebreakers should be extremely general, and not specific to the word pair since the players won't know the assigned category." : ""}
""";

    try {
      final response = await _httpClient.post(
        Uri.parse(
            _config.apiUrl ?? "https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${_config.apiKey}",
        },
        body: jsonEncode({
          "model": _config.model,
          "messages": [
            {
              "role": "system",
              "content": systemContent,
            },
            {
              "role": "user",
              "content": userContent,
            }
          ],
          "max_completion_tokens": 4096,
          "response_format": {
            "type": "json_schema",
            "json_schema": {
              "name": "word_wolf_output",
              "strict": true,
              "schema": {
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
              }
            }
          }
        }),
      );

      WordPairResult? validatedWordPair;

      if (response.statusCode == 200) {
        // Try to parse the response
        try {
          final jsonResponse =
              jsonDecode(response.body) as Map<String, dynamic>;
          final content =
              jsonResponse["choices"][0]["message"]["content"] as String;

          // Clean up the content string before parsing
          final sanitizedContent = _sanitizeJsonString(content);

          // Try to parse the content
          try {
            final wordPairJson =
                jsonDecode(sanitizedContent) as Map<String, dynamic>;

            // Sanitize string values in the parsed JSON
            final sanitizedWordPairJson = _sanitizeJsonMap(wordPairJson);

            // Validate the structure
            try {
              validatedWordPair = WordPairResult.fromMap(sanitizedWordPairJson);
            } catch (e) {
              print("WordPairResult validation failed: $e");
              print("Raw JSON: $sanitizedWordPairJson");
            }
          } catch (parseError) {
            print("Direct JSON parse failed: $parseError");
            print("Raw content JSON: $sanitizedContent");
          }
        } catch (e) {
          print("JSON decode error: $e");
          print("Raw response body: ${response.body}");
        }
      } else {
        print("API error response: ${response.body}");
      }

      return validatedWordPair;
    } catch (e) {
      print("OpenAI API error: $e");
      return null;
    }
  }

  /// Sanitizes a JSON string by replacing problematic characters
  String _sanitizeJsonString(String input) {
    // Replace common problematic characters
    return input.replaceAll("â", "'"); // Fix apostrophe
  }

  /// Recursively sanitizes all string values in a Map
  Map<String, dynamic> _sanitizeJsonMap(Map<String, dynamic> map) {
    final sanitizedMap = <String, dynamic>{};

    map.forEach((key, value) {
      if (value is String) {
        sanitizedMap[key] = _sanitizeJsonString(value);
      } else if (value is Map<String, dynamic>) {
        sanitizedMap[key] = _sanitizeJsonMap(value);
      } else if (value is List) {
        sanitizedMap[key] = _sanitizeJsonList(value);
      } else {
        sanitizedMap[key] = value;
      }
    });

    return sanitizedMap;
  }

  /// Recursively sanitizes all string values in a List
  List<dynamic> _sanitizeJsonList(List<dynamic> list) {
    return list.map((item) {
      if (item is String) {
        return _sanitizeJsonString(item);
      } else if (item is Map<String, dynamic>) {
        return _sanitizeJsonMap(item);
      } else if (item is List) {
        return _sanitizeJsonList(item);
      } else {
        return item;
      }
    }).toList();
  }
}
