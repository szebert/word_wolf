import "dart:convert";

import "package:firebase_vertexai/firebase_vertexai.dart";

import "ai_service.dart";

/// {@template gemini_service}
/// Service for generating structured responses using Google's Gemini AI through Firebase Vertex AI.
/// No configuration required as it uses Firebase project credentials.
/// {@endtemplate}
class GeminiService implements AIService {
  /// {@macro gemini_service}
  GeminiService();

  @override
  bool get isConfigured => true; // Always configured through Firebase

  @override
  Future<Map<String, dynamic>?> generateStructuredResponse({
    required String systemPrompt,
    required String userPrompt,
    required Map<String, dynamic> schema,
  }) async {
    try {
      // Define the schema for structured output
      final responseSchema = _convertJsonSchemaToVertexSchema(schema);

      // Set up generation config
      final generationConfig = GenerationConfig(
        responseMimeType: "application/json",
        responseSchema: responseSchema,
        maxOutputTokens: 4096,
      );

      // Create Gemini model instance
      final model = FirebaseVertexAI.instance.generativeModel(
        model: "gemini-2.0-flash-lite",
        generationConfig: generationConfig,
      );

      // Create the contents for the request
      final contents = [
        Content("model", [TextPart(systemPrompt)]),
        Content("user", [TextPart(userPrompt)]),
      ];

      // Generate content
      final response = await model.generateContent(contents);

      // Parse the generated content
      if (response.text != null) {
        try {
          final jsonResponse =
              jsonDecode(response.text!) as Map<String, dynamic>;
          return jsonResponse;
        } catch (e) {
          print("Error parsing Gemini response: $e");
          print("Raw response: ${response.text}");
          return null;
        }
      }

      return null;
    } catch (e) {
      print("Gemini API error: $e");
      return null;
    }
  }

  /// Converts a JSON Schema to Firebase Vertex AI Schema
  Schema _convertJsonSchemaToVertexSchema(Map<String, dynamic> jsonSchema) {
    // Get properties from the schema
    final properties = jsonSchema["properties"] as Map<String, dynamic>;

    // Create a map to hold the Vertex schema properties
    final vertexProperties = <String, Schema>{};

    // Convert each property to Vertex Schema format
    properties.forEach((key, value) {
      final propType = value["type"] as String?;
      final description = value["description"] as String? ?? "";

      switch (propType) {
        case "string":
          vertexProperties[key] = Schema.string(
            description: description,
            nullable: false,
            format: "string",
          );
          break;
        case "array":
          // Handle array type
          Schema? vertexItems;
          final items = value["items"] as Map<String, dynamic>?;
          if (items == null) break;
          if (items["type"] == "string") {
            vertexItems = Schema.string();
          } else if (items["type"] == "object") {
            // Recursive call to handle nested objects
            final nestedSchema = _convertJsonSchemaToVertexSchema(items);
            vertexItems = nestedSchema;
          } else {
            break;
          }
          vertexProperties[key] = Schema.array(
            description: description,
            items: vertexItems,
            nullable: false,
          );
          break;
        case "object":
          // Recursive call to handle nested objects
          final nestedSchema = _convertJsonSchemaToVertexSchema(value);
          vertexProperties[key] = nestedSchema;
          break;
        default:
          break;
      }
    });

    // Create and return the schema object
    return Schema.object(
      properties: vertexProperties,
      nullable: false,
    );
  }
}
