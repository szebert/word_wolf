import 'package:equatable/equatable.dart';

/// {@template saved_category}
/// A model representing a user-saved category with a timestamp
/// {@endtemplate}
class SavedCategory extends Equatable {
  /// {@macro saved_category}
  const SavedCategory({
    required this.name,
    required this.lastUsedAt,
  });

  /// The name of the category
  final String name;

  /// Timestamp when the category was last selected/used
  final DateTime lastUsedAt;

  /// Creates a copy of this SavedCategory with the given fields replaced.
  SavedCategory copyWith({
    String? name,
    DateTime? lastUsedAt,
  }) {
    return SavedCategory(
      name: name ?? this.name,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Create a SavedCategory from a Map.
  factory SavedCategory.fromJson(Map<String, dynamic> json) {
    return SavedCategory(
      name: json['name'] as String,
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
    );
  }

  /// Convert this SavedCategory to a Map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastUsedAt': lastUsedAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [name, lastUsedAt];
}
