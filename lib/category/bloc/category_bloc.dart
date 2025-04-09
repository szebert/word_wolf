import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";

import "../models/saved_category.dart";
import "../repository/category_repository.dart";

part "category_event.dart";
part "category_state.dart";

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required CategoryRepository categoryRepository,
  })  : _categoryRepository = categoryRepository,
        super(const CategoryState()) {
    on<CategoryInitialized>(_onCategoryInitialized);
    on<CategorySearchUpdated>(_onCategorySearchUpdated);
    on<CategorySelected>(_onCategorySelected);
    on<CategoryRemoved>(_onCategoryRemoved);
  }

  final CategoryRepository _categoryRepository;

  Future<void> _onCategoryInitialized(
    CategoryInitialized event,
    Emitter<CategoryState> emit,
  ) async {
    if (state.status == CategoryStatus.ready ||
        state.status == CategoryStatus.loading) {
      return;
    }
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      // Load saved categories
      final savedCategories = await _categoryRepository.getSavedCategories();

      // Load preset categories
      final presetCategories = await _categoryRepository.getPresetCategories();

      // Load selected category if available
      final selectedCategory = await _categoryRepository.getSelectedCategory();

      emit(
        state.copyWith(
          status: CategoryStatus.ready,
          savedCategories: savedCategories,
          presetCategories: presetCategories,
          selectedCategory: selectedCategory,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          error: "Failed to load category data: $error",
        ),
      );
    }
  }

  void _onCategorySearchUpdated(
    CategorySearchUpdated event,
    Emitter<CategoryState> emit,
  ) {
    emit(
      state.copyWith(
        searchText: event.searchText,
      ),
    );
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<CategoryState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategory: event.categoryName,
      ),
    );

    // When a category is selected, update its lastUsedAt timestamp
    if (event.categoryName.isNotEmpty) {
      final updatedCategories = await _categoryRepository.addOrUpdateCategory(
        event.categoryName,
      );
      emit(
        state.copyWith(savedCategories: updatedCategories),
      );
    }

    // Save the selected category
    await _categoryRepository.saveSelectedCategory(event.categoryName);
  }

  Future<void> _onCategoryRemoved(
    CategoryRemoved event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final savedCategories = await _categoryRepository.removeCategory(
        event.categoryName,
      );

      // If the removed category is the selected category, clear it
      final updatedSelectedCategory =
          state.selectedCategory == event.categoryName
              ? ""
              : state.selectedCategory;

      emit(
        state.copyWith(
          savedCategories: savedCategories,
          selectedCategory: updatedSelectedCategory,
        ),
      );

      // If selected category changed, save it
      if (updatedSelectedCategory != state.selectedCategory) {
        await _categoryRepository.saveSelectedCategory(updatedSelectedCategory);
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          error: "Failed to remove category: $error",
        ),
      );
    }
  }
}
