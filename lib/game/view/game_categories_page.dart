import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";

import "../../app_ui/app_spacing.dart";
import "../../app_ui/widgets/app_button.dart";
import "../../app_ui/widgets/app_icon_button.dart";
import "../../app_ui/widgets/app_list_tile.dart";
import "../../app_ui/widgets/app_text.dart";
import "../../category/bloc/category_bloc.dart";
import "../../category/models/saved_category.dart";
import "../../l10n/l10n.dart";
import "../bloc/game_bloc.dart";
import "../view/distribute_words_page.dart";

class GameCategoriesPage extends StatelessWidget {
  const GameCategoriesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const GameCategoriesPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const GameCategoriesView();
  }
}

class GameCategoriesView extends StatefulWidget {
  const GameCategoriesView({super.key});

  @override
  State<GameCategoriesView> createState() => _GameCategoriesViewState();
}

class _GameCategoriesViewState extends State<GameCategoriesView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "";
  bool _isAddingCategory = false;
  String? _lastAddedCategory;
  String _lastSearchQuery = "";

  List<String> _displayedCategories = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      final categoryState = context.read<CategoryBloc>().state;

      setState(() {
        // Initialize selected category from game state
        if (categoryState.selectedCategory.isNotEmpty) {
          _selectedCategory = categoryState.selectedCategory;
        }

        // Restore search text if previously saved
        if (categoryState.searchText.isNotEmpty) {
          _searchController.text = categoryState.searchText;
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    if (_isAddingCategory) return;

    setState(() {
      // Toggle selection
      if (_selectedCategory == category) {
        _selectedCategory = "";
        context.read<CategoryBloc>().add(const CategorySelected(
              categoryName: "",
            ));
      } else {
        _selectedCategory = category;
        context.read<CategoryBloc>().add(CategorySelected(
              categoryName: category,
            ));
      }
    });

    // Dismiss the keyboard if visible
    FocusScope.of(context).unfocus();
  }

  void _addNewCategory(String categoryName) {
    if (_isAddingCategory || categoryName.isEmpty) return;

    setState(() {
      _isAddingCategory = true;
      _lastAddedCategory = categoryName;
      _selectedCategory = categoryName; // Select the new category
    });

    // Send to bloc which will save it
    context.read<CategoryBloc>().add(CategorySelected(
          categoryName: categoryName,
        ));

    // Clear the search field
    _searchController.clear();

    // Unfocus the text field to dismiss the keyboard
    FocusScope.of(context).unfocus();
  }

  void _removeCategory(String category) {
    if (_isAddingCategory) return;

    // Send the remove event to the bloc
    context.read<CategoryBloc>().add(CategoryRemoved(categoryName: category));

    // Update selected category if it was removed
    if (_selectedCategory == category) {
      setState(() {
        _selectedCategory = "";
      });
    }
  }

  String _formatLastUsed(AppLocalizations l10n, SavedCategory category) {
    final now = DateTime.now();
    final difference = now.difference(category.lastUsedAt);

    if (difference.inDays == 0) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return l10n.timeNow;
        } else {
          return l10n.timeMinutesAgo(difference.inMinutes);
        }
      } else {
        return l10n.timeHoursAgo(difference.inHours);
      }
    } else if (difference.inDays == 1) {
      return l10n.timeYesterday;
    } else if (difference.inDays < 7) {
      return l10n.timeDaysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      return l10n.timeWeeksAgo((difference.inDays / 7).floor());
    } else {
      return DateFormat("MMM d").format(category.lastUsedAt);
    }
  }

  void _continueToNextStep() {
    final l10n = context.l10n;

    context.read<CategoryBloc>().add(CategorySelected(
          categoryName: _selectedCategory,
        ));

    context.read<GameBloc>().add(GameStarted(
          category: _selectedCategory,
          l10n: l10n,
        ));

    // Navigate to the word distribution page
    Navigator.of(context).push(DistributeWordsPage.route());
  }

  // Update displayed categories based on search and saved categories
  void _updateDisplayedCategories(
      String searchQuery, List<String> savedCategories) {
    final state = context.read<CategoryBloc>().state;
    final presetCategories = state.presetCategories;

    // Only perform filtering if we have preset categories
    if (presetCategories.isEmpty) {
      _displayedCategories = [];
      return;
    }

    List<String> filteredSaved = [];
    List<String> filteredPreset = [];

    // Convert to lowercase once for efficiency
    final lowercaseQuery = searchQuery.toLowerCase();

    // For empty search, just use the existing lists
    if (searchQuery.isEmpty) {
      filteredSaved = [...savedCategories];

      // Performance optimization: Limit preset categories when no search
      // to improve rendering performance with large datasets
      final maxPresetsToShow = 100;
      filteredPreset = presetCategories
          .where((category) => !savedCategories.contains(category))
          .take(maxPresetsToShow) // Limit initial display
          .toList();
    } else {
      // Use efficient filter for search
      filteredSaved = savedCategories
          .where((category) => category.toLowerCase().contains(lowercaseQuery))
          .toList();

      // For search, show more results but still limit for very large datasets
      final maxSearchResults = 200;
      filteredPreset = presetCategories
          .where((category) =>
              category.toLowerCase().contains(lowercaseQuery) &&
              !savedCategories.contains(category))
          .take(maxSearchResults)
          .toList();
    }

    // Make sure any newly added category shows up in the list
    if (_lastAddedCategory != null &&
        !filteredSaved.contains(_lastAddedCategory)) {
      // If we just added this category but it's not yet in saved categories,
      // add it to our display list temporarily
      if (searchQuery.isEmpty ||
          _lastAddedCategory!.toLowerCase().contains(lowercaseQuery)) {
        filteredSaved.insert(0, _lastAddedCategory!);
      }
    }

    // Preserve the current order of displayed categories when possible
    if (_displayedCategories.isNotEmpty) {
      // Create a new combined list
      final newCombined = [...filteredSaved, ...filteredPreset];

      // Optimize comparison for large lists
      final currentSet = _displayedCategories.toSet();
      final newSet = newCombined.toSet();

      final hasStructuralChange =
          _displayedCategories.length != newCombined.length ||
              !currentSet.containsAll(newSet) ||
              !newSet.containsAll(currentSet) ||
              searchQuery != _lastSearchQuery;

      // Only update the list if search query changed or categories were added/removed
      if (hasStructuralChange) {
        _displayedCategories = newCombined;
      }
    } else {
      // Initial load - use default ordering
      _displayedCategories = [...filteredSaved, ...filteredPreset];
    }

    // Save the last search query
    _lastSearchQuery = searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listenWhen: (previous, current) {
        // Listen for any changes to the saved categories or selected category
        return previous.savedCategories != current.savedCategories ||
            previous.selectedCategory != current.selectedCategory;
      },
      listener: (context, state) {
        final savedCategoryNames =
            state.savedCategories.map((c) => c.name).toList();
        final presetCategories = state.presetCategories;

        // If we were adding a category and the state has changed, check if our category is now saved
        if (_isAddingCategory && _lastAddedCategory != null) {
          final bool isSaved = state.savedCategories
              .any((category) => category.name == _lastAddedCategory);

          if (isSaved) {
            setState(() {
              _isAddingCategory = false;
              // Keep the last added category so we can highlight it,
              // but mark that we're done adding it
            });
          }
        }

        // Store current order before updating
        final currentCategories = List<String>.from(_displayedCategories);

        // Only rebuild if this is our first render or we're adding a category
        if (_displayedCategories.isEmpty || _isAddingCategory) {
          _updateDisplayedCategories(
              _searchController.text, savedCategoryNames);
        } else {
          // For deletions and other state changes, maintain current order but remove deleted items
          final newSet = savedCategoryNames.toSet();
          final presetNotInSaved = presetCategories
              .where((category) => !newSet.contains(category))
              .toList();

          // Create a new list preserving the order but removing deleted categories
          _displayedCategories = currentCategories
              .where((category) =>
                  newSet.contains(category) ||
                  presetNotInSaved.contains(category))
              .toList();

          // Add any new categories that might have been added elsewhere
          for (final category in [...savedCategoryNames, ...presetNotInSaved]) {
            if (!_displayedCategories.contains(category)) {
              _displayedCategories.add(category);
            }
          }
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final savedCategories = state.savedCategories;
        final savedCategoryNames = savedCategories.map((c) => c.name).toList();

        // Only update displayed categories on first render or when explicitly needed
        if (_displayedCategories.isEmpty) {
          _updateDisplayedCategories(
              _searchController.text, savedCategoryNames);
        }

        return Scaffold(
          appBar: AppBar(
            title: AppText(
              l10n.categoriesTitle,
              variant: AppTextVariant.titleLarge,
            ),
            leading: AppIconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: l10n.back,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _buildContent(
              status: state.status,
              savedCategoryNames: savedCategoryNames,
              savedCategories: savedCategories,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent({
    required CategoryStatus status,
    required List<String> savedCategoryNames,
    required List<SavedCategory> savedCategories,
  }) {
    final l10n = context.l10n;

    // Show loading indicator if the game is in loading state
    if (status == CategoryStatus.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            AppText(l10n.categoriesLoading),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category Selection Section
        AppText(
          l10n.categorySelection,
          variant: AppTextVariant.titleMedium,
          weight: AppTextWeight.bold,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          l10n.categoryDescription,
          variant: AppTextVariant.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),

        // Search and add category field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.categorySearchHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  AppIconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.categoryClear,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _updateDisplayedCategories("", savedCategoryNames);
                      });
                      context
                          .read<CategoryBloc>()
                          .add(const CategorySearchUpdated(
                            searchText: "",
                          ));
                    },
                  ),
                if (_searchController.text.isNotEmpty)
                  AppIconButton(
                    icon: const Icon(Icons.check),
                    tooltip: l10n.useCategory,
                    onPressed: () {
                      final category = _searchController.text.trim();
                      _addNewCategory(category);
                    },
                  ),
              ],
            ),
          ),
          maxLength: 200, // To avoid abuse
          buildCounter: (
            context, {
            required int currentLength,
            required bool isFocused,
            required int? maxLength,
          }) =>
              null, // Hide the default counter
          onChanged: (value) {
            setState(() {
              _updateDisplayedCategories(value, savedCategoryNames);
            });
            context.read<CategoryBloc>().add(CategorySearchUpdated(
                  searchText: value,
                ));
          },
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) {
              _addNewCategory(trimmed);
            }
          },
          enabled: !_isAddingCategory, // Disable when adding a category
        ),

        const SizedBox(height: AppSpacing.md),

        // Show loading indicator when adding a category
        if (_isAddingCategory)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: LinearProgressIndicator(),
          ),

        // Category list
        Expanded(
          flex: 1,
          child: Card(
            child: _displayedCategories.isEmpty
                ? Center(
                    child: AppText(
                      l10n.noCategoriesFound,
                      variant: AppTextVariant.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    itemCount: _displayedCategories.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                    itemBuilder: (context, index) {
                      final category = _displayedCategories[index];
                      final isSaved = savedCategoryNames.contains(category);
                      final isNewlyAdded =
                          category == _lastAddedCategory && !isSaved;

                      // Find the saved category if it exists
                      SavedCategory? savedCategory;
                      if (isSaved) {
                        savedCategory = savedCategories.firstWhere(
                          (c) => c.name == category,
                        );
                      }

                      return AppListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 0,
                        ),
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -3,
                        ),
                        shape: RoundedRectangleBorder(
                          side: _selectedCategory == category
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : BorderSide(
                                  color: Colors.transparent,
                                  width: 2,
                                ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: _selectedCategory == category
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withAlpha(76)
                            : null,
                        title: AppText(
                          category,
                          style: isNewlyAdded
                              ? const TextStyle(fontStyle: FontStyle.italic)
                              : null,
                        ),
                        subtitle: savedCategory != null
                            ? AppText(
                                l10n.lastUsed(
                                    _formatLastUsed(l10n, savedCategory)),
                                variant: AppTextVariant.labelSmall,
                              )
                            : isNewlyAdded
                                ? AppText(
                                    l10n.addingCategory,
                                    variant: AppTextVariant.labelSmall,
                                  )
                                : null,
                        selected: _selectedCategory == category,
                        onTap: !_isAddingCategory
                            ? () => _selectCategory(category)
                            : null,
                        trailing: SizedBox(
                          width: 48,
                          child: isSaved && !_isAddingCategory
                              ? AppIconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: l10n.removeCategory,
                                  onPressed: () => _removeCategory(category),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ),

        // Continue button
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: SafeArea(
            child: AppButton(
              variant: AppButtonVariant.elevated,
              onPressed: _continueToNextStep,
              child: AppText(
                l10n.startGame,
                variant: AppTextVariant.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
