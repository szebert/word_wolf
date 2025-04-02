import 'dart:convert';

import '../../storage/persistent_storage.dart';
import '../models/saved_category.dart';

/// {@template category_repository}
/// Repository for managing saved categories with persistent storage.
/// {@endtemplate}
class CategoryRepository {
  /// {@macro category_repository}
  CategoryRepository({
    required PersistentStorage persistentStorage,
  }) : _persistentStorage = persistentStorage;

  final PersistentStorage _persistentStorage;
  static const String _kSavedCategoriesKey = 'saved_categories';

  /// Returns the list of saved categories
  Future<List<SavedCategory>> getSavedCategories() async {
    final categoriesJsonString = await _persistentStorage.read(
      key: _kSavedCategoriesKey,
    );

    if (categoriesJsonString == null || categoriesJsonString.isEmpty) {
      // Return an empty list if no categories exist
      return [];
    }

    try {
      final List<dynamic> categoriesJson =
          jsonDecode(categoriesJsonString) as List<dynamic>;

      final categories = categoriesJson
          .map((item) => SavedCategory.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort by most recently used first
      categories.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));

      return categories;
    } catch (e) {
      // If parsing failed, return an empty list
      return [];
    }
  }

  /// Save the list of categories to storage
  Future<void> saveCategories(List<SavedCategory> categories) async {
    final categoriesJson =
        categories.map((category) => category.toJson()).toList();
    final jsonString = jsonEncode(categoriesJson);
    await _persistentStorage.write(
      key: _kSavedCategoriesKey,
      value: jsonString,
    );
  }

  /// Add or update a category
  Future<List<SavedCategory>> addOrUpdateCategory(String categoryName) async {
    final categories = await getSavedCategories();

    // Use trimmed category name to avoid whitespace issues
    final trimmedName = categoryName.trim();

    // Check if the category already exists
    final existingIndex = categories.indexWhere((c) => c.name == trimmedName);

    if (existingIndex >= 0) {
      // Update existing category with new timestamp
      final updatedCategory = categories[existingIndex].copyWith(
        lastUsedAt: DateTime.now(),
      );
      categories[existingIndex] = updatedCategory;
    } else {
      // Add new category with current timestamp
      categories.add(
        SavedCategory(
          name: trimmedName,
          lastUsedAt: DateTime.now(),
        ),
      );
    }

    // Sort by most recently used
    categories.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));

    // Enforce maximum of 100 saved categories by removing oldest ones
    const maxSavedCategories = 5;
    if (categories.length > maxSavedCategories) {
      // Keep only the 100 most recently used categories
      categories.removeRange(maxSavedCategories, categories.length);
    }

    // Save to storage
    await saveCategories(categories);

    return categories;
  }

  /// Remove a category by name
  Future<List<SavedCategory>> removeCategory(String categoryName) async {
    final categories = await getSavedCategories();
    final updatedCategories =
        categories.where((c) => c.name != categoryName).toList();
    await saveCategories(updatedCategories);
    return updatedCategories;
  }
}
