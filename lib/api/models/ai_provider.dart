/// {@template ai_provider}
/// Enum defining available AI providers for the app
/// {@endtemplate}
enum AIProvider {
  /// Firebase Gemini AI
  gemini,

  /// OpenAI
  openAI,
}

/// {@template ai_config}
/// Base class for AI provider configuration
/// {@endtemplate}
abstract class AIConfig {
  /// {@macro ai_config}
  const AIConfig({
    required this.enabled,
  });

  /// Whether the AI provider is enabled
  final bool enabled;

  /// Convert configuration to a map for storage
  Map<String, dynamic> toMap();
}

/// {@template openai_config}
/// Configuration for OpenAI
/// {@endtemplate}
class OpenAIConfig extends AIConfig {
  /// {@macro openai_config}
  const OpenAIConfig({
    required super.enabled,
    this.apiKey,
    this.apiUrl,
    this.model = "gpt-o3-mini",
  });

  /// Default OpenAI configuration with disabled state
  static const OpenAIConfig defaultConfig = OpenAIConfig(enabled: false);

  /// The OpenAI API key
  final String? apiKey;

  /// The OpenAI API URL
  final String? apiUrl;

  /// The OpenAI model to use
  final String model;

  /// Create an OpenAIConfig from a map
  factory OpenAIConfig.fromMap(Map<String, dynamic> map) {
    return OpenAIConfig(
      enabled: map["enabled"] as bool? ?? false,
      apiKey: map["apiKey"] as String?,
      apiUrl: map["apiUrl"] as String?,
      model: map["model"] as String? ?? "gpt-o3-mini",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "enabled": enabled,
      if (apiKey != null && apiKey!.isNotEmpty) "apiKey": apiKey,
      if (apiUrl != null && apiUrl!.isNotEmpty) "apiUrl": apiUrl,
      "model": model,
    };
  }

  /// Create a copy of this config with the given fields replaced
  OpenAIConfig copyWith({
    bool? enabled,
    String? apiKey,
    String? apiUrl,
    String? model,
  }) {
    return OpenAIConfig(
      enabled: enabled ?? this.enabled,
      apiKey: apiKey ?? this.apiKey,
      apiUrl: apiUrl ?? this.apiUrl,
      model: model ?? this.model,
    );
  }

  /// Create a copy with explicit handling of null values for nullable fields
  /// This allows setting a field to null, overriding the existing value
  OpenAIConfig copyWithExplicitNulls({
    bool? enabled,
    Object? apiKey = const Object(),
    Object? apiUrl = const Object(),
    String? model,
  }) {
    return OpenAIConfig(
      enabled: enabled ?? this.enabled,
      apiKey: apiKey == const Object() ? this.apiKey : apiKey as String?,
      apiUrl: apiUrl == const Object() ? this.apiUrl : apiUrl as String?,
      model: model ?? this.model,
    );
  }

  /// Check if the OpenAI configuration is valid for use
  bool get isValid => enabled && apiKey != null && apiKey!.isNotEmpty;
}
