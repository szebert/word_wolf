import "dart:convert";

import "package:http/http.dart" as http;

import "../../analytics/logging_service.dart";
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
/// Implementation of [AIService] that uses OpenAI API to generate responses
/// {@endtemplate}
class OpenAIService implements AIService {
  /// {@macro openai_service}
  OpenAIService({
    required OpenAIConfig config,
    http.Client? httpClient,
    LoggingService? loggingService,
  })  : _config = config,
        _httpClient = httpClient ?? http.Client(),
        _loggingService = loggingService ?? LoggingService();

  OpenAIConfig _config;
  final http.Client _httpClient;
  final LoggingService _loggingService;

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

      _loggingService.logError(
        Exception("OpenAI test configuration error"),
        StackTrace.current,
        reason: "OpenAI test configuration error",
        information: [
          "Error message: $errorMessage",
          "Error code: $errorCode",
          "API URL: ${_config.apiUrl}",
          "Model: ${_config.model}",
        ],
      );

      return OpenAIConfigError.unknown;
    } on http.ClientException {
      return OpenAIConfigError.offline;
    } catch (e) {
      _loggingService.logError(
        e,
        StackTrace.current,
        reason: "OpenAI test configuration error",
        information: [
          "API URL: ${_config.apiUrl}",
          "Model: ${_config.model}",
        ],
      );
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
  Future<Map<String, dynamic>?> generateStructuredResponse({
    required String systemPrompt,
    required String userPrompt,
    required Map<String, dynamic> schema,
  }) async {
    if (!isConfigured) {
      return null;
    }

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
              "content": systemPrompt,
            },
            {
              "role": "user",
              "content": userPrompt,
            }
          ],
          "max_completion_tokens": 4096,
          "response_format": {
            "type": "json_schema",
            "json_schema": {
              "name": "output",
              "strict": true,
              "schema": schema,
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        // Try to parse the response
        try {
          final decodedBody = utf8.decode(response.bodyBytes);
          final jsonResponse = jsonDecode(decodedBody) as Map<String, dynamic>;

          final content =
              jsonResponse["choices"][0]["message"]["content"] as String;

          // Try to parse the content
          try {
            return jsonDecode(content) as Map<String, dynamic>;
          } catch (e) {
            _loggingService.logError(
              e,
              StackTrace.current,
              reason: "OpenAI content JSON decode error",
              information: ["Raw content: $content"],
            );
          }
        } catch (e) {
          _loggingService.logError(
            e,
            StackTrace.current,
            reason: "OpenAI JSON decode error",
            information: [
              "Raw response body: ${response.body}",
              "Raw response bytes: ${response.bodyBytes}"
            ],
          );
        }
      } else {
        _loggingService.logError(
          Exception("API error - status code: ${response.statusCode}"),
          StackTrace.current,
          reason: "OpenAI API error response",
          information: ["Response body: ${response.body}"],
        );
      }

      return null;
    } catch (e) {
      _loggingService.logError(
        e,
        StackTrace.current,
        reason: "OpenAI API error",
      );
      return null;
    }
  }
}
