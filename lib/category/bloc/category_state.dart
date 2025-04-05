part of 'category_bloc.dart';

enum CategoryStatus {
  initial,
  loading,
  ready,
  error,
}

class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.searchText = '',
    this.savedCategories = const [],
    this.presetCategories = const [],
    this.selectedCategory = '',
    this.error = '',
  });

  final CategoryStatus status;
  final String searchText;
  final List<SavedCategory> savedCategories;
  final List<String> presetCategories;
  final String selectedCategory;
  final String error;

  CategoryState copyWith({
    CategoryStatus? status,
    String? searchText,
    List<SavedCategory>? savedCategories,
    List<String>? presetCategories,
    String? selectedCategory,
    String? error,
  }) {
    return CategoryState(
      status: status ?? this.status,
      searchText: searchText ?? this.searchText,
      savedCategories: savedCategories ?? this.savedCategories,
      presetCategories: presetCategories ?? this.presetCategories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [
        status,
        searchText,
        savedCategories,
        presetCategories,
        selectedCategory,
        error,
      ];
}
